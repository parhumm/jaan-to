# Building a Production-Ready PR/MR Code Review Skill

**The automated code review landscape has matured significantly, with clear industry consensus on optimal approaches.** Research from Google, Microsoft, and SmartBear establishes that code reviews work best when PRs stay under 400 lines, reviews last 30-60 minutes maximum, and automated tools handle style checking so humans focus on design and security. The emerging standard for structured feedback—Conventional Comments—provides machine-parsable labels that distinguish blocking issues from optional suggestions, reducing review friction by 50%+ in teams that adopt it.

This research document provides the complete technical foundation for building a GitLab-primary, GitHub-secondary PR review skill targeting PHP/Laravel and TypeScript/React codebases, covering input parsing, risk scoring, security detection, output formatting, and AI integration patterns.

---

## 1. Industry standards establish clear review effectiveness thresholds

The SmartBear/Cisco study—the largest code review study ever conducted with 2,500 reviews across 3.2 million lines—established definitive benchmarks that should inform the skill's design decisions.

### Optimal review parameters

| Metric | Recommended Value | Evidence |
|--------|------------------|----------|
| **PR size** | 100-300 LOC (max 400) | Defect detection drops **70%** beyond 400 LOC |
| **Review duration** | 30-60 minutes | Effectiveness degrades after 60-90 minutes |
| **Review rate** | 300-500 LOC/hour | Reviews >1,500 LOC/hour classified as "pass-through" |
| **Optimal reviewers** | 2 | Diminishing returns beyond two reviewers |
| **Defect detection** | 70-90% at optimal size | Drops to <30% for oversized PRs |

Google's engineering practices establish a three-part approval system: correctness verification (LGTM), code owner approval (OWNERS file), and readability approval for language-specific standards. The skill should flag when PRs exceed size thresholds and recommend splitting.

### The review pyramid prioritizes concerns correctly

Code reviews should follow a priority hierarchy, spending decreasing time as you move up the pyramid:

1. **API Semantics** — Public contracts, backwards compatibility
2. **Implementation Semantics** — Correctness, edge cases, error handling, performance
3. **Documentation** — Sufficient, accurate, up-to-date
4. **Tests** — Coverage, edge cases, test design
5. **Code Style** — Formatting, naming (automate this entirely)

**Critical insight**: 75% of defects found in code reviews affect evolvability and maintainability, not functional bugs. Less than 15% directly relate to bugs. This means the skill should emphasize design and architectural feedback over bug-hunting, which testing handles better.

### Conventional Comments specification

The skill should output findings using Conventional Comments format, which provides machine-parsable structure:

```
<label> [decorations]: <subject>

[discussion]
```

**Standard labels with severity mapping:**

| Label | Purpose | Default Blocking |
|-------|---------|-----------------|
| `issue` | Problems requiring fixes | Yes |
| `suggestion` | Proposed improvements | No |
| `question` | Clarification needed | No |
| `nitpick` | Minor stylistic concerns | No |
| `praise` | Positive acknowledgment | N/A |
| `chore` | Required housekeeping tasks | Yes |

**Decorations** modify behavior: `(blocking)`, `(non-blocking)`, `(security)`, `(if-minor)`. Example output:

```
issue (blocking, security): SQL injection vulnerability via string interpolation

suggestion (non-blocking): Consider extracting this logic into a service class for better testability
```

---

## 2. Risk-based review techniques maximize defect detection

The skill must implement intelligent file prioritization since not all changes carry equal risk. Research shows risk-based prioritization boosts fault detection by **30%** over random review order.

### File risk scoring algorithm

Implement a weighted scoring system combining multiple factors:

