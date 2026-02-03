# Claude Code Plugin Patterns, Best Practices & Standards

## Executive Summary

Analysis of 13 official Claude Code plugins reveals a highly consistent ecosystem with well-defined patterns for structure, configuration, naming, and implementation. This document captures the complete standards used across the marketplace.

---

## 1. PLUGIN ECOSYSTEM OVERVIEW

### Total Plugins: 13

**Development Workflow Plugins:**
- `commit-commands` - Git operations
- `feature-dev` - Full feature development cycle
- `code-review` - Automated PR reviews
- `pr-review-toolkit` - Specialized review aspects

**Developer Tools:**
- `agent-sdk-dev` - Agent SDK development
- `plugin-dev` - Plugin development toolkit (7 skills!)
- `hookify` - Hook creation framework

**Code Quality & Security:**
- `security-guidance` - Security warnings
- `code-review` - Quality checks

**Output Style Modifiers:**
- `explanatory-output-style` - Educational insights
- `learning-output-style` - Interactive learning
- `frontend-design` - Design guidance skill

**Migration & Upgrade:**
- `claude-opus-4-5-migration` - Model migration

**Experimental:**
- `ralph-wiggum` - Autonomous iteration loops

### Complexity Spectrum
- **Simplest**: security-guidance (1 hook, 1 Python file)
- **Simple**: frontend-design (1 skill)
- **Medium**: commit-commands (3 commands)
- **Complex**: feature-dev (1 command, 3 agents)
- **Most Complex**: hookify (4 commands, 1 agent, 1 skill, 4 hooks, Python framework)
- **Most Comprehensive**: plugin-dev (1 command, 3 agents, 7 skills)

---

## 2. STANDARD DIRECTORY STRUCTURE

### Complete Plugin Layout

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # REQUIRED - Plugin metadata
├── README.md                     # REQUIRED - User documentation
├── commands/                     # Optional - Slash commands
│   ├── main-command.md
│   └── helper-command.md
├── agents/                       # Optional - Autonomous agents
│   ├── agent-name.md
│   └── another-agent.md
├── skills/                       # Optional - Skills with progressive disclosure
│   ├── skill-name/
│   │   ├── SKILL.md             # Core skill (UPPERCASE filename)
│   │   ├── README.md            # Optional overview
│   │   ├── examples/            # Working code examples
│   │   ├── references/          # Detailed documentation
│   │   └── scripts/             # Utility scripts
│   └── another-skill/
├── hooks/                        # Optional - Event-driven automation
│   ├── hooks.json               # Hook configuration
│   ├── pretooluse.py
│   ├── posttooluse.py
│   └── stop.py
├── core/                         # Optional - Python modules
│   ├── __init__.py
│   ├── module_name.py
│   └── another_module.py
├── examples/                     # Optional - Usage examples
│   └── example-config.local.md
└── .mcp.json                    # Optional - MCP server configuration
```

### Auto-Discovery Mechanism

Claude Code automatically discovers:
- Commands in `commands/*.md`
- Agents in `agents/*.md`
- Skills in `skills/*/SKILL.md`
- Hooks in `hooks/hooks.json`
- MCP servers in `.mcp.json`

**No manual registration required** - just place files in standard locations.

---

## 3. NAMING CONVENTIONS

### Plugin Names
- **Format**: `kebab-case` (lowercase with hyphens)
- **Examples**: `feature-dev`, `plugin-dev`, `pr-review-toolkit`, `claude-opus-4-5-migration`

### File Names

| Type | Convention | Examples |
|------|-----------|----------|
| Commands | `kebab-case.md` | `feature-dev.md`, `create-plugin.md` |
| Agents | `kebab-case.md` | `code-explorer.md`, `code-architect.md` |
| Skills | Always `SKILL.md` | `SKILL.md` (in each skill directory) |
| Python Modules | `snake_case.py` | `config_loader.py`, `rule_engine.py` |
| Bash Scripts | `kebab-case.sh` | `validate-bash.sh`, `test-hook.sh` |
| Hooks | `lowercase.py` | `pretooluse.py`, `posttooluse.py`, `stop.py` |

### Python Code Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| Functions | `snake_case` | `load_rules()`, `extract_frontmatter()` |
| Classes | `PascalCase` | `RuleEngine`, `Condition`, `Rule` |
| Constants | `UPPER_SNAKE_CASE` | `PLUGIN_ROOT`, `FLAG_FILE` |
| Private methods | `_snake_case` | `_rule_matches()`, `_check_condition()` |

---

## 4. PLUGIN MANIFEST (plugin.json)

### Required Structure

**Location**: `.claude-plugin/plugin.json`

**Minimal**:
```json
{
  "name": "plugin-name"
}
```

**Standard**:
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief description of plugin functionality",
  "author": {
    "name": "Full Name",
    "email": "email@example.com"
  }
}
```

### Field Specifications

| Field | Required | Format | Example |
|-------|----------|--------|---------|
| `name` | Yes | `kebab-case` | `"feature-dev"` |
| `version` | No | Semantic versioning | `"1.0.0"` |
| `description` | No | Brief text | `"Comprehensive feature development workflow"` |
| `author.name` | No | Full name | `"Sid Bidasaria"` |
| `author.email` | No | Email address | `"sbidasaria@anthropic.com"` |

