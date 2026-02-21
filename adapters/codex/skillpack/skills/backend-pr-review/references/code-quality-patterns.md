# Code Quality Patterns -- Backend PR Review

> Reference file for backend-pr-review skill. Loaded on demand during Step 4.
> Organized by: Universal Patterns (always loaded) + per-stack sections (loaded by anchor).

---

## Universal Patterns

### Missing Error Handling

```bash
# Broad exception catches that swallow errors
grep -rn 'catch\s*(\s*\(Exception\|Error\|\\\Throwable\|Exception\)\s*)' {files}
grep -rn 'catch\s*{' {files}
grep -rn 'except:\s*$\|except\s\+Exception' {files}
```

**Flag**: Empty catch blocks, overly broad exception types, missing error logging.

### Dead Code

```bash
# Commented-out code blocks (not documentation comments)
grep -rn '^\s*//\s*\(function\|class\|def\|fn\|pub\|private\|protected\|public\|return\|if\|for\|while\)' {files}
# Unreachable code after return/throw/exit
grep -rn 'return.*\n\s*[a-zA-Z]' {files}
```

### TODO/FIXME in Production Code

```bash
grep -rn 'TODO\|FIXME\|HACK\|XXX\|TEMP' {files}
```

**Severity**: INFO -- worth noting but not blocking.

### Hardcoded Configuration

```bash
# Hardcoded URLs, ports, hostnames
grep -rn 'localhost\|127\.0\.0\.1\|0\.0\.0\.0' {files}
grep -rn ':\(3000\|3306\|5432\|6379\|8080\|8443\|27017\)' {files}
```

### Missing Logging on Error Paths

```bash
# Error handling without logging
grep -rn 'catch\|except\|Err(' {files}
# Check if error handlers include logging calls
grep -rn 'log\.\|logger\.\|Log::\|logging\.' {files}
```

---

## Test File Conventions

Used to detect when new source files lack corresponding tests.

| Stack Key | Source Pattern | Test Pattern |
|-----------|--------------|-------------|
| `php-laravel` | `app/Http/Controllers/{Name}Controller.php` | `tests/Feature/{Name}Test.php`, `tests/Unit/{Name}Test.php` |
| `php-laravel` | `app/Services/{Name}.php` | `tests/Unit/Services/{Name}Test.php` |
| `node-ts` | `src/{path}/{name}.ts` | `src/{path}/{name}.test.ts`, `src/{path}/{name}.spec.ts`, `__tests__/{name}.test.ts` |
| `python-django` | `{app}/views.py`, `{app}/models.py` | `{app}/tests/test_views.py`, `{app}/tests/test_models.py` |
| `go` | `{package}/{name}.go` | `{package}/{name}_test.go` |
| `rust` | `src/{name}.rs` | `src/{name}.rs` (inline `#[cfg(test)]` module), `tests/{name}.rs` |

**Detection rule**: If a new controller, service, or handler file is added in the diff but no corresponding test file is in the diff, flag as WARNING.

---

## php-laravel

### Naming Convention Violations

```bash
# Controllers should be PascalCase + Controller suffix
grep -rn 'class\s\+[a-z].*Controller' {files}

# Form requests should be PascalCase + Request suffix
grep -rn 'class\s\+[a-z].*Request' {files}

# Methods should be camelCase
grep -rn 'function\s\+[A-Z]' {files}
```

### Anti-Patterns

```bash
# Business logic in controllers (should be in services/actions)
# Flag controllers with more than ~50 lines per method

# Using env() outside config files
grep -rn 'env(' {files}
# env() should only appear in config/*.php files, not in app code

# Missing FormRequest validation
grep -rn '\$request->input\|\$request->get\|\$request->query' {files}
# Should use validated() from FormRequest instead of direct access
```

### Migration Safety

```bash
# Destructive operations without down() method
grep -rn 'dropColumn\|dropTable\|drop(' {files}
grep -rn 'function\s\+down' {files}
# Migrations must implement down()

# Float for currency (should be unsignedDecimal)
grep -rn 'float\|double' {files}

# Missing indexes on foreign keys
grep -rn 'foreignId\|foreign(' {files}
grep -rn '->index()\|->unique()' {files}
```