```typescript
interface FileRiskScore {
  changeScore: number;     // 0-10 based on lines changed
  criticalityScore: number; // 0-10 based on file type/path
  historicalScore: number;  // 0-10 based on past defect density
  authorScore: number;      // 0-10 based on author experience (optional)
  totalRisk: number;        // Weighted combination
}

const RISK_WEIGHTS = {
  change: 0.3,
  criticality: 0.4,
  historical: 0.2,
  author: 0.1
};

const CRITICALITY_PATTERNS = {
  CRITICAL: { patterns: ['auth/*', '**/security/*', '*credential*', '*.env*'], score: 10 },
  HIGH: { patterns: ['**/api/*', '**/payment/*', '*migration*', '*.sql'], score: 8 },
  MEDIUM: { patterns: ['*config*', 'Dockerfile', '*.yaml', '*.yml'], score: 5 },
  LOW: { patterns: ['*.md', '**/docs/*', '*.test.*', '*.spec.*'], score: 2 },
  SKIP: { patterns: ['*.lock', '*.min.js', 'dist/*', 'build/*'], score: 0 }
};
```

### Security-focused review requires explicit focus

Research from UC Berkeley found that explicitly asking reviewers to focus on security increases vulnerability detection probability **8x**. The skill should:

1. Apply OWASP Top 10 patterns to identify security-relevant changes
2. Elevate security findings to `issue (blocking, security)` status
3. Group security findings in a dedicated section with remediation guidance
4. Flag files in authentication, authorization, and cryptography paths for mandatory security review

---

## 3. Input transformation requires robust diff parsing

The skill must transform unified diff format into structured review data. The unified diff format follows this structure:

```
diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,4 @@
 Line 1
-Line 2
+Line 2 modified
 Line 3
+Line 4
```

### Diff parsing algorithm

```typescript
interface ParsedDiff {
  files: FileChange[];
  stats: { additions: number; deletions: number; filesChanged: number };
}

interface FileChange {
  path: string;
  oldPath?: string;
  status: 'added' | 'modified' | 'deleted' | 'renamed';
  language: string;
  riskCategory: RiskCategory;
  hunks: Hunk[];
}

interface Hunk {
  oldStart: number;
  oldCount: number;
  newStart: number;
  newCount: number;
  changes: LineChange[];
}

interface LineChange {
  type: 'add' | 'remove' | 'context';
  oldLineNumber?: number;
  newLineNumber?: number;
  content: string;
}
```

**Recommended parsing libraries:**
- **JavaScript**: `diff2html`, `jsdiff` (with `parsePatch()`)
- **Python**: `whatthepatch`, `unidiff`
- **Go**: `github.com/codepawfect/git-diff-parser`

### Extended diff headers to handle

```
new file mode <mode>
deleted file mode <mode>
rename from <path>
rename to <path>
similarity index <number>
Binary files a/path and b/path differ
```

Binary files should be logged but not content-reviewed. Renamed files should be tracked to avoid treating them as delete + add operations.

---

## 4. Output structure should prioritize actionability

Research across CodeRabbit, Sourcery, Danger.js, and other tools reveals a consistent pattern for effective review output structure.

### Recommended review pack structure (6 sections)

```markdown
# 🔍 MR Review: [Title]

## Executive Summary
| Metric | Value |
|--------|-------|
| Files Changed | 12 |
| Lines Added | +234 |
| Lines Removed | -89 |
| Risk Level | 🟠 Medium |
| Blocking Issues | 2 |

## 🔴 Critical Issues (Blocking)
[Security vulnerabilities, breaking changes, data integrity risks]

## 🟠 Risky Files Analysis
[Files ranked by risk score with specific concerns]

## 🔒 Security Hints
[OWASP patterns, secrets detection, authorization gaps]

## ⚡ Performance Hints
[N+1 queries, missing indexes, bundle size concerns]

## 🧪 Missing Test Coverage
[Source files without corresponding tests]

## 🔧 CI/CD Failure Analysis
[Pipeline failures correlated to changed files]

## 💡 Suggestions (Non-blocking)
[Refactoring ideas, code quality improvements]
```

### Severity classification system

Adopt a 4-level system that maps to Conventional Comments:

| Level | Visual | Label | Blocking | Examples |
|-------|--------|-------|----------|----------|
| Critical | 🔴 | `issue (blocking)` | Yes | SQL injection, hardcoded secrets, auth bypass |
| Warning | 🟠 | `issue` or `suggestion (blocking)` | Conditional | Missing tests, performance regressions |
| Info | 🟡 | `suggestion` | No | Refactoring opportunities, style improvements |
| Note | 🔵 | `nitpick` | No | Documentation gaps, naming preferences |