---

## 5. COMMANDS EXPORT PATTERN

### File Structure

**Location**: `commands/command-name.md`

**Format**: YAML frontmatter + Markdown content

```markdown
---
description: Brief command description shown in command list
argument-hint: Optional description of arguments (e.g., "feature description")
allowed-tools: ["Tool1", "Tool2"]  # Optional tool restrictions
---

# Command Name

[System prompt for Claude when command executes]

## Phase/Section Structure

**Goal**: What this section accomplishes

**Actions**:
1. Step one with clear instructions
2. Step two with expected outcomes
...

[Detailed procedural instructions]
```

### Frontmatter Fields

| Field | Required | Purpose | Example |
|-------|----------|---------|---------|
| `description` | Recommended | Shown in `/help` | `"Create a git commit"` |
| `argument-hint` | Optional | Describes args | `"Optional feature description"` |
| `allowed-tools` | Optional | Tool restrictions | `["Bash(git *)", "Read", "Write"]` |

### Special Variables

- `$ARGUMENTS` - Access command arguments within the prompt

### Example from commit-commands

**File**: `commands/commit.md`
```markdown
---
allowed-tools: ["Bash(git add:*)", "Bash(git status:*)", "Bash(git commit:*)"]
description: Create a git commit
---

# Git Commit

You should follow these steps carefully:

1. Run git status and git diff commands in parallel
2. Analyze all staged changes and draft a commit message
3. Add relevant files and create the commit
...
```

---

## 6. AGENTS EXPORT PATTERN

### File Structure

**Location**: `agents/agent-name.md`

**Format**: YAML frontmatter + System prompt

```markdown
---
name: agent-identifier
description: Use this agent when the user asks to "action phrase", "verb phrase", or describes [scenario]. Trigger when [conditions]. Examples:

<example>
Context: [Situation description]
user: "[User message]"
assistant: "[Response before triggering]"
<commentary>
[Why agent should trigger]
</commentary>
</example>

[More examples demonstrating triggering scenarios...]

model: inherit|sonnet|haiku|opus
color: blue|green|yellow|red|magenta|cyan
tools: ["Tool1", "Tool2"]  # Optional, omit for all tools
---

You are [expert persona]. Your expertise lies in [domain].

When [trigger condition], you will:

1. **Step One**: Description of action
2. **Step Two**: Description of action
...

[Detailed instructions, methodologies, quality standards]
```

### Frontmatter Fields

| Field | Required | Format | Purpose |
|-------|----------|--------|---------|
| `name` | Yes | `kebab-case`, 3-50 chars | Agent identifier |
| `description` | Yes | Text with `<example>` blocks | When to trigger, with concrete examples |
| `model` | No | `inherit`/`sonnet`/`haiku`/`opus` | Model selection (default: `inherit`) |
| `color` | No | Color name | UI indicator for agent status |
| `tools` | No | Array of tool names | Restrict available tools (omit for all) |

### Description Best Practices

**Pattern**: "Use this agent when..." + specific trigger phrases + inline examples

**Example from code-explorer**:
```yaml
description: Deeply analyzes existing codebase features by tracing execution paths, mapping architecture layers, understanding patterns and abstractions, and documenting dependencies to inform new development
```

**Example with inline examples from comment-analyzer**:
```yaml
description: Use this agent when you need to analyze code comments for accuracy, completeness, and long-term maintainability. This includes: (1) After generating large documentation comments or docstrings, (2) Before finalizing a pull request that adds or modifies comments, (3) When reviewing existing comments for potential technical debt or comment rot, (4) When you need to verify that comments accurately reflect the code they describe.\n\n<example>\nContext: The user is working on a pull request that adds several documentation comments to functions.\nuser: "I've added documentation to these functions. Can you check if the comments are accurate?"\nassistant: "I'll use the comment-analyzer agent to thoroughly review all the comments in this pull request for accuracy and completeness."\n<commentary>\nSince the user has added documentation comments and wants them checked, use the comment-analyzer agent to verify their accuracy against the actual code.\n</commentary>\n</example>
```

### Semantic Color Coding

| Color | Common Usage |
|-------|--------------|
| `blue` | Analysis, exploration, research |
| `green` | Creation, generation, building |
| `yellow` | Validation, review, testing |
| `red` | Security, critical operations |
| `magenta` | Meta/architectural work |
| `cyan` | Utilities, helpers |

---

## 7. SKILLS EXPORT PATTERN

### Progressive Disclosure Architecture

Skills use a **three-level progressive disclosure pattern**:

1. **Level 1: Metadata** (always loaded) - 100-200 words
2. **Level 2: Core Skill** (loaded when triggered) - 1,500-2,000 words
3. **Level 3: Bundled Resources** (loaded as needed) - unlimited depth

### Directory Structure

