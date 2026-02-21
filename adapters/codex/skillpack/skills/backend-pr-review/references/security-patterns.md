# Security Patterns -- Backend PR Review

> Reference file for backend-pr-review skill. Loaded on demand during Step 3.
> Organized by: Universal Patterns (always loaded) + per-stack sections (loaded by anchor).

---

## Universal Patterns

These patterns apply to ALL backend stacks. Always run these.

### Hardcoded Secrets

```bash
# API keys and tokens
grep -rn 'api[_-]?key\s*[:=]\s*["\x27][A-Za-z0-9]' {files}
grep -rn 'secret[_-]?key\s*[:=]\s*["\x27][A-Za-z0-9]' {files}
grep -rn 'password\s*[:=]\s*["\x27][^"\x27]*["\x27]' {files}
grep -rn 'token\s*[:=]\s*["\x27][A-Za-z0-9]' {files}

# AWS credentials
grep -rn 'AKIA[0-9A-Z]{16}' {files}

# Private keys
grep -rn 'BEGIN.*PRIVATE KEY' {files}

# Connection strings with credentials
grep -rn '://[^:]+:[^@]+@' {files}
```

### Known False Positive Allowlist

Skip these when found in security scans:
- Files in `test/`, `tests/`, `spec/`, `__tests__/`, `fixtures/` directories
- Variables named `*_example`, `*_placeholder`, `*_dummy`, `*_fake`, `*_test`
- Values that are clearly UUIDs or example tokens (e.g., `sk_test_`, `pk_test_`)
- Environment variable references (`process.env.*`, `os.environ.*`, `env()`, `getenv()`)
- Config files that read from env: `.env.example`, `config/*.example.*`

### Command Injection

```bash
# Shell execution functions (check if user input reaches these)
grep -rn 'exec\|system\|popen\|shell_exec\|passthru\|subprocess' {files}
```

### Path Traversal

```bash
# File operations with potential user input
grep -rn 'file_get_contents\|readFile\|open(\|fopen' {files}
grep -rn '\.\./\.\.' {files}
```

---

## php-laravel

### SQL Injection

```bash
# Raw queries with potential user input
grep -rn 'whereRaw\|selectRaw\|orderByRaw\|havingRaw\|groupByRaw' {files}
grep -rn 'DB::raw\|DB::select\|DB::insert\|DB::update\|DB::delete\|DB::statement' {files}
grep -rn '\$pdo->query\|\$pdo->exec' {files}
```

### Mass Assignment

```bash
# Dangerous mass assignment patterns
grep -rn '\$request->all()\|\$request->input()' {files}
grep -rn 'forceFill\|forceCreate' {files}
grep -rn '\$guarded\s*=\s*\[\s*\]' {files}
```

### XSS

```bash
# Unescaped output in Blade
grep -rn '{!!\s*\$' {files}
```

### Auth Bypass

```bash
# Missing middleware
grep -rn "Route::" {files}
# Check for auth middleware on state-changing routes
grep -rn "->middleware" {files}

# Missing policy checks
grep -rn 'authorize\|can\|cannot\|policy' {files}
```

### Sanctum / Passport Issues

```bash
# Token without abilities
grep -rn 'createToken' {files}
# Check if abilities/scopes are specified
grep -rn 'tokenCan\|hasAbility' {files}
```

### Dangerous Functions

```bash
grep -rn 'eval(\|assert(\|extract(\|unserialize(' {files}
grep -rn 'shell_exec\|exec(\|system(\|passthru\|popen\|proc_open' {files}
```

---

## node-ts

### SQL Injection

```bash
# Raw queries in Knex, Sequelize, TypeORM, Prisma
grep -rn '\.raw(\|\.query(' {files}
grep -rn 'knex\.raw\|sequelize\.query' {files}
# String concatenation in queries
grep -rn "query.*\+.*req\.\|query.*\`.*\${.*req" {files}
```

### NoSQL Injection

```bash
# MongoDB operator injection
grep -rn '\$where\|\$regex\|\$gt\|\$lt\|\$ne\|\$in' {files}
grep -rn 'find(\s*req\.\|findOne(\s*req\.' {files}
```