### SARIF output for machine interoperability

For integration with CI/CD systems and security dashboards, provide SARIF (Static Analysis Results Interchange Format) output:

```json
{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [{
    "tool": {
      "driver": {
        "name": "dev:pr-review",
        "version": "1.0.0",
        "rules": [{
          "id": "SEC001",
          "name": "SQLInjection",
          "shortDescription": { "text": "Potential SQL Injection" },
          "defaultConfiguration": { "level": "error" }
        }]
      }
    },
    "results": [{
      "ruleId": "SEC001",
      "level": "error",
      "message": { "text": "User input directly interpolated into SQL query" },
      "locations": [{
        "physicalLocation": {
          "artifactLocation": { "uri": "src/api/users.php" },
          "region": { "startLine": 45, "startColumn": 5 }
        }
      }]
    }]
  }]
}
```

---

## 5. PHP/Laravel security patterns for detection

### Critical anti-patterns to detect

**SQL Injection via DB::raw():**
```php
// ❌ VULNERABLE
User::whereRaw('email = "'.$request->input('email').'"')->get();
DB::table('users')->whereRaw('email = "'.$request->input('email').'"')->get();

// ✅ SECURE
User::whereRaw('email = ?', [$request->input('email')])->get();
```

**Detection regex:** `whereRaw\s*\(\s*['"][^'"]*\$(?!.*\?)`

**Mass Assignment:**
```php
// ❌ VULNERABLE
protected $guarded = [];
$request->user()->forceFill($request->all())->save();

// ✅ SECURE
protected $fillable = ['name', 'email'];
$request->user()->fill($request->validated())->save();
```

**Detection regex:** `\$guarded\s*=\s*\[\s*\]` and `->forceFill\s*\(\s*\$request->all\(\)`

**XSS in Blade Templates:**
```blade
{{-- ❌ VULNERABLE --}}
{!! $userInput !!}

{{-- ✅ SECURE --}}
{{ $userInput }}
```

**Detection regex:** `\{!!\s*\$.*!!\}`

**Missing Authorization:**
```php
// ❌ VULNERABLE - No authorization check
public function show(Post $post) {
    return view('posts.show', compact('post'));
}

// ✅ SECURE
public function show(Post $post) {
    $this->authorize('view', $post);
    return view('posts.show', compact('post'));
}
```

**Command Injection:**
```php
// ❌ VULNERABLE
exec('whois '.$request->input('domain'));

// ✅ SECURE
exec('whois '.escapeshellarg($request->input('domain')));
```

**Detection regex:** `(exec|shell_exec|system|passthru)\s*\(\s*[^)]*\$`

### N+1 Query Detection

The skill should flag relationship access patterns that suggest N+1 issues:

```php
// ❌ PROBLEM - N+1 queries
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name;  // Query per iteration
}

// ✅ SOLUTION
$posts = Post::with('author')->get();
```

**Laravel configuration for runtime detection:**
```php
// AppServiceProvider.php
Model::preventLazyLoading(!app()->isProduction());
```

### PHPStan/Larastan configuration

```neon
includes:
    - vendor/larastan/larastan/extension.neon
    - vendor/spaze/phpstan-disallowed-calls/disallowed-dangerous-calls.neon
    - vendor/spaze/phpstan-disallowed-calls/disallowed-execution-calls.neon

parameters:
    paths:
        - app/
    level: 5
    checkModelProperties: true
```

### Test file matching conventions

| Source File | Test File |
|------------|-----------|
| `app/Models/User.php` | `tests/Unit/Models/UserTest.php` |
| `app/Http/Controllers/PostController.php` | `tests/Feature/Http/Controllers/PostControllerTest.php` |
| `app/Services/PaymentService.php` | `tests/Unit/Services/PaymentServiceTest.php` |

---

## 6. TypeScript/React security patterns for detection