```
skills/skill-name/
├── SKILL.md                      # Core skill definition (UPPERCASE)
├── README.md                      # Optional overview
├── examples/                      # Working code examples
│   ├── example1.sh
│   └── example2.py
├── references/                    # Deep-dive documentation
│   ├── advanced-patterns.md
│   ├── migration-guide.md
│   └── api-reference.md
└── scripts/                       # Utility scripts
    ├── validate.sh
    └── test.sh
```

### SKILL.md Format

**Location**: `skills/skill-name/SKILL.md`

```markdown
---
name: Skill Name
description: This skill should be used when the user asks to "trigger phrase 1", "mentions keyword X", "wants to do Y", or "describes scenario Z". Provides [comprehensive description of capabilities].
version: 0.1.0
---

# Skill Name for Claude Code Plugins

## Overview

High-level explanation of what the skill covers and why it exists.

**Key capabilities:**
- Bullet list of main features
- What you can accomplish with this skill
- When to apply it

## [Core Content Sections]

Comprehensive technical documentation organized by topic:
- Conceptual explanations
- API references
- Code examples inline
- Configuration patterns
- Common workflows
- Best practices
- Troubleshooting

## Quick Reference

Tables and summaries for rapid lookup.

## Additional Resources

### Reference Files
- [Advanced Patterns](references/advanced-patterns.md)
- [Migration Guide](references/migration-guide.md)

### Example Files
- [Example 1](examples/example1.sh) - Description
- [Example 2](examples/example2.py) - Description

### Utility Scripts
- [Validation Script](scripts/validate.sh) - Schema validator
- [Test Script](scripts/test.sh) - Functional tests
```

### Frontmatter Best Practices

**name**: Human-readable title (can use spaces, Title Case)

**description**:
- **Format**: "This skill should be used when the user..."
- **Include**: Multiple specific trigger phrases in quotes
- **Examples**: "create a skill", "add a skill", "improve skill description"
- **Third person**: Not "I will help you" but "This skill provides"

**version**: Semantic versioning (0.1.0, 1.0.0, etc.)

### Content Guidelines

- **Target length**: 1,500-2,000 words for core SKILL.md
- **Voice**: Imperative/infinitive form (not second person)
- **Structure**: Clear sections with headings
- **Code examples**: Inline with syntax highlighting
- **Links**: Reference bundled resources for depth

---

## 8. HOOKS EXPORT PATTERN

### Configuration File

**Location**: `hooks/hooks.json`

**Structure**:
```json
{
  "description": "Optional description of hook functionality",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [...],
    "Stop": [...],
    "SessionStart": [...],
    "UserPromptSubmit": [...]
  }
}
```

### Hook Types

**Available Event Types:**
- `PreToolUse` - Before any tool executes
- `PostToolUse` - After tool completes
- `Stop` - When user stops Claude
- `SubagentStop` - When subagent stops
- `SessionStart` - When session begins
- `SessionEnd` - When session ends
- `UserPromptSubmit` - Before user prompt sent
- `PreCompact` - Before conversation compaction
- `Notification` - System notifications

### Hook Entry Structure

| Field | Required | Format | Purpose |
|-------|----------|--------|---------|
| `matcher` | No | Regex pattern | Filter by tool name (PreToolUse/PostToolUse) |
| `type` | Yes | `"command"` or `"prompt"` | Hook execution type |
| `command` | Yes (command) | Shell command | Script to execute |
| `timeout` | No | Number (seconds) | Max execution time (default: 10, max: 600) |

### Environment Variables

**${CLAUDE_PLUGIN_ROOT}**: Absolute path to plugin directory
- **ALWAYS use** for portability
- Expands at runtime
- Example: `python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py`

### Hook Script Pattern (Python)

**Location**: `hooks/pretooluse.py`

```python
#!/usr/bin/env python3
"""PreToolUse hook executor.

This script is called by Claude Code before any tool executes.
"""

import os
import sys
import json

# CRITICAL: Add plugin root to Python path for imports
PLUGIN_ROOT = os.environ.get('CLAUDE_PLUGIN_ROOT')
if PLUGIN_ROOT:
    parent_dir = os.path.dirname(PLUGIN_ROOT)
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)

try:
    from plugin_name.core.module import function
except ImportError as e:
    error_msg = {"systemMessage": f"Import error: {e}"}
    print(json.dumps(error_msg), file=sys.stdout)
    sys.exit(0)

def main():
    """Main entry point for hook."""
    try:
        # Read input from stdin (JSON)
        input_data = json.load(sys.stdin)

        # Process hook logic
        result = process_logic(input_data)

        # Always output JSON to stdout
        print(json.dumps(result), file=sys.stdout)

    except Exception as e:
        # On error, allow operation and log
        error_output = {"systemMessage": f"Hook error: {str(e)}"}
        print(json.dumps(error_output), file=sys.stdout)
    finally:
        # ALWAYS exit 0 - never block due to hook errors
        sys.exit(0)

if __name__ == '__main__':
    main()
```

### Hook Input/Output

**Input** (via stdin):
```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.py",
    "content": "..."
  }
}
```

**Output** (to stdout):
```json
{
  "decision": "allow" | "block",
  "reason": "Optional explanation",
  "systemMessage": "Message shown to Claude (can be multi-line)"
}
```