### XSS / Unsafe HTML

```bash
# Dangerous innerHTML or template interpolation
grep -rn 'innerHTML\|dangerouslySetInnerHTML\|v-html' {files}
grep -rn 'res\.send.*req\.\|res\.write.*req\.' {files}
```

### Auth Issues

```bash
# Missing auth middleware on routes
grep -rn 'router\.\(get\|post\|put\|delete\|patch\)' {files}
# JWT verification issues
grep -rn 'jwt\.decode\|jsonwebtoken.*decode' {files}
# Check verify vs decode (decode doesn't verify signature)
```

### Prototype Pollution

```bash
grep -rn 'Object\.assign\|\.\.\.req\.body\|merge(\|extend(' {files}
grep -rn '__proto__\|constructor\[' {files}
```

---

## python-django

### SQL Injection

```bash
# Raw SQL in Django
grep -rn '\.raw(\|\.extra(\|RawSQL\|connection\.cursor' {files}
grep -rn 'cursor\.execute.*%\|cursor\.execute.*format\|cursor\.execute.*f"' {files}
```

### Mass Assignment / Unsafe Deserialization

```bash
# Pickle deserialization (RCE risk)
grep -rn 'pickle\.loads\|pickle\.load\|yaml\.load\b' {files}
# Unrestricted model updates
grep -rn '\.update(\*\*request\.\|\.create(\*\*request\.' {files}
```

### Auth Issues

```bash
# Missing @login_required or permission decorators
grep -rn 'def\s\+\(get\|post\|put\|patch\|delete\)\b' {files}
grep -rn '@login_required\|@permission_required\|IsAuthenticated' {files}
# CSRF exemption
grep -rn '@csrf_exempt' {files}
```

### Template Injection

```bash
# mark_safe with user input
grep -rn 'mark_safe\|SafeString\|\|safe\b' {files}
# Jinja2 without sandboxing
grep -rn 'from_string\|Template(' {files}
```

---

## go

### SQL Injection

```bash
# String formatting in SQL queries
grep -rn 'fmt\.Sprintf.*SELECT\|fmt\.Sprintf.*INSERT\|fmt\.Sprintf.*UPDATE\|fmt\.Sprintf.*DELETE' {files}
grep -rn 'db\.Query.*\+\|db\.Exec.*\+' {files}
# Prefer parameterized queries: db.Query("SELECT ... WHERE id = $1", id)
```

### Command Injection

```bash
grep -rn 'exec\.Command\|os\.exec' {files}
# Check if user input reaches command arguments
```

### Auth Issues

```bash
# Missing middleware on HTTP handlers
grep -rn 'HandleFunc\|Handle(' {files}
grep -rn 'AuthMiddleware\|RequireAuth\|WithAuth' {files}
```

### Goroutine Leaks

```bash
# Goroutines without context cancellation
grep -rn 'go\s\+func\|go\s\+[a-zA-Z]' {files}
grep -rn 'context\.WithCancel\|context\.WithTimeout\|context\.WithDeadline' {files}
```

### Unsafe Pointer Usage

```bash
grep -rn 'unsafe\.Pointer\|reflect\.SliceHeader\|reflect\.StringHeader' {files}
```

---

## rust

### Unsafe Code

```bash
# Unsafe blocks
grep -rn 'unsafe\s*{' {files}
# Raw pointer dereferencing
grep -rn '\*mut\s\|\*const\s' {files}
```

### SQL Injection

```bash
# String formatting in SQL (sqlx, diesel)
grep -rn 'format!.*SELECT\|format!.*INSERT\|format!.*UPDATE\|format!.*DELETE' {files}
grep -rn 'query(&format!' {files}
```

### Auth Issues

```bash
# Missing auth extractors in Actix/Axum handlers
grep -rn '#\[get\|#\[post\|#\[put\|#\[delete\|#\[patch' {files}
grep -rn 'AuthUser\|Claims\|Identity\|AuthGuard' {files}
```

### Unwrap / Panic in Production

```bash
# unwrap() calls that could panic
grep -rn '\.unwrap()\|\.expect(' {files}
# Prefer proper error handling with ? operator or match
```