### Critical anti-patterns to detect

**XSS via dangerouslySetInnerHTML:**
```typescript
// ❌ VULNERABLE
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ SECURE
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

**useEffect dependency problems:**
```typescript
// ❌ VULNERABLE - Missing dependency causes stale closure
useEffect(() => {
  console.log(`Count: ${count}`);
}, []);  // count missing

// ❌ VULNERABLE - Object reference causes infinite loop
useEffect(() => {
  // Some logic
}, [{ type: "blog" }]);  // New object every render

// ✅ SECURE
useEffect(() => {
  console.log(`Count: ${count}`);
}, [count]);
```

**Memory leaks from unmounted state updates:**
```typescript
// ❌ VULNERABLE
useEffect(() => {
  fetch('/api/data').then(res => res.json()).then(setData);
}, []);

// ✅ SECURE - AbortController cleanup
useEffect(() => {
  const controller = new AbortController();
  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(setData)
    .catch(err => { if (err.name !== 'AbortError') throw err; });
  return () => controller.abort();
}, []);
```

**Type safety bypasses:**
```typescript
// ❌ VULNERABLE - Defeats TypeScript's purpose
const data: any = response.body;
// @ts-ignore
const user = data.user;

// ✅ SECURE - Runtime validation
import { z } from 'zod';
const UserSchema = z.object({ name: z.string(), email: z.string().email() });
const user = UserSchema.parse(response.body);
```

**localStorage security issues:**
```typescript
// ❌ VULNERABLE - Accessible via XSS
localStorage.setItem('authToken', token);

// ✅ SECURE - HttpOnly cookies (server-side)
// Or store in memory (React state/context)
```

### ESLint security configuration

```javascript
module.exports = {
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended-type-checked",
    "plugin:react-hooks/recommended",
    "plugin:security/recommended"
  ],
  rules: {
    "no-eval": "error",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "react/no-danger": "warn",
    "react-hooks/exhaustive-deps": "warn"
  }
};
```

### Test file matching conventions

| Source File | Test File |
|------------|-----------|
| `src/components/Button.tsx` | `src/components/Button.test.tsx` or `__tests__/components/Button.test.tsx` |
| `src/utils/validation.ts` | `src/utils/validation.spec.ts` |
| `src/hooks/useAuth.ts` | `src/hooks/useAuth.test.ts` |

---

## 7. Secrets detection patterns

The skill must detect hardcoded secrets using entropy analysis combined with pattern matching.

### High-confidence secret patterns

```toml
# AWS Credentials
[[rules]]
id = "aws-access-key"
regex = '''(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}'''

[[rules]]
id = "aws-secret-key"
regex = '''(?i)aws(.{0,20})?(?-i)['"][0-9a-zA-Z\/+]{40}['"]'''

# JWT Tokens
[[rules]]
id = "jwt-token"
regex = '''eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'''

# Generic API Keys
[[rules]]
id = "generic-api-key"
regex = '''(?i)((api|app|auth|access)[-_]?(key|token|secret))\s*[=:]\s*['"][a-zA-Z0-9_\-]{16,}['"]'''
entropy = 3.5

# Database Passwords
[[rules]]
id = "database-password"
regex = '''(?i)db[_-]?pass(word)?[\"'`\s]*[=:][\"'`\s]*[A-Za-z0-9@#$%^&*!]{8,}'''

# Platform-Specific
[[rules]]
id = "github-token"
regex = '''ghp_[0-9a-zA-Z]{36}'''

[[rules]]
id = "gitlab-token"
regex = '''glpat-[0-9a-zA-Z_\-]{20}'''

[[rules]]
id = "stripe-secret"
regex = '''sk_(test|live)_[A-Za-z0-9]{24,}'''