### Hook Script Pattern (Bash)

**Location**: `hooks/stop-hook.sh`

```bash
#!/bin/bash
set -euo pipefail

# Read input from stdin (for stop hooks, may be empty)
INPUT=$(cat)

# Process logic
# ...

# Output JSON
echo '{"decision": "allow", "systemMessage": "Hook message"}' >&2

# Always exit 0
exit 0
```

### Critical Hook Standards

1. **Always exit 0** - Never block operations due to hook errors
2. **JSON output** - stdout must be valid JSON
3. **Use ${CLAUDE_PLUGIN_ROOT}** - For portable paths
4. **Graceful error handling** - Catch all exceptions
5. **Timeout awareness** - Default 10s, respect limits
6. **Input validation** - Check all fields before use

---

## 9. PYTHON CODE STANDARDS

### Module Organization

**Package structure**:
```
plugin-name/
├── core/
│   ├── __init__.py              # Empty or exports
│   ├── config_loader.py         # Configuration loading
│   └── rule_engine.py           # Business logic
└── hooks/
    ├── pretooluse.py            # Hook entry point
    └── posttooluse.py           # Hook entry point
```

### Import Patterns

**Relative imports within package**:
```python
from plugin_name.core.config_loader import load_rules
from plugin_name.core.rule_engine import RuleEngine
```

**Hook script path setup**:
```python
import os
import sys

# Add plugin to path
PLUGIN_ROOT = os.environ.get('CLAUDE_PLUGIN_ROOT')
if PLUGIN_ROOT:
    parent_dir = os.path.dirname(PLUGIN_ROOT)
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)
```

### Type Hints (Python 3.7+)

**Use consistently**:
```python
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field

@dataclass
class Condition:
    """A single matching condition."""
    field: str
    operator: str
    pattern: str

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Condition':
        """Create from dictionary."""
        return cls(
            field=data.get('field', ''),
            operator=data.get('operator', 'regex_match'),
            pattern=data.get('pattern', '')
        )

def load_rules(event: Optional[str] = None) -> List[Rule]:
    """Load all rules from .claude directory.

    Args:
        event: Optional event filter

    Returns:
        List of enabled Rule objects
    """
    pass
```

### Dataclasses Pattern

**Use for configuration objects**:
```python
from dataclasses import dataclass, field

@dataclass
class Rule:
    """A plugin rule configuration."""
    name: str
    enabled: bool
    event: str
    pattern: Optional[str] = None
    conditions: List[Condition] = field(default_factory=list)
    action: str = "warn"
    message: str = ""
```

### Error Handling

**Specific exception handling**:
```python
def load_rules(event: Optional[str] = None) -> List[Rule]:
    """Load rules with graceful error handling."""
    rules = []
    for file_path in files:
        try:
            rule = load_rule_file(file_path)
            if rule and rule.enabled:
                rules.append(rule)
        except (IOError, OSError, PermissionError) as e:
            # Graceful degradation
            print(f"Warning: Failed to read {file_path}: {e}", file=sys.stderr)
            continue
        except (ValueError, KeyError, AttributeError, TypeError) as e:
            print(f"Warning: Failed to parse {file_path}: {e}", file=sys.stderr)
            continue
    return rules
```

**Key principles**:
- Catch specific exceptions (not bare `except`)
- Graceful degradation (continue on error)
- Informative messages to stderr
- Return empty/default values rather than raising

### Input Validation

**Type checking and conversion**:
```python
def _extract_field(self, field: str, data: Dict[str, Any]) -> Optional[str]:
    """Extract field with type validation."""
    if field in data:
        value = data[field]
        if isinstance(value, str):
            return value
        return str(value)  # Convert non-strings
    return None  # Explicit None for missing
```

**Security validation**:
```python
# Validate inputs
if not re.match(r'^[a-zA-Z0-9_-]+$', plugin_name):
    raise ValueError("Invalid plugin name")

# Check path traversal
if '..' in file_path or file_path.startswith('/'):
    raise ValueError("Invalid file path")

# Sanitize regex patterns
try:
    compiled = re.compile(pattern)
except re.error as e:
    print(f"Invalid regex: {e}", file=sys.stderr)
    return False
```

### Caching for Performance

**Use functools.lru_cache**:
```python
from functools import lru_cache

@lru_cache(maxsize=128)
def compile_regex(pattern: str) -> re.Pattern:
    """Compile regex with caching for performance."""
    return re.compile(pattern, re.IGNORECASE | re.MULTILINE)
```

### Docstrings

**Google-style format**:
```python
def load_rules(event: Optional[str] = None) -> List[Rule]:
    """Load all plugin rules from .claude directory.

    Searches for .claude/plugin-name.*.local.md files and parses
    them into Rule objects. Only enabled rules are returned.

    Args:
        event: Optional event filter (e.g., "bash", "file", "stop").
               If provided, only rules matching this event are returned.

    Returns:
        List of enabled Rule objects matching the event filter.

    Raises:
        IOError: If .claude directory is not accessible.

    Example:
        >>> rules = load_rules(event="bash")
        >>> for rule in rules:
        ...     print(rule.name)
    """
    pass
```

