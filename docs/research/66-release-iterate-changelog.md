# Changelog Create/Update Skill — Research Summary

## Sources
- [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [GitHub Official MCP Server](https://github.com/github/github-mcp-server)
- [GitLab MCP Server Docs](https://docs.gitlab.com/user/gitlab_duo/model_context_protocol/mcp_server/)
- [GitLab Community MCP Servers](https://github.com/zereight/gitlab-mcp) / [yoda-digital](https://github.com/yoda-digital/mcp-gitlab-server)
- Git tagging & diff analysis best practices (multiple sources)

---

## 1. What Is a Changelog?

A curated, chronologically ordered list of notable changes for each version of a project. It is written **for humans, not machines** — distinct from git log dumps.

---

## 2. Keep a Changelog Standard — Key Rules

### File Naming & Location
- File should be named `CHANGELOG.md` (preferred over `HISTORY`, `NEWS`, `RELEASES`).
- Lives in the project root.

### Header Boilerplate
Every changelog should start with:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
```

### Section Structure (per version)

```markdown
## [Unreleased]

## [1.2.0] - 2025-06-15

### Added
- ...

### Changed
- ...

### Deprecated
- ...

### Removed
- ...

### Fixed
- ...

### Security
- ...
```

### The 6 Change Types
| Type          | When to Use                                  |
|---------------|----------------------------------------------|
| **Added**     | New features                                 |
| **Changed**   | Changes to existing functionality             |
| **Deprecated**| Features that will be removed in the future   |
| **Removed**   | Features that have been removed               |
| **Fixed**     | Bug fixes                                    |
| **Security**  | Vulnerability fixes                          |

### Guiding Principles
1. Changelogs are for **humans**, not machines.
2. There should be an entry for **every single version**.
3. The same types of changes should be **grouped** (using the 6 types above).
4. Versions and sections should be **linkable**.
5. The **latest version comes first** (reverse chronological).
6. The **release date** of each version is displayed.
7. Mention whether you follow **Semantic Versioning**.

### `[Unreleased]` Section
- Always maintain an `[Unreleased]` section at the top.
- Tracks upcoming changes before they're tagged to a version.
- At release time, move `[Unreleased]` entries into a new versioned section.

### Date Format
- Always use **ISO 8601**: `YYYY-MM-DD` (e.g., `2025-06-15`).
- Never use ambiguous regional formats.

### Comparison Links (Footer)
At the bottom, include diff links between versions:

```markdown
[unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

### Yanked Releases
Mark pulled/broken releases explicitly:
```markdown
## [0.0.5] - 2014-12-13 [YANKED]
```

### Anti-Patterns to Avoid
- **Commit log dumps** — noisy, not curated for end users.
- **Ignoring deprecations** — always list deprecations, removals, and breaking changes.
- **Confusing dates** — stick to ISO 8601.
- **Inconsistent changes** — if you have a changelog, keep it complete or users lose trust.

---

## 3. Semantic Versioning (SemVer 2.0.0) — Key Rules

### Version Format
```
MAJOR.MINOR.PATCH
```
Example: `1.4.2`

### When to Increment What

| Component  | Increment When...                                      | Resets          |
|------------|--------------------------------------------------------|-----------------|
| **MAJOR**  | Incompatible / breaking API changes                    | MINOR & PATCH → 0 |
| **MINOR**  | New backward-compatible functionality, or deprecations  | PATCH → 0       |
| **PATCH**  | Backward-compatible bug fixes only                     | Nothing          |

### Additional Rules
- **0.y.z** = initial development, anything can change, API not stable.
- **1.0.0** = defines the stable public API.
- Once released, a version's contents **must not be modified** — any fix = new version.
- **Pre-release**: append hyphen + identifiers → `1.0.0-alpha`, `1.0.0-beta.1`, `1.0.0-rc.1`
- **Build metadata**: append plus sign → `1.0.0+20130313144700` (ignored in precedence).

### Version Precedence
```
1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
```

### SemVer Regex (JavaScript-compatible)
```
^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
```

### Deprecation Handling
1. Update documentation to inform users.
2. Issue a new **minor** release with the deprecation.
3. Only **remove** in a subsequent **major** release.

---

## 4. Skill Design Recommendations

Based on the research above, a `changelog-create-update` skill should handle these scenarios:

### Scenario A: Create a New Changelog
**Inputs**: Project name, optional repo URL, optional initial version + changes.

**Output**: A well-formed `CHANGELOG.md` with:
- Standard header boilerplate
- `[Unreleased]` section
- Optional initial version entry
- Footer with comparison links (if repo URL provided)

### Scenario B: Add a New Release to an Existing Changelog
**Inputs**: Existing `CHANGELOG.md`, new version number, date, list of changes by type.

**Steps**:
1. Parse existing changelog.
2. Move relevant `[Unreleased]` items into the new version section (or accept explicit items).
3. Insert the new version section below `[Unreleased]` and above previous versions.
4. Update footer comparison links.
5. Validate version number against SemVer.
6. Validate date is ISO 8601.

### Scenario C: Add Entries to `[Unreleased]`
**Inputs**: Existing `CHANGELOG.md`, changes to add (with type classification).

**Steps**:
1. Parse `[Unreleased]` section.
2. Append new items under the correct change type sub-headers.
3. Create missing sub-headers as needed.

### Validation Rules the Skill Should Enforce
- Version numbers must be valid SemVer (`MAJOR.MINOR.PATCH[-prerelease][+build]`).
- Dates must be `YYYY-MM-DD`.
- Versions must be in reverse chronological order.
- Only the 6 standard change types should be used.
- New version must be greater than the previous latest version.
- Breaking changes should require a MAJOR bump (warn if not).
- Deprecations should trigger at least a MINOR bump (warn if not).

### Parsing Strategy
The changelog format is well-structured Markdown. Key parsing anchors:
- `## [Unreleased]` — the unreleased section
- `## [x.y.z] - YYYY-MM-DD` — versioned sections
- `### Added|Changed|Deprecated|Removed|Fixed|Security` — change type headers
- `- ` prefixed lines — individual change entries
- Footer link definitions: `[x.y.z]: https://...`

### Edge Cases to Handle
- Changelog doesn't exist yet → create from scratch
- `[Unreleased]` section is empty → still include it
- No repo URL provided → omit comparison links
- Yanked releases → preserve `[YANKED]` tag
- Pre-release versions → valid SemVer, place correctly in order
- Existing changelog uses non-standard formatting → best-effort parsing, normalize on output

---

## 5. Example Output: Complete Changelog

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Dark mode support for the dashboard.

## [1.1.0] - 2025-06-15

### Added

- User profile avatars.
- Export to CSV functionality.

### Changed

- Improved search performance by 40%.

### Fixed

- Login timeout issue on slow connections.

## [1.0.0] - 2025-03-01

### Added

- Initial release with core authentication, dashboard, and reporting modules.

[unreleased]: https://github.com/user/repo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

---

## 6. Git Tagging for Releases

### Two Types of Git Tags

| Type           | Command                                           | Use Case                                |
|----------------|---------------------------------------------------|-----------------------------------------|
| **Lightweight** | `git tag v1.0.0`                                 | Quick bookmark, no metadata             |
| **Annotated**   | `git tag -a v1.0.0 -m "Release version 1.0.0"`  | Recommended for releases — stores author, date, message |

**Always use annotated tags for releases.** They are stored as full objects in Git and include tagger name, email, date, and message.

### Tag Naming Convention
- Use `v` prefix: `v1.0.0`, `v2.1.0-beta.1` (SemVer spec says "v1.2.3" is not a semantic version, but `v` prefix is the universal convention for tag names)
- Tag name maps directly to changelog version: `## [1.2.0]` → `git tag v1.2.0`
- Pre-release tags: `v1.0.0-alpha`, `v1.0.0-rc.1`

### Git Tag Commands Reference

```bash
# Create annotated tag for release
git tag -a v1.2.0 -m "Release v1.2.0 — Added export feature, fixed login bug"

# Create tag on a specific commit (retroactive tagging)
git tag -a v1.2.0 -m "Release v1.2.0" abc1234

# List all tags
git tag -l

# List tags matching a pattern
git tag -l "v1.*"

# Show tag details
git show v1.2.0

# Push a single tag to remote
git push origin v1.2.0

# Push all tags to remote
git push origin --tags

# Delete a local tag
git tag -d v1.2.0

# Delete a remote tag
git push origin --delete v1.2.0

# Get latest tag
git describe --tags --abbrev=0

# Get latest tag with commit distance
git describe --tags
# Output example: v1.2.0-3-g7a8b9c0 (3 commits after v1.2.0)
```

### Tag Message Best Practices
The tag message should summarize the release. Options:

**Option A: Short summary**
```bash
git tag -a v1.2.0 -m "Added CSV export, improved search performance, fixed login timeout"
```

**Option B: Changelog excerpt** (recommended — mirrors the changelog)
```bash
git tag -a v1.2.0 -m "Release v1.2.0

Added:
- User profile avatars
- Export to CSV functionality

Changed:
- Improved search performance by 40%

Fixed:
- Login timeout issue on slow connections"
```

### Immutability Rule
Once a tag is pushed, it should **never** be moved or deleted (same principle as SemVer: once released, contents must not change). If you realize a mistake after tagging, create a new version rather than re-tagging.

### Integration with Changelog Workflow
The skill should support this release flow:

1. **Develop** → entries accumulate in `[Unreleased]`
2. **Release** → skill creates new versioned section in CHANGELOG.md
3. **Tag** → skill creates annotated git tag with changelog content as message
4. **Push** → skill pushes tag to remote
5. **(Optional) GitHub/GitLab Release** → skill creates a platform release via MCP

---

## 7. Optional MCP Integration — GitHub & GitLab

The skill should optionally integrate with GitHub or GitLab MCP servers to create platform releases alongside local git tags and changelog updates. This is a **non-blocking optional enhancement** — the core skill works purely with local files and git.

### 7.1 GitHub MCP Server

**Official Server**: [github/github-mcp-server](https://github.com/github/github-mcp-server)

**Setup Options**:

Remote (hosted by GitHub):
```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

Local (Docker):
```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

**Relevant Tools for Changelog Skill**:

| Tool                       | Purpose                                              |
|----------------------------|------------------------------------------------------|
| `create_release`           | Create a GitHub Release from a tag with release notes |
| `list_releases`            | List existing releases to validate no duplicates      |
| `get_file_contents`        | Read existing CHANGELOG.md from repo                  |
| `create_or_update_file`    | Push updated CHANGELOG.md back to repo                |
| `push_files`               | Push multiple files in a single commit                |
| `list_commits`             | Get commits since last tag for auto-generating notes  |
| `list_tags`                | Verify tag state before creating release              |

**Create Release API Pattern** (via MCP tool call):
```
Tool: create_release
Inputs:
  owner: "user"
  repo: "my-project"
  tag_name: "v1.2.0"
  name: "v1.2.0"
  body: "<changelog content for this version>"
  draft: false
  prerelease: false
```

### 7.2 GitLab MCP Server

**Official Server** (built-in to GitLab 17.8+):
```json
{
  "mcpServers": {
    "GitLab": {
      "httpUrl": "https://gitlab.example.com/api/v4/mcp"
    }
  }
}
```

Supports **OAuth 2.0 Dynamic Client Registration** — AI tools auto-register and authenticate.

**Community Servers** (for older GitLab or more tooling):
- [zereight/gitlab-mcp](https://github.com/zereight/gitlab-mcp) — most popular community server
- [yoda-digital/mcp-gitlab-server](https://github.com/yoda-digital/mcp-gitlab-server) — TypeScript, SSE + stdio
- [LuisCusihuaman/gitlab-mcp-server](https://github.com/LuisCusihuaman/gitlab-mcp-server) — Go, toolset-based

**Community Server Setup Example** (zereight/gitlab-mcp):
```json
{
  "mcpServers": {
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@zereight/gitlab-mcp@latest"],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "<your-token>",
        "GITLAB_API_URL": "https://gitlab.com/api/v4"
      }
    }
  }
}
```

**Relevant GitLab API Endpoints** (exposed via MCP tools):

| Operation                   | GitLab API                                             |
|-----------------------------|--------------------------------------------------------|
| Create Release              | `POST /projects/:id/releases`                          |
| Create Tag                  | `POST /projects/:id/repository/tags`                   |
| List Tags                   | `GET /projects/:id/repository/tags`                    |
| Get/Update File             | `GET/PUT /projects/:id/repository/files/:file_path`    |
| List Commits                | `GET /projects/:id/repository/commits`                 |
| Create Commit (multi-file)  | `POST /projects/:id/repository/commits`                |

**Create Release Pattern** (GitLab API):
```json
POST /projects/:id/releases
{
  "tag_name": "v1.2.0",
  "name": "v1.2.0",
  "description": "<changelog content for this version>",
  "ref": "main"
}
```

GitLab can **auto-create the tag** when creating a release if the tag doesn't exist yet — specify `ref` to indicate which branch to tag.

### 7.3 MCP Integration Strategy for the Skill

The skill should implement MCP as an **optional layer** with graceful fallback:

```
┌─────────────────────────────────────────────────────┐
│                   Skill Workflow                     │
├─────────────────────────────────────────────────────┤
│  1. Parse/update CHANGELOG.md           (always)     │
│  2. Validate SemVer + dates             (always)     │
│  3. Write updated CHANGELOG.md          (always)     │
│  4. Create annotated git tag            (if in repo) │
│  5. Push tag to remote                  (if remote)  │
│  6. Create GitHub/GitLab Release        (if MCP)     │
│  7. Push updated CHANGELOG.md to remote (if MCP)     │
└─────────────────────────────────────────────────────┘
```

**Detection Logic**:
1. Check if current directory is a git repo (`git rev-parse --is-inside-work-tree`)
2. Check remote URL to detect platform: `github.com` → GitHub, `gitlab.com` or custom → GitLab
3. Check if MCP server is available for the detected platform
4. If MCP unavailable, fall back to local git operations only

**Release Body Generation**:
Extract the relevant version's changelog entries and format as Markdown for the release body. Strip the version header since GitHub/GitLab provide their own title.

---

## 8. Commit Analysis & Auto-Generated Changelog

This is a **core feature** of the skill: analyze recent git commits (and optionally diffs) to automatically generate or populate changelog entries. The skill should support two modes of commit messages — Conventional Commits (structured, easy to parse) and freeform commits (require heuristic/LLM classification).

### 8.1 Conventional Commits Specification (v1.0.0)

**Source**: [conventionalcommits.org](https://www.conventionalcommits.org/en/v1.0.0/)

**Format**:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Examples**:
```
feat(auth): add OAuth2 login support
fix(api): prevent race condition in request handler
docs: update README with new API endpoints
feat!: redesign user dashboard layout

BREAKING CHANGE: dashboard widgets now use grid layout instead of flex
```

**Commit Type → Changelog Category Mapping**:

| Conventional Commit Type | Keep a Changelog Category | SemVer Impact | Include in Changelog? |
|--------------------------|---------------------------|---------------|----------------------|
| `feat`                   | **Added**                 | MINOR         | ✅ Always            |
| `fix`                    | **Fixed**                 | PATCH         | ✅ Always            |
| `feat!` / `BREAKING CHANGE` | **Changed** or **Removed** | MAJOR    | ✅ Always            |
| `perf`                   | **Changed**               | PATCH         | ✅ Usually           |
| `refactor`               | (omit or **Changed**)     | —             | ⚠️ Optional          |
| `docs`                   | (omit)                    | —             | ❌ Usually not       |
| `style`                  | (omit)                    | —             | ❌ No                |
| `test`                   | (omit)                    | —             | ❌ No                |
| `build`                  | (omit)                    | —             | ❌ No                |
| `ci`                     | (omit)                    | —             | ❌ No                |
| `chore`                  | (omit)                    | —             | ❌ No                |
| `revert`                 | **Removed** or **Fixed**  | varies        | ✅ Usually           |
| `deprecate` (custom)     | **Deprecated**            | MINOR         | ✅ Always            |
| `security` (custom)      | **Security**              | PATCH         | ✅ Always            |

**Parsing Regex** (for extracting type, scope, breaking, description):
```regex
^(?<type>\w+)(?:\((?<scope>[^)]+)\))?(?<breaking>!)?:\s*(?<description>.+)$
```

**Breaking Change Detection**:
1. `!` after type/scope: `feat!:` or `feat(api)!:`
2. `BREAKING CHANGE:` or `BREAKING-CHANGE:` in footer
3. Both are valid — check both

**Auto SemVer Suggestion**:
Based on parsed commits, the skill can suggest the next version:
- Any `BREAKING CHANGE` or `!` → suggest MAJOR bump
- Any `feat` → suggest at least MINOR bump
- Only `fix`, `perf`, etc. → suggest PATCH bump

### 8.2 Freeform Commit Analysis (Non-Conventional)

When commits don't follow Conventional Commits, the skill should use a **multi-signal heuristic** approach combining commit message keywords, file paths changed, and diff statistics.

#### Signal 1: Commit Message Keywords

```python
KEYWORD_PATTERNS = {
    "Added": [
        r"\badd(ed|s|ing)?\b", r"\bnew\b", r"\bcreate[ds]?\b",
        r"\bintroduc(e|ed|ing)\b", r"\bimplement(ed|s)?\b",
        r"\bsupport(s|ed)?\b"
    ],
    "Fixed": [
        r"\bfix(ed|es|ing)?\b", r"\bbug\b", r"\bpatch(ed|es)?\b",
        r"\bresolv(e|ed|ing)\b", r"\bcorrect(ed|s)?\b",
        r"\brepair(ed|s)?\b", r"\bhotfix\b"
    ],
    "Changed": [
        r"\bupdat(e|ed|ing)\b", r"\bmodif(y|ied|ying)\b",
        r"\brefactor(ed|s|ing)?\b", r"\bimprov(e|ed|ing)\b",
        r"\boptimiz(e|ed|ing)\b", r"\benhance[ds]?\b",
        r"\bupgrad(e|ed|ing)\b", r"\bredesign(ed)?\b"
    ],
    "Removed": [
        r"\bremov(e|ed|ing)\b", r"\bdelet(e|ed|ing)\b",
        r"\bdrop(ped|s)?\b", r"\bdiscard(ed)?\b",
        r"\bclean(ed|ing)?\s*(up|out)\b"
    ],
    "Deprecated": [
        r"\bdeprecate[ds]?\b", r"\bobsolete\b",
        r"\bphase[ds]?\s*out\b", r"\bsunset(ting)?\b"
    ],
    "Security": [
        r"\bsecur(e|ity)\b", r"\bvulnerab(le|ility)\b",
        r"\bCVE-\d+\b", r"\bauth(entication|orization)\b.*\b(fix|patch)\b",
        r"\bXSS\b", r"\bSQL\s*inject\b", r"\bCSRF\b"
    ]
}
```

#### Signal 2: File Path Heuristics

Analyze `git diff --name-only` or `git log --name-only` to classify by path patterns:

```python
FILE_PATH_SIGNALS = {
    "Added": [
        # Entirely new files (from git diff --diff-filter=A)
    ],
    "Removed": [
        # Deleted files (from git diff --diff-filter=D)
    ],
    "Fixed": [
        # Changes in test files alongside source files suggest bug fix
    ],
    "Changed": [
        # Default for modified existing files
    ],
    "Security": [
        r"(auth|security|crypto|ssl|tls|password|token|secret)",
        r"\.env(\.example)?$"
    ],
    "Deprecated": [],
    # Excluded from changelog (noise):
    "_skip": [
        r"^\.github/", r"^\.gitlab-ci", r"^\.gitignore$",
        r"^(README|CHANGELOG|LICENSE|CONTRIBUTING)\.",
        r"^(Makefile|Dockerfile|docker-compose)",
        r"\.(md|txt|yml|yaml|json|toml|lock)$",  # config-only changes
        r"^test(s)?/", r"^spec(s)?/",             # test-only changes
        r"^docs?/"                                  # docs-only changes
    ]
}
```

#### Signal 3: Diff Statistics

Use `git diff --stat` and `git diff --numstat` for quantitative signals:

```bash
# Get per-file insertions/deletions
git diff v1.0.0..HEAD --numstat
# Output: <insertions> <deletions> <file>
# Example: 45  3  src/auth/login.js

# Get summary
git diff v1.0.0..HEAD --shortstat
# Output: 12 files changed, 340 insertions(+), 89 deletions(-)

# Get diff filter (Added/Deleted/Modified/Renamed)
git diff v1.0.0..HEAD --diff-filter=A --name-only   # New files only
git diff v1.0.0..HEAD --diff-filter=D --name-only   # Deleted files only
git diff v1.0.0..HEAD --diff-filter=M --name-only   # Modified files only
git diff v1.0.0..HEAD --diff-filter=R --name-only   # Renamed files only
```

| Signal                                  | Suggests              |
|-----------------------------------------|-----------------------|
| New files in src/                       | **Added**             |
| Deleted files                           | **Removed**           |
| High deletion ratio (>80% deletions)    | **Removed** or **Changed** |
| Small patch (few lines)                 | **Fixed** (likely a bug fix) |
| Large changes in existing files         | **Changed**           |
| Changes only in docs/tests              | Skip (not user-facing)|
| Renamed files                           | **Changed**           |

#### Signal 4: LLM-Assisted Classification (Claude)

For ambiguous commits, the skill can use Claude (the LLM running the skill) to classify:

```
Given this commit:
  Message: "Updated the way exports work to use streaming"
  Files changed: src/export/csv.js (+120 -45), src/export/pdf.js (+89 -30)
  
Classify into one of: Added, Changed, Deprecated, Removed, Fixed, Security
Also write a human-friendly changelog entry.

Expected output:
  Category: Changed
  Entry: "Refactored export system to use streaming for CSV and PDF exports, improving performance for large datasets."
```

This is the most powerful signal — Claude can read commit messages, understand context from file names, and produce polished, human-readable entries.

### 8.3 Git Commands for Commit Collection

```bash
# ── Find the reference point (last tag or first commit) ──
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
    # No tags exist — use the root commit
    REF=$(git rev-list --max-parents=0 HEAD)
else
    REF="$LAST_TAG"
fi

# ── Collect commits since last tag ──
# Basic: one-line messages
git log ${REF}..HEAD --oneline

# Detailed: full message + files changed
git log ${REF}..HEAD --pretty=format:"%H|%s|%b|%an|%ai" --name-status

# Conventional Commits formatted output
git log ${REF}..HEAD --pretty=format:"%s"

# With file stats per commit (for diff analysis)
git log ${REF}..HEAD --pretty=format:"COMMIT:%H|%s" --numstat

# ── Merge commit handling ──
# Skip merge commits (they're noise for changelogs)
git log ${REF}..HEAD --oneline --no-merges

# OR use first-parent to follow main branch only
git log ${REF}..HEAD --oneline --first-parent

# ── PR/MR titles via merge commits (alternative approach) ──
# Extract PR numbers from merge commits for GitHub
git log ${REF}..HEAD --merges --oneline | grep -oP '#\d+'
```

### 8.4 Complete Commit Analysis Pipeline

```
┌────────────────────────────────────────────────────────────────────┐
│                   COMMIT ANALYSIS PIPELINE                         │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  1. COLLECT                                                        │
│     ├─ Find last tag: git describe --tags --abbrev=0               │
│     ├─ Get commits: git log <tag>..HEAD --no-merges                │
│     └─ Get diffs: git diff <tag>..HEAD --numstat                   │
│                                                                    │
│  2. PARSE                                                          │
│     ├─ Try Conventional Commits regex first                        │
│     ├─ If matches → direct type mapping (Section 8.1)              │
│     └─ If no match → freeform heuristic (Section 8.2)             │
│                                                                    │
│  3. CLASSIFY                                                       │
│     ├─ Combine signals: message + files + diff stats               │
│     ├─ Apply confidence scoring                                    │
│     ├─ For low-confidence → LLM classification (Signal 4)          │
│     └─ Filter out noise (docs-only, test-only, config-only)        │
│                                                                    │
│  4. GROUP                                                          │
│     ├─ Bucket into: Added/Changed/Deprecated/Removed/Fixed/Security│
│     ├─ De-duplicate similar entries                                 │
│     └─ Sort: Breaking changes first, then by category order        │
│                                                                    │
│  5. GENERATE                                                       │
│     ├─ Write human-friendly descriptions                           │
│     │   ├─ Conventional: use description directly                  │
│     │   └─ Freeform: LLM rewrites to polished entry                │
│     ├─ Add scope prefix if available: "**auth**: ..."              │
│     └─ Suggest SemVer bump based on change types                   │
│                                                                    │
│  6. OUTPUT                                                         │
│     ├─ Insert into [Unreleased] section of CHANGELOG.md            │
│     ├─ Present to user for review/approval                         │
│     └─ Optionally promote to versioned release                     │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### 8.5 Handling Edge Cases

| Edge Case                              | Strategy                                           |
|----------------------------------------|----------------------------------------------------|
| No tags exist yet                      | Use root commit as reference point                  |
| Merge commits                          | Skip with `--no-merges` (PR title from body if available) |
| Squash merges                          | Treat as single commit, use full message body       |
| Revert commits                         | Detect `revert:` or `Revert "..."` → match to original |
| Commits touching only tests/docs       | Filter out unless explicitly requested               |
| Duplicate descriptions                 | De-duplicate by normalized message similarity        |
| Commits with no message body           | Use subject line only                               |
| Mixed conventional + freeform          | Handle each commit independently                    |
| Very large commit count (100+)         | Summarize by category, not per-commit               |
| Monorepo with multiple packages        | Use scope or path-based filtering                   |

### 8.6 Example: Full Auto-Generation Flow

**Input**: Git repository with these commits since `v1.1.0`:

```
a1b2c3d feat(export): add CSV export for reports
d4e5f6a fix: resolve timeout on large dataset queries
7g8h9i0 Updated dependencies
j1k2l3m refactor: simplify database connection pooling
n4o5p6q feat!: redesign dashboard layout
         BREAKING CHANGE: widgets use CSS grid, old flex layout removed
r7s8t9u docs: add API reference for export endpoints
v1w2x3y fix(auth): patch XSS vulnerability in login form
z4a5b6c chore: update CI pipeline
```

**Output**: Generated `[Unreleased]` section:

```markdown
## [Unreleased]

### Added

- **export**: CSV export for reports.

### Changed

- **BREAKING**: Redesigned dashboard layout — widgets now use CSS grid (old flex layout removed).
- Updated project dependencies.

### Fixed

- Resolved timeout on large dataset queries.
- **auth**: Patched XSS vulnerability in login form.

### Security

- **auth**: Patched XSS vulnerability in login form.
```

**Suggested version**: `2.0.0` (MAJOR — contains breaking change)

**Skipped commits** (not user-facing):
- `refactor: simplify database connection pooling` (internal refactor)
- `docs: add API reference for export endpoints` (docs only)
- `chore: update CI pipeline` (CI/CD)

---

## 9. Updated Skill Scenarios (Complete)

### Scenario A: Create New Changelog
**Inputs**: Project name, optional repo URL, optional initial version + changes.
**Output**: `CHANGELOG.md` with boilerplate, `[Unreleased]`, optional first version.

### Scenario B: Auto-Generate Changelog from Recent Commits (PRIMARY)
**Inputs**: Git repository (current directory), optional target version.
**Steps**:
1. Find last tag (or root commit if no tags)
2. Collect all commits since last tag
3. Run commit analysis pipeline (Section 8.4)
4. Parse conventional commits; classify freeform commits via heuristics + LLM
5. Filter noise (docs, tests, CI, chores)
6. Generate human-readable entries grouped by change type
7. Suggest SemVer version based on change types detected
8. Insert into `[Unreleased]` section (or create new versioned section if version provided)
9. Present to user for review before finalizing

### Scenario C: Release a New Version
**Inputs**: Existing `CHANGELOG.md`, new version number, date, changes by type.
**Steps**:
1. Validate SemVer version > previous version
2. Move `[Unreleased]` → new version section (or accept explicit items)
3. Update footer comparison links
4. **(Git)** Create annotated tag with changelog excerpt as message
5. **(Git)** Push tag to remote
6. **(MCP/GitHub)** Create GitHub Release with body from changelog
7. **(MCP/GitLab)** Create GitLab Release with description from changelog

### Scenario D: Add Entries to `[Unreleased]` Manually
**Inputs**: Existing `CHANGELOG.md`, changes with type classification.
**Steps**: Parse, append under correct sub-headers, create missing headers as needed.

### Scenario E: Auto-Generate + Release in One Step (Full Pipeline)
**Inputs**: Git repository, target version (or auto-suggest).
**Steps**:
1. Run Scenario B (auto-generate from commits)
2. Present to user for review
3. On approval, run Scenario C (release: update changelog, tag, push, platform release)
4. This is the "one command release" workflow

### Scenario F: Retroactive Changelog from Tags
**Inputs**: Git repository with existing tags but no changelog.
**Steps**:
1. List all tags: `git tag -l --sort=-version:refname`
2. For each tag pair, get commits between them
3. Build changelog sections from commit history
4. Generate full `CHANGELOG.md`

---

## 10. Validation Rules (Complete)

| Rule                                  | Severity | Details                                                  |
|---------------------------------------|----------|----------------------------------------------------------|
| Valid SemVer format                   | Error    | Must match `MAJOR.MINOR.PATCH[-pre][+build]`            |
| ISO 8601 date                         | Error    | Must be `YYYY-MM-DD`                                    |
| Reverse chronological order           | Error    | New version must come before older versions              |
| Version greater than previous         | Error    | `1.2.0` cannot follow `1.3.0`                           |
| Only standard 6 change types          | Warning  | Added, Changed, Deprecated, Removed, Fixed, Security    |
| Breaking changes need MAJOR bump      | Warning  | If `Removed` or breaking `Changed`, suggest MAJOR bump  |
| Deprecations need at least MINOR bump | Warning  | If `Deprecated` present, at least MINOR                 |
| Tag matches version                   | Error    | Tag `v1.2.0` must match `## [1.2.0]` in changelog      |
| No duplicate versions                 | Error    | Same version cannot appear twice                        |
| Unreleased section exists             | Warning  | Should always be present at top                         |
| Git tag exists before creating release| Error    | MCP release creation requires the tag to exist          |