[[rules]]
id = "slack-token"
regex = '''xox[baprs]-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9-]*'''
```

### False positive reduction

Implement allowlists for common false positive patterns:

```toml
[allowlist]
regexes = [
    '''(?i)test[_-]?(key|token|secret)''',
    '''(?i)(fake|dummy|example|placeholder)[_-]?(key|token)''',
    '''[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}''',  # UUIDs
]
paths = [
    '''test/.*''',
    '''\.github/.*''',
    '''docs/.*'''
]
stopwords = ["test", "fake", "example", "dummy", "placeholder"]
```

---

## 8. Edge cases require explicit handling strategies

### Very large PRs (500+ files)

When PRs exceed 500 files or 2,000 lines:

1. **Warn about review effectiveness**: Research shows 70% reduction in defect detection
2. **Chunk processing**: Review high-risk files first, batch remaining files
3. **Recommend splitting**: Provide guidance on logical split points
4. **Apply tiered depth**: Deep review for critical files, surface scan for generated files

```typescript
function handleLargePR(files: FileChange[], maxBatch = 100) {
  const critical = files.filter(f => isHighRisk(f));
  const standard = files.filter(f => !isHighRisk(f) && !isGenerated(f));
  const generated = files.filter(f => isGenerated(f));
  
  return {
    review: [
      ...reviewBatch(critical, { depth: 'deep' }),
      ...reviewBatch(standard, { depth: 'standard' }),
    ],
    skipped: { generated: generated.length },
    warning: `PR contains ${files.length} files. Consider splitting for more effective review.`
  };
}
```

### Files to skip or handle specially

| Category | Patterns | Action |
|----------|----------|--------|
| Binary | `*.png`, `*.pdf`, `*.woff2` | Log as "binary changed", no content review |
| Generated | `*.lock`, `*.min.js`, `dist/*` | Auto-collapse, version consistency check only |
| Lockfiles | `package-lock.json`, `composer.lock` | Check for dependency audit issues only |
| Vendor | `vendor/*`, `node_modules/*` | Skip entirely |

**Use .gitattributes for generated file detection:**
```gitattributes
*.lock linguist-generated=true -diff
*.min.js linguist-generated=true -diff
dist/* linguist-generated=true
```

### Draft/WIP MRs

```typescript
function shouldReview(mr: MergeRequest): ReviewConfig {
  if (mr.draft || mr.title.match(/^\[WIP\]|^WIP:/i)) {
    return {
      review: 'limited',
      actions: ['lint', 'syntax-check', 'secrets-scan'],
      skip: ['deep-review', 'performance-analysis'],
      message: '📝 Limited review for draft MR. Full review when marked ready.'
    };
  }
  return { review: 'full' };
}
```

### Deletion-only PRs

Flag for careful human review:
- Code removal can hide security issues (removing validation, removing auth checks)
- Check for orphaned references (imports, tests, documentation)
- Verify test coverage isn't silently reduced

---

## 9. GitLab MR API integration

### Key endpoints for the skill

**Retrieve MR diff:**
```bash
GET /api/v4/projects/:id/merge_requests/:merge_request_iid/diffs
```

**Post review comment (inline on code):**
```bash
POST /api/v4/projects/:id/merge_requests/:merge_request_iid/discussions

{
  "body": "issue (blocking, security): SQL injection vulnerability...",
  "position": {
    "position_type": "text",
    "base_sha": "<base_commit>",
    "start_sha": "<start_commit>",
    "head_sha": "<head_commit>",
    "new_path": "src/api/users.php",
    "new_line": 45
  }
}
```

**Post summary comment:**
```bash
POST /api/v4/projects/:id/merge_requests/:merge_request_iid/notes

{
  "body": "## 🔍 Automated Review Summary\n\n..."
}
```

**Get pipeline status:**
```bash
GET /api/v4/projects/:id/merge_requests/:merge_request_iid/pipelines
```

### GitLab CI integration

```yaml
automated-review:
  stage: review
  image: node:20
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script:
    - npm ci
    - node scripts/pr-review.js
  variables:
    GITLAB_TOKEN: $REVIEW_BOT_TOKEN
  artifacts:
    reports:
      codequality: gl-code-quality-report.json
```

**Key CI variables:**
- `CI_MERGE_REQUEST_IID` — MR internal ID
- `CI_MERGE_REQUEST_DIFF_BASE_SHA` — Base commit for diff
- `CI_PROJECT_ID` — Project identifier
- `CI_API_V4_URL` — API base URL

---

## 10. AI-specific considerations for LLM-based review

### Current LLM performance benchmarks

Research from SWR-Bench (2025) and ByteDance's ContextCRBench shows:

- LLMs are **better at detecting functional errors** (bugs, logic) than non-functional issues (documentation, style)
- Multi-review aggregation can boost F1 scores by **up to 43.67%**
- **Textual context (PR descriptions, issue links) provides greater performance boost than code context alone**
- Current LLMs "still fall short of requirements for reliable, automated code review" — human validation remains essential

### Common LLM failure modes

| Failure Mode | Description | Mitigation |
|--------------|-------------|------------|
| **Hallucinated line numbers** | References non-existent lines | Validate all line references against actual diff |
| **Incorrect severity** | Flags minor issues as critical | Apply rules-based severity classification |
| **Missing context** | Misses cross-file impacts | Include related files in context |
| **False security positives** | Flags test data as real secrets | Apply path-based filtering |
| **Overconfidence** | Presents uncertain suggestions confidently | Require confidence scoring |

### Prompt engineering patterns

**Effective prompt structure:**
```
You are reviewing code changes for a PHP/Laravel and TypeScript/React application.

## Context
- PR Title: {title}
- PR Description: {description}
- Changed files: {file_list}

## Your Task
Review the following diff for:
1. Security vulnerabilities (SQL injection, XSS, authentication issues)
2. Performance problems (N+1 queries, missing indexes)
3. Missing test coverage
4. Code quality issues

## Output Format
Use Conventional Comments format:
- `issue (blocking, security):` for security problems
- `issue (blocking):` for bugs
- `suggestion:` for improvements
- `nitpick:` for minor style issues

## Diff
{diff_content}
```

**Key principles:**
- Lower temperature (0.3-0.5) reduces hallucination
- Provide explicit output format with examples
- Include PR description and issue context — often more valuable than additional code
- Break large diffs into logical chunks at function/class boundaries
- Request confidence levels for uncertain findings

### Context window strategies for large diffs

For diffs exceeding context limits (~100k tokens):

1. **Prioritize by risk**: Review high-risk files first with full context
2. **Chunk at logical boundaries**: Split at function/class definitions, not arbitrary line counts
3. **Map-reduce for summaries**: Summarize each file section, then synthesize
4. **Include expanded context**: For each hunk, include 5-10 lines of surrounding code

### Human-in-the-loop validation points

**Always require human validation for:**
- Security findings (especially authorization logic)
- Architectural change suggestions
- Business logic assessments
- Cross-repository impacts

**Confidence-based escalation:**
- High confidence (>90%): Include in automated summary
- Medium confidence (70-90%): Mark as "suggested" with lower severity
- Low confidence (<70%): Flag for human review or exclude

---

## 11. Example Dangerfile configurations

### Comprehensive Dangerfile.ts for polyglot codebase

```typescript
import { danger, warn, fail, message, markdown } from 'danger';

// === PR Size Checks ===
const additions = danger.github.pr.additions;
const deletions = danger.github.pr.deletions;
const totalChanges = additions + deletions;

if (totalChanges > 500) {
  warn(`🐘 Large PR detected (${totalChanges} lines). Consider splitting for more effective review.`);
}
if (totalChanges > 1000) {
  fail(`❌ PR exceeds 1000 lines. Please split into smaller PRs for reviewability.`);
}

// === Missing Description ===
if (!danger.github.pr.body || danger.github.pr.body.length < 50) {
  warn('📝 Please provide a meaningful PR description explaining the changes.');
}

// === Test Coverage Check ===
const phpFiles = danger.git.modified_files.filter(f => f.endsWith('.php') && !f.includes('Test.php'));
const phpTestFiles = danger.git.modified_files.filter(f => f.includes('Test.php'));
const tsFiles = danger.git.modified_files.filter(f => f.match(/\.(ts|tsx)$/) && !f.match(/\.(test|spec)\./));
const tsTestFiles = danger.git.modified_files.filter(f => f.match(/\.(test|spec)\.(ts|tsx)$/));

if (phpFiles.length > 0 && phpTestFiles.length === 0) {
  warn('🧪 PHP source files changed without corresponding tests.');
}
if (tsFiles.length > 0 && tsTestFiles.length === 0) {
  warn('🧪 TypeScript source files changed without corresponding tests.');
}

// === Security-Sensitive Files ===
const securityFiles = danger.git.modified_files.filter(f => 
  f.includes('auth') || f.includes('security') || f.includes('password') ||
  f.includes('middleware') || f.includes('Policy')
);
if (securityFiles.length > 0) {
  warn(`🔒 Security-sensitive files modified: ${securityFiles.join(', ')}. Ensure thorough security review.`);
}

// === Lockfile Consistency ===
const packageChanged = danger.git.modified_files.includes('package.json');
const lockfileChanged = danger.git.modified_files.includes('package-lock.json') || 
                        danger.git.modified_files.includes('yarn.lock');
if (packageChanged && !lockfileChanged) {
  fail('📦 package.json changed but lockfile not updated. Run `npm install` or `yarn`.');
}

const composerChanged = danger.git.modified_files.includes('composer.json');
const composerLockChanged = danger.git.modified_files.includes('composer.lock');
if (composerChanged && !composerLockChanged) {
  fail('📦 composer.json changed but composer.lock not updated. Run `composer update`.');
}

// === Migration Safety ===
const migrations = danger.git.modified_files.filter(f => f.includes('migration'));
if (migrations.length > 0) {
  warn('🗄️ Database migrations detected. Ensure backwards compatibility and rollback plan.');
}

// === Draft PR ===
if (danger.github.pr.title.includes('[WIP]') || danger.github.pr.title.includes('WIP:')) {
  message('📝 This PR is marked as work-in-progress. Limited automated review applied.');
}

// === Summary ===
markdown(`
## 📊 PR Stats
| Metric | Value |
|--------|-------|
| Files Changed | ${danger.git.modified_files.length} |
| Additions | +${additions} |
| Deletions | -${deletions} |
`);
```

---

## 12. Quality checklist for the skill

### Comment quality requirements

Every automated review comment must be:

- [ ] **Actionable**: Includes specific code suggestion or clear next step
- [ ] **Located**: Points to exact file and line number
- [ ] **Labeled**: Uses Conventional Comments format
- [ ] **Severity-appropriate**: Critical issues marked blocking, style issues marked non-blocking
- [ ] **Explained**: Includes "why" not just "what" — links to relevant documentation or security advisory

### False positive prevention

- [ ] Secrets detection excludes test files and example configs
- [ ] Security patterns validated against allowlists
- [ ] Entropy thresholds tuned to reduce noise (recommend 3.5+)
- [ ] Path-based rules prevent flagging documentation examples

### Output completeness

- [ ] Executive summary with key metrics
- [ ] All blocking issues clearly identified
- [ ] Security findings grouped separately
- [ ] Missing test coverage reported
- [ ] CI failure correlation attempted
- [ ] Non-blocking suggestions provided but de-emphasized

---

## 13. Template recommendation for review pack output

```markdown
# 🔍 Automated Review: MR !{mr_iid}

## Executive Summary

| Metric | Value |
|--------|-------|
| **Risk Level** | {risk_emoji} {risk_level} |
| **Files Changed** | {files_count} |
| **Lines** | +{additions} / -{deletions} |
| **Blocking Issues** | {blocking_count} |
| **Suggestions** | {suggestion_count} |

{#if blocking_count > 0}
⚠️ **This MR has blocking issues that must be resolved before merge.**
{/if}

---

## 🔴 Blocking Issues ({blocking_count})

{#each blocking_issues as issue}
### {issue.title}
📁 `{issue.file}` | Line {issue.line}

```{issue.language}
{issue.code_snippet}
```

**{issue.label}:** {issue.message}

**Suggested Fix:**
```{issue.language}
{issue.fix_snippet}
```

---
{/each}

## 🔒 Security Analysis

{#if security_findings.length > 0}
{#each security_findings as finding}
- **{finding.severity}**: {finding.description} (`{finding.file}:{finding.line}`)
{/each}
{else}
✅ No security issues detected in changed code.
{/if}

## ⚡ Performance Hints

{#each performance_hints as hint}
- {hint.description} (`{hint.file}`)
{/each}

## 🧪 Test Coverage

{#if missing_tests.length > 0}
The following source files lack corresponding tests:
{#each missing_tests as file}
- `{file.source}` → Expected: `{file.expected_test}`
{/each}
{else}
✅ All changed source files have corresponding tests.
{/if}

## 🔧 CI Status

{#if ci_failures.length > 0}
Pipeline failures detected:
{#each ci_failures as failure}
- **{failure.job}**: {failure.error} (likely related to `{failure.attributed_file}`)
{/each}
{else}
✅ All CI checks passing.
{/if}

## 💡 Suggestions ({suggestion_count})

{#each suggestions as suggestion}
**{suggestion.label}:** {suggestion.message}
📁 `{suggestion.file}:{suggestion.line}`

{/each}

---

*Generated by dev:pr-review • {timestamp}*
```

---

## 14. Tool integration specifications

### Required integrations

| Tool | Purpose | Integration Method |
|------|---------|-------------------|
| **GitLab API** | Post comments, retrieve diffs | REST API v4 |
| **GitHub API** | Secondary platform support | REST API / GraphQL |
| **Semgrep** | SAST for PHP/TypeScript | CLI with SARIF output |
| **Gitleaks** | Secrets detection | CLI with JSON output |
| **PHPStan** | PHP static analysis | CLI with JSON output |
| **ESLint** | TypeScript linting | CLI with JSON output |
| **npm audit** | JS dependency vulnerabilities | CLI with JSON output |
| **composer audit** | PHP dependency vulnerabilities | CLI with JSON output |

### Semgrep rule configuration

```yaml
# .semgrep.yml
rules:
  # PHP/Laravel
  - id: laravel-sql-injection
    patterns:
      - pattern-either:
          - pattern: DB::raw($REQUEST)
          - pattern: whereRaw("..." . $REQUEST . "...")
    message: "SQL injection via raw query with user input"
    severity: ERROR
    languages: [php]
    
  - id: laravel-mass-assignment
    pattern: $guarded = [];
    message: "Empty $guarded allows mass assignment to all properties"
    severity: ERROR
    languages: [php]
    
  # TypeScript/React
  - id: react-dangerouslysetinnerhtml
    pattern: dangerouslySetInnerHTML={{ __html: $X }}
    message: "Potential XSS via dangerouslySetInnerHTML"
    severity: WARNING
    languages: [typescript, javascript]
```

---

## Conclusion

Building a production-ready PR review skill requires combining multiple complementary approaches: **risk-based file prioritization** ensures limited review time focuses on high-impact changes, **pattern-based security detection** catches known vulnerability patterns with high precision, and **structured output using Conventional Comments** makes feedback actionable and machine-parsable.

The key insight from this research is that automated review should augment, not replace, human judgment. The skill should handle the mechanical aspects—style checking, known security patterns, test coverage verification—freeing human reviewers to focus on design decisions, business logic correctness, and subtle security implications that require context beyond the diff.

For GitLab-primary deployment with PHP/Laravel and TypeScript/React codebases, prioritize:

1. **Robust diff parsing** with proper handling of renames, binaries, and generated files
2. **Risk scoring algorithm** that surfaces authentication, authorization, and payment code first
3. **Language-specific security patterns** from this document's PHP and TypeScript sections
4. **Conventional Comments output** for both machine parsing and human readability
5. **SARIF export** for integration with security dashboards and CI quality gates
6. **LLM integration with guardrails** — validate line numbers, apply rules-based severity, require confidence scoring

The review pack template and Dangerfile configurations provided can serve as starting points, adapted to the specific codebase conventions and team preferences.