### Private Methods

**Prefix with underscore**:
```python
class RuleEngine:
    def evaluate_rules(self, rules: List[Rule]) -> Dict[str, Any]:
        """Public API method."""
        pass

    def _rule_matches(self, rule: Rule, data: Dict) -> bool:
        """Private helper method."""
        pass

    def _check_condition(self, condition: Condition) -> bool:
        """Private validation method."""
        pass
```

---

## 10. BASH SCRIPT STANDARDS

### Strict Mode

**Always use**:
```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

### Quoting Variables

**Quote all variables**:
```bash
# Good
echo "$file_path"
cd "$CLAUDE_PROJECT_DIR"
command "$arg1" "$arg2"

# Bad
echo $file_path
cd $CLAUDE_PROJECT_DIR
command $arg1 $arg2
```

### JSON Output for Hooks

**Use JSON format**:
```bash
#!/bin/bash
set -euo pipefail

# Output JSON to stdout
echo '{"decision": "allow", "reason": "Validation passed"}' >&2

exit 0
```

### Input Validation

**Check arguments**:
```bash
#!/bin/bash
set -euo pipefail

# Usage check
if [ $# -lt 1 ]; then
  echo "Usage: $0 <file-path>" >&2
  exit 1
fi

FILE_PATH="$1"

# Validate file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH" >&2
  exit 1
fi
```

### Using jq for JSON

**JSON validation and parsing**:
```bash
#!/bin/bash
set -euo pipefail

HOOKS_FILE="$1"

# Validate JSON syntax
if ! jq empty "$HOOKS_FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax" >&2
  exit 1
fi

# Extract values
HOOK_TYPE=$(jq -r '.hooks.PreToolUse[0].hooks[0].type' "$HOOKS_FILE")
TIMEOUT=$(jq -r '.hooks.PreToolUse[0].hooks[0].timeout // 10' "$HOOKS_FILE")

echo "Hook type: $HOOK_TYPE, Timeout: $TIMEOUT"
```

### Validation Script Pattern

**Location**: `skills/*/scripts/validate-*.sh`

```bash
#!/bin/bash
# Validates configuration file format and structure

set -euo pipefail

# Input validation
if [ $# -eq 0 ]; then
  echo "Usage: $0 <config-file>" >&2
  exit 1
fi

CONFIG_FILE="$1"

echo "🔍 Validating: $CONFIG_FILE"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ File not found" >&2
  exit 1
fi

# Validation checks
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax" >&2
  exit 1
fi

# Field validations
# ...

echo "✅ Validation passed"
exit 0
```

---

## 11. DOCUMENTATION STANDARDS

### README.md Structure

**Standard sections**:

```markdown
# Plugin Name

Brief one-line description of what the plugin does.

## Overview

2-3 paragraphs explaining:
- What the plugin does
- Why it exists
- Key benefits

## Features

### Feature 1: Name

Description and usage.

### Feature 2: Name

Description and usage.

## Installation

```bash
# From Claude Code marketplace
claude-code plugins install plugin-name
```

## Quick Start

Step-by-step getting started guide with examples.

## Usage

Detailed usage instructions with:
- Command examples
- Configuration options
- Workflow examples

## Configuration

How to configure the plugin (if applicable).

## Examples

Real-world usage examples.

## Best Practices

Recommendations for effective use.

## Troubleshooting

Common issues and solutions.

## Requirements

- Any dependencies
- Minimum versions
- Prerequisites

## Author

Name <email@example.com>

## Version

1.0.0
```

### Markdown Formatting Standards

**Headers**:
- H1 (`#`) for plugin name only
- H2 (`##`) for major sections
- H3 (`###`) for subsections
- H4 (`####`) for details

**Code blocks**:
```markdown
```bash
command --arg value
```

```python
def function():
    pass
```

```json
{
  "key": "value"
}
```
```

**Emphasis**:
- **Bold** for important concepts
- *Italic* for emphasis
- `code` for inline code

**Lists**:
```markdown
- Unordered list item
- Another item
  - Nested item

1. Ordered list item
2. Another item
   1. Nested item
```

---

## 12. TESTING & VALIDATION PATTERNS

### Validation Script Organization

**Location**: `skills/*/scripts/validate-*.sh`

**Purpose**: Validate configuration files, schemas, and formats

**Example**:
```bash
#!/bin/bash
# validate-hook-schema.sh
# Validates hooks.json format and structure

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <hooks.json>" >&2
  exit 1
fi

HOOKS_FILE="$1"

echo "🔍 Validating hooks configuration: $HOOKS_FILE"

# JSON syntax
if ! jq empty "$HOOKS_FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax" >&2
  exit 1
fi

# Required fields
if ! jq -e '.hooks' "$HOOKS_FILE" >/dev/null; then
  echo "❌ Missing 'hooks' field" >&2
  exit 1
fi

# Hook types
for hook_type in $(jq -r '.. | .type? | select(.)' "$HOOKS_FILE"); do
  if [ "$hook_type" != "command" ] && [ "$hook_type" != "prompt" ]; then
    echo "❌ Invalid type '$hook_type'" >&2
    exit 1
  fi
done

# Timeout ranges
for timeout in $(jq -r '.. | .timeout? | select(.)' "$HOOKS_FILE"); do
  if [ "$timeout" -lt 1 ] || [ "$timeout" -gt 600 ]; then
    echo "⚠️  Timeout $timeout outside recommended range (1-600s)" >&2
  fi
done

# Check for ${CLAUDE_PLUGIN_ROOT}
if grep -q '"command":.*"/' "$HOOKS_FILE" | grep -qv '\${CLAUDE_PLUGIN_ROOT}'; then
  echo "⚠️  Hardcoded paths detected. Use \${CLAUDE_PLUGIN_ROOT}" >&2
fi

echo "✅ Validation passed"
exit 0
```

### Test Script Organization

**Location**: `skills/*/scripts/test-*.sh`

**Purpose**: Functional testing of hooks and scripts

**Example**:
```bash
#!/bin/bash
# test-hook.sh
# Functional test for hook scripts

set -euo pipefail

HOOK_SCRIPT="$1"
TEST_INPUT="$2"

echo "🧪 Testing hook: $HOOK_SCRIPT"

# Run hook with test input
OUTPUT=$(echo "$TEST_INPUT" | "$HOOK_SCRIPT")

# Validate output is JSON
if ! echo "$OUTPUT" | jq empty 2>/dev/null; then
  echo "❌ Hook output is not valid JSON" >&2
  exit 1
fi

# Check required fields
if ! echo "$OUTPUT" | jq -e '.decision' >/dev/null; then
  echo "❌ Missing 'decision' field in output" >&2
  exit 1
fi

echo "✅ Test passed"
exit 0
```

### Python Test Pattern

**In-module testing** (main guard):
```python
#!/usr/bin/env python3
"""Module with built-in tests."""

def function(arg: str) -> str:
    """Main function."""
    return arg.upper()

if __name__ == '__main__':
    """Run tests when module executed directly."""
    import sys

    # Test cases
    assert function("hello") == "HELLO"
    assert function("") == ""

    print("✅ All tests passed", file=sys.stderr)
    sys.exit(0)
```

---

## 13. CONFIGURATION PATTERNS

### Plugin Settings (.local.md files)

**Location**: `.claude/plugin-name.*.local.md`

**Format**: YAML frontmatter + Markdown body

**Example**: `.claude/hookify.dangerous-rm.local.md`
```markdown
---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf\s+(/|~|\$HOME)
action: block
---

⚠️ **Dangerous rm command detected!**

This command could delete important files. Please:
- Verify the path is correct
- Consider using a safer approach
- Make sure you have backups

If you're sure, you can:
1. Disable this rule temporarily
2. Use a more specific path
```

### Frontmatter Parsing

**Extract YAML and Markdown separately**:

**Bash**:
```bash
# Extract YAML frontmatter between --- delimiters
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$FILE")
NAME=$(echo "$FRONTMATTER" | grep '^name:' | sed 's/name: *//')

# Extract markdown body (after closing ---)
BODY=$(awk '/^---$/{i++; next} i>=2' "$FILE")
```

**Python**:
```python
import re
import yaml

def parse_local_file(file_path: str) -> tuple[dict, str]:
    """Parse .local.md file into frontmatter dict and body."""
    with open(file_path, 'r') as f:
        content = f.read()

    # Extract frontmatter
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)$', content, re.DOTALL)
    if not match:
        raise ValueError("Invalid frontmatter format")

    frontmatter_yaml = match.group(1)
    body = match.group(2)

    frontmatter = yaml.safe_load(frontmatter_yaml)

    return frontmatter, body