---

## node-ts

### Missing Type Safety

```bash
# any type usage
grep -rn ':\s*any\b\|as\s\+any\b\|<any>' {files}

# Type assertions that bypass checking
grep -rn 'as\s\+unknown\s\+as\|as\s\+any\s\+as' {files}

# Non-null assertions
grep -rn '!\.' {files}
```

### Error Handling Anti-Patterns

```bash
# Empty catch blocks
grep -rn 'catch\s*(.*)\s*{\s*}' {files}

# Unhandled promise rejections
grep -rn '\.then(\|new Promise' {files}
# Check if .catch() is present or async/await with try/catch
```

### Missing ESM Compatibility

```bash
# CommonJS in ESM projects
grep -rn 'require(\|module\.exports' {files}
# Check tsconfig.json for "module": "ESNext" or "NodeNext"
```

### Import/Export Issues

```bash
# Default exports (prefer named exports for better tree-shaking)
grep -rn 'export default' {files}

# Circular dependency indicators
# Large barrel files re-exporting everything
grep -rn "export \* from\|export {" {files}
```

---

## python-django

### Naming Convention Violations

```bash
# Classes should be PascalCase
grep -rn 'class\s\+[a-z]' {files}

# Functions/methods should be snake_case
grep -rn 'def\s\+[a-z]*[A-Z]' {files}

# Constants should be UPPER_CASE
grep -rn '^[A-Z_]*\s*=' {files}
```

### Anti-Patterns

```bash
# Mutable default arguments
grep -rn 'def\s\+.*=\s*\[\]\|def\s\+.*=\s*{}' {files}

# Bare except clause
grep -rn 'except:\s*$' {files}

# Using print() instead of logging
grep -rn 'print(' {files}
# Should use logging module in production code
```

### Django-Specific Issues

```bash
# Missing __str__ on models
grep -rn 'class\s\+\w\+(models\.Model)' {files}
grep -rn 'def\s\+__str__' {files}

# Hardcoded URLs in views
grep -rn "redirect('/\|redirect(\"/" {files}
# Should use reverse() or redirect(name)

# Missing migrations for model changes
grep -rn 'class\s\+\w\+(models\.Model)\|models\.\w\+Field' {files}
```

---

## go

### Error Handling

```bash
# Ignored errors (assigned to _)
grep -rn '\s_\s*=\s*.*(' {files}
# Errors should be checked, not discarded

# Errors not wrapped with context
grep -rn 'return err$\|return nil, err$' {files}
# Prefer fmt.Errorf("context: %w", err) for error wrapping
```

### Naming Conventions

```bash
# Exported functions/types should be PascalCase (Go enforces this)
# Unexported should be camelCase

# Package naming -- should be lowercase, no underscores
grep -rn 'package\s\+[A-Z]\|package\s\+.*_' {files}

# Stuttering names (e.g., user.UserService)
# Check if type name repeats package name
```

### Anti-Patterns

```bash
# init() functions (hidden side effects)
grep -rn 'func init()' {files}

# Global mutable state
grep -rn 'var\s\+\w\+\s\+=' {files}
# Package-level variables should be const or sync-protected

# Naked goroutines without error handling
grep -rn 'go\s\+func' {files}
# Should have recover() or error channel
```

---

## rust

### Error Handling

```bash
# unwrap() in non-test code
grep -rn '\.unwrap()' {files}
# Should use ? operator or match for proper error handling

# expect() with unhelpful messages
grep -rn '\.expect("' {files}
# Messages should describe what went wrong, not just "failed"
```

### Ownership Anti-Patterns

```bash
# Unnecessary cloning
grep -rn '\.clone()' {files}
# Check if borrowing would suffice

# Returning references to local data
# (compiler catches this, but check for unsafe workarounds)
grep -rn 'unsafe.*&' {files}
```

### API Design

```bash
# Public functions without documentation
grep -rn 'pub\s\+fn\|pub\s\+struct\|pub\s\+enum' {files}
grep -rn '///\|//!' {files}
# Public items should have doc comments

# Missing Display/Debug derives on public types
grep -rn '#\[derive(' {files}
grep -rn 'pub\s\+struct\|pub\s\+enum' {files}
```
