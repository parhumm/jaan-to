# Validation Utilities

Reference guide for validating plugin components using standard tools.

---

## Validating hooks.json

### Basic JSON Syntax

```bash
# Validate JSON is well-formed
jq empty hooks/hooks.json

# If valid, exits 0
# If invalid, shows error
```

### Required Fields

```bash
# Check for 'hooks' top-level field
jq -e '.hooks' hooks/hooks.json >/dev/null
echo $?  # Should be 0
```

### Hook Type Validation

```bash
# Verify all hooks have valid 'type' field (command or prompt)
for hook_type in $(jq -r '.. | .type? | select(.)' hooks/hooks.json); do
  if [ "$hook_type" != "command" ] && [ "$hook_type" != "prompt" ]; then
    echo "❌ Invalid type '$hook_type'"
    exit 1
  fi
done
echo "✅ All hook types valid"
```

### Timeout Validation

```bash
# Check timeout ranges (should be 1-600 seconds)
for timeout in $(jq -r '.. | .timeout? | select(.)' hooks/hooks.json); do
  if [ "$timeout" -lt 1 ] || [ "$timeout" -gt 600 ]; then
    echo "⚠️  Timeout $timeout outside recommended range (1-600s)"
  fi
done
```

### Portability Check

```bash
# Ensure hooks use ${CLAUDE_PLUGIN_ROOT} not hardcoded paths
if grep -q '"command":.*"/' hooks/hooks.json | grep -qv '${CLAUDE_PLUGIN_ROOT}'; then
  echo "⚠️  Hardcoded paths detected. Use \${CLAUDE_PLUGIN_ROOT}"
else
  echo "✅ All paths use \${CLAUDE_PLUGIN_ROOT}"
fi
```

---

## Validating Agent Frontmatter

### Extract Frontmatter

```bash
# Extract YAML frontmatter from agent markdown file
sed -n '/^---$/,/^---$/{ /^---$/d; p; }' agents/quality-reviewer.md
```

### Required Fields

Agent frontmatter must have:
- `name` (string)
- `description` (string with <example> blocks recommended)

Optional fields:
- `model` (inherit, sonnet, haiku, opus)
- `color` (blue, green, yellow, red, magenta, cyan)
- `tools` (array of tool names)

### Check for Non-Standard Fields

According to official plugin patterns, avoid custom fields like `capabilities`. If you need to document agent capabilities, include them in the `description` or system prompt.

**Example validation:**

```bash
# Check if agent has non-standard 'capabilities' field
if grep -q '^capabilities:' agents/*.md; then
  echo "⚠️  Non-standard 'capabilities' field found"
  echo "    Move to description or system prompt"
fi
```

---

## Complete Hook Validation Script

Save as `scripts/validate-hooks.sh`:

```bash
#!/bin/bash
set -euo pipefail

HOOKS_FILE="${1:-hooks/hooks.json}"

echo "🔍 Validating: $HOOKS_FILE"

# 1. JSON syntax
if ! jq empty "$HOOKS_FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax"
  exit 1
fi

# 2. Required fields
if ! jq -e '.hooks' "$HOOKS_FILE" >/dev/null; then
  echo "❌ Missing 'hooks' field"
  exit 1
fi

# 3. Hook types
for hook_type in $(jq -r '.. | .type? | select(.)' "$HOOKS_FILE"); do
  if [ "$hook_type" != "command" ] && [ "$hook_type" != "prompt" ]; then
    echo "❌ Invalid type '$hook_type'"
    exit 1
  fi
done

# 4. Timeout ranges
for timeout in $(jq -r '.. | .timeout? | select(.)' "$HOOKS_FILE"); do
  if [ "$timeout" -lt 1 ] || [ "$timeout" -gt 600 ]; then
    echo "⚠️  Timeout $timeout outside range (1-600s)"
  fi
done

# 5. Portability
if grep -q '"command":.*"/' "$HOOKS_FILE" | grep -qv '${CLAUDE_PLUGIN_ROOT}'; then
  echo "⚠️  Hardcoded paths detected"
fi

echo "✅ Validation passed"
```

Usage:
```bash
chmod +x scripts/validate-hooks.sh
./scripts/validate-hooks.sh hooks/hooks.json
```

---

## Agent Validation

Save as `scripts/validate-agent.sh`:

```bash
#!/bin/bash
set -euo pipefail

AGENT_FILE="$1"

echo "🔍 Validating agent: $AGENT_FILE"

# Extract frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$AGENT_FILE")

# Check required fields
if ! echo "$FRONTMATTER" | grep -q '^name:'; then
  echo "❌ Missing 'name' field"
  exit 1
fi

if ! echo "$FRONTMATTER" | grep -q '^description:'; then
  echo "❌ Missing 'description' field"
  exit 1
fi

# Check for non-standard fields
if echo "$FRONTMATTER" | grep -q '^capabilities:'; then
  echo "⚠️  Non-standard 'capabilities' field found"
  echo "    Move to description or system prompt"
fi

# Check for <example> blocks in description
if ! grep -q '<example>' "$AGENT_FILE"; then
  echo "⚠️  No <example> blocks found in description"
  echo "    Official plugins use examples for triggering scenarios"
fi

echo "✅ Validation passed"
```

Usage:
```bash
chmod +x scripts/validate-agent.sh
./scripts/validate-agent.sh agents/quality-reviewer.md
```

---

## Best Practices Checklist

### Hooks
- [ ] JSON is well-formed
- [ ] All hooks have `type: "command"` or `type: "prompt"`
- [ ] Timeouts are in seconds (not milliseconds)
- [ ] All paths use `${CLAUDE_PLUGIN_ROOT}`
- [ ] Hook scripts always exit 0 (never block operations)

### Agents
- [ ] Frontmatter has `name` and `description`
- [ ] Description includes <example> blocks with trigger scenarios
- [ ] No non-standard fields (like `capabilities`)
- [ ] Model choice is appropriate (haiku for cost-sensitive operations)
- [ ] Tools array limits to minimum necessary

### Skills
- [ ] SKILL.md has YAML frontmatter with `name` and `description`
- [ ] Description uses third-person voice
- [ ] Description includes specific trigger phrases
- [ ] Body is 1,500-2,000 words (core content)
- [ ] References to bundled resources for deeper content

---

## Resources

- [Official Claude Code Plugin Patterns Research](../outputs/research/57-ai-workflow-claude-code-plugin-patterns-best-practices-standards.md)
- [Hook Development Skill](../../skills/hook-development/SKILL.md) *(if available in plugin-dev)*
- [Agent Development Skill](../../skills/agent-development/SKILL.md) *(if available in plugin-dev)*

---

**Last Updated:** 2026-02-03