```

### Environment Variables

**Standard Claude Code variables**:

| Variable | Description | Example |
|----------|-------------|---------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin | `/Users/x/.claude/plugins/.../plugin-name` |
| `$CLAUDE_PROJECT_DIR` | Current project directory | `/Users/x/project` |
| `$CLAUDE_HOME` | Claude home directory | `/Users/x/.claude` |

**Usage in hooks.json**:
```json
{
  "type": "command",
  "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py"
}
```

**Usage in bash scripts**:
```bash
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
```

**Usage in Python**:
```python
import os

PLUGIN_ROOT = os.environ.get('CLAUDE_PLUGIN_ROOT')
PROJECT_DIR = os.environ.get('CLAUDE_PROJECT_DIR')
```

---

## 14. SECURITY BEST PRACTICES

### Input Validation

**Path validation**:
```python
def validate_path(file_path: str) -> bool:
    """Validate file path for security."""
    # Check path traversal
    if '..' in file_path:
        return False

    # Check absolute paths (if not allowed)
    if file_path.startswith('/'):
        return False

    # Check for null bytes
    if '\x00' in file_path:
        return False

    return True
```

**Pattern validation**:
```python
def validate_regex(pattern: str) -> bool:
    """Validate regex pattern."""
    try:
        re.compile(pattern)
        return True
    except re.error as e:
        print(f"Invalid regex: {e}", file=sys.stderr)
        return False
```

**Command validation**:
```python
def validate_command(command: str) -> bool:
    """Validate shell command for dangerous patterns."""
    dangerous_patterns = [
        r'rm\s+-rf\s+/',
        r':\(\)\{.*\}',  # Fork bomb
        r'>\s*/dev/sd',  # Disk write
    ]

    for pattern in dangerous_patterns:
        if re.search(pattern, command):
            return False

    return True
```

### Error Handling

**Never expose sensitive info**:
```python
try:
    result = process_sensitive_data()
except Exception as e:
    # Bad: Exposes internals
    # error_msg = f"Failed: {str(e)}"

    # Good: Generic message
    error_msg = "Processing failed. Check logs for details."
    print(error_msg, file=sys.stderr)
```

**Always exit gracefully**:
```python
def main():
    try:
        result = process()
        print(json.dumps(result))
    except Exception as e:
        # Log error but allow operation
        error = {"systemMessage": f"Error: {e}"}
        print(json.dumps(error))
    finally:
        # NEVER block operations
        sys.exit(0)
```

### Hook Safety

**Critical rules**:
1. **Always exit 0** - Never fail operations due to hook errors
2. **Timeout awareness** - Respect timeout limits (default: 10s, max: 600s)
3. **Graceful degradation** - If hook fails, allow the operation
4. **No destructive actions** - Hooks should only warn/block, not modify

**Example**:
```python
def main():
    try:
        # Process hook logic
        if should_block():
            result = {"decision": "block", "reason": "Dangerous operation"}
        else:
            result = {"decision": "allow"}

        print(json.dumps(result))
    except Exception:
        # On any error, allow the operation
        print(json.dumps({"decision": "allow"}))
    finally:
        sys.exit(0)  # Always exit 0
```

---

## 15. PROGRESSIVE DISCLOSURE PATTERN

### Skill Content Organization

**Core principle**: Information revealed progressively as needed

**Level 1: Metadata (100-200 words)**
- Always loaded
- Triggers skill activation
- Includes: name, description, version

**Level 2: Core Content (1,500-2,000 words)**
- Loaded when skill triggered
- Essential concepts and workflows
- Links to deeper resources

**Level 3: Bundled Resources (unlimited)**
- Loaded on demand when referenced
- Deep dives, examples, scripts

### Example Structure

**SKILL.md** (1,800 words):
```markdown
---
name: Hook Development
description: This skill should be used when...
version: 0.1.0
---

# Hook Development for Claude Code

## Overview
Essential concepts about hooks...

## Core Workflows
Basic hook patterns...

## Quick Reference
Tables and summaries...

## Additional Resources
- [Advanced Patterns](references/advanced.md) - 3,000 words
- [Examples](examples/) - Working code
```

**references/advanced.md** (3,000+ words):
```markdown
# Advanced Hook Patterns

## Complex Scenarios
Detailed explanations...

## Performance Optimization
In-depth techniques...

## Architecture Patterns
...
```

**examples/validate-write.sh**:
```bash
#!/bin/bash
# Working example of file validation hook
# ...
```

### Content Distribution

| Location | Purpose | Size | Load Time |
|----------|---------|------|-----------|
| Frontmatter | Triggering | 100-200 words | Always |
| SKILL.md body | Core concepts | 1,500-2,000 words | On trigger |
| references/*.md | Deep dives | 2,000-5,000 words | On reference |
| examples/* | Working code | Any size | On reference |
| scripts/* | Utilities | Any size | On execution |

---

## 16. VERSION CONTROL PATTERNS

### .gitignore

**For Python plugins** (from hookify):
```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Plugin specific
*.local.md  # User configurations
```

### Commit Message Standards

**Format**: Not explicitly defined, but common patterns:
```
Add agent for code review

- Implement code-reviewer agent with quality checks
- Add examples for triggering scenarios
- Include validation for common issues
```

**Types**:
- `Add` - New features
- `Fix` - Bug fixes
- `Update` - Improvements to existing features
- `Remove` - Deletions
- `Refactor` - Code restructuring

---

## 17. COMPLETE EXAMPLES

### Example 1: Simple Plugin (Single Skill)

**Structure**:
```
frontend-design/
├── .claude-plugin/
│   └── plugin.json
├── README.md
└── skills/
    └── frontend-design/
        └── SKILL.md
```

**plugin.json**:
```json
{
  "name": "frontend-design",
  "version": "1.0.0",
  "description": "Production-grade frontend interface creation guidance",
  "author": {
    "name": "Author Name",
    "email": "author@anthropic.com"
  }
}
```

### Example 2: Medium Plugin (Commands + Agents)

**Structure**:
```
feature-dev/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── commands/
│   └── feature-dev.md
└── agents/
    ├── code-explorer.md
    ├── code-architect.md
    └── code-reviewer.md
```

### Example 3: Complex Plugin (Full Stack)

**Structure**:
```
hookify/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── .gitignore
├── commands/
│   ├── hookify.md
│   ├── list.md
│   ├── configure.md
│   └── delete.md
├── agents/
│   └── conversation-analyzer.md
├── skills/
│   └── writing-rules/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json
│   ├── pretooluse.py
│   ├── posttooluse.py
│   ├── stop.py
│   └── userpromptsubmit.py
├── core/
│   ├── __init__.py
│   ├── config_loader.py
│   └── rule_engine.py
├── matchers/
│   └── pattern_matcher.py
└── examples/
    ├── dangerous-rm.local.md
    └── console-log-warning.local.md
```

---

## 18. QUALITY CHECKLIST

### Before Publishing Plugin

**Required**:
- [ ] `.claude-plugin/plugin.json` exists with valid name
- [ ] `README.md` with overview and usage instructions
- [ ] All commands have valid frontmatter
- [ ] All agents have name, description with examples
- [ ] All skills have triggering phrases in description
- [ ] Hooks always exit 0
- [ ] All paths use `${CLAUDE_PLUGIN_ROOT}`

**Recommended**:
- [ ] Semantic versioning in plugin.json
- [ ] Author information in plugin.json
- [ ] Validation scripts for complex configurations
- [ ] Examples for non-obvious use cases
- [ ] Troubleshooting section in README
- [ ] Type hints in all Python code
- [ ] Docstrings for public functions
- [ ] Error messages to stderr, not stdout

**Best Practices**:
- [ ] Progressive disclosure for skills (1,500-2,000 word core)
- [ ] Semantic color coding for agents
- [ ] Input validation in hooks
- [ ] Caching for expensive operations
- [ ] Security validation (path traversal, injection)
- [ ] Graceful error handling (continue on error)
- [ ] Clear examples in agent descriptions
- [ ] Tool restrictions where appropriate

---

## 19. COMMON PATTERNS SUMMARY

### File Organization
- Commands: `commands/*.md`
- Agents: `agents/*.md`
- Skills: `skills/*/SKILL.md`
- Hooks: `hooks/hooks.json` + `hooks/*.py`
- Core logic: `core/*.py`

### Naming
- Plugins: `kebab-case`
- Files: `kebab-case.ext`
- Skills: `SKILL.md` (uppercase)
- Python: `snake_case` functions, `PascalCase` classes
- Constants: `UPPER_SNAKE_CASE`

### Configuration
- YAML frontmatter for metadata
- Markdown body for content
- JSON for structured config (plugin.json, hooks.json)
- `${CLAUDE_PLUGIN_ROOT}` for paths

### Code Quality
- Python: Type hints, docstrings, dataclasses
- Bash: `set -euo pipefail`, quote variables
- Hooks: Always exit 0, JSON output, error handling
- Security: Input validation, path checking, sanitization

### Documentation
- Third-person for skill descriptions
- Imperative for skill content
- Examples with context for agent triggers
- Progressive disclosure (1,500-2,000 word core)

---

## 20. REFERENCES TO ACTUAL IMPLEMENTATIONS

### Best Plugin Examples

**For learning plugin structure**:
- `plugin-dev` - 7 comprehensive skills covering all aspects
- `feature-dev` - Well-organized command + agents workflow
- `hookify` - Full-stack Python implementation

**For specific patterns**:
- **Simple plugin**: `frontend-design` (1 skill)
- **Commands**: `commit-commands` (git workflow)
- **Agents**: `pr-review-toolkit` (6 specialized agents)
- **Hooks**: `security-guidance` (Python hook), `ralph-wiggum` (Bash hook)
- **Python modules**: `hookify` (dataclasses, type hints, error handling)
- **Progressive disclosure**: `plugin-dev/skills/*` (references, examples, scripts)

### File Locations for Reference

**Plugin manifests**:
- `feature-dev/.claude-plugin/plugin.json`
- `hookify/.claude-plugin/plugin.json`

**Command examples**:
- `feature-dev/commands/feature-dev.md`
- `commit-commands/commands/commit.md`

**Agent examples**:
- `feature-dev/agents/code-explorer.md`
- `pr-review-toolkit/agents/comment-analyzer.md`

**Skill examples**:
- `plugin-dev/skills/skill-development/SKILL.md`
- `plugin-dev/skills/hook-development/SKILL.md`

**Hook examples**:
- `hookify/hooks/pretooluse.py` (Python)
- `ralph-wiggum/hooks/stop-hook.sh` (Bash)

**Python modules**:
- `hookify/core/config_loader.py`
- `hookify/core/rule_engine.py`

**Validation scripts**:
- `plugin-dev/skills/hook-development/scripts/validate-hook-schema.sh`
- `plugin-dev/skills/agent-development/scripts/validate-agent.sh`

---

## CONCLUSION

The Claude Code plugin ecosystem demonstrates exceptional consistency in:
- **Structure**: Auto-discovery directories with standard layouts
- **Naming**: kebab-case for files, snake_case for Python, clear conventions
- **Configuration**: YAML frontmatter + Markdown, JSON for structured data
- **Code Quality**: Type hints, error handling, validation, security
- **Documentation**: Progressive disclosure, third-person triggers, examples
- **Portability**: ${CLAUDE_PLUGIN_ROOT}, environment variables, relative paths

This standardization enables rapid plugin development while maintaining high quality and security standards across the marketplace.
