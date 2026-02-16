# Performance Patterns -- Backend PR Review

> Reference file for backend-pr-review skill. Loaded on demand during Step 4.
> Organized by: Universal Patterns (always loaded) + per-stack sections (loaded by anchor).

---

## Universal Patterns

These patterns apply to ALL backend stacks.

### Unbounded Queries

Any database query without a LIMIT clause or pagination is a risk. Flag queries that could return unlimited rows.

```bash
# Look for queries missing LIMIT or pagination
grep -rn 'SELECT.*FROM' {files}
# Then verify each has LIMIT, pagination, or is constrained by primary key lookup
```

### N+1 Query Problem

Database queries inside loops multiply database calls. The most common performance killer across all stacks.

**Detection**: Look for DB query calls inside `for`, `foreach`, `while`, `map`, or `flatMap` constructs.

### Missing Pagination

API endpoints returning collections without pagination parameters.

```bash
grep -rn 'findAll\|find_all\|get_list\|list(\|\.all()' {files}
# Check if results are paginated (limit/offset, cursor, page parameter)
```

### Sequential External Calls

Multiple external API/service calls made sequentially when they could be parallelized.

### Missing Connection Pooling

Database connections opened per-request instead of using a pool.

---

## php-laravel

### N+1 Queries

```bash
# Relationships accessed in loops without eager loading
grep -rn '->with(\|->load(' {files}
# Check if queries in views/controllers access relationships without with()
grep -rn 'foreach.*->.*->.*(' {files}
```

**Fix pattern**: Use `->with('relationship')` for eager loading.

### Unbounded Eloquent Queries

```bash
# Model::all() returns everything
grep -rn '::all()\|->get()' {files}
# Check if these have ->limit() or ->paginate() before ->get()
```

### Missing Pagination

```bash
grep -rn '->get()\|->all()' {files}
# Should use ->paginate() or ->simplePaginate() for list endpoints
```

### Expensive Operations Without Cache

```bash
grep -rn 'Cache::remember\|Cache::get\|cache(' {files}
# Flag expensive operations (API calls, complex queries) without caching
```

### Queue-Worthy Operations in Request Cycle

```bash
# Email, notifications, file processing in sync request
grep -rn 'Mail::send\|Notification::send\|dispatch(' {files}
# Should use queued jobs for long-running operations
```

---

## node-ts

### N+1 Queries

```bash
# Queries inside loops or map/forEach
grep -rn 'await.*find.*forEach\|await.*find.*map\|for.*await.*find' {files}
```

**Fix pattern**: Use batch queries (`WHERE id IN (...)`) or ORM eager loading.

### Sequential Awaits

```bash
# Multiple sequential awaits that could be parallelized
grep -rn 'await.*\nawait\|await.*;\s*await' {files}
```

**Fix pattern**: Use `Promise.all([...])` for independent async operations.

### Missing Stream Processing

```bash
# Reading entire files into memory
grep -rn 'readFileSync\|readFile(' {files}
# For large files, prefer createReadStream
```

### Blocking Event Loop

```bash
# CPU-intensive sync operations
grep -rn 'JSON\.parse\|JSON\.stringify' {files}
# Flag when used on large payloads without streaming
grep -rn 'crypto\.\(pbkdf2Sync\|randomBytes.*Sync\|scryptSync\)' {files}
```

### Missing Connection Pool Config

```bash
# Database connections without pool configuration
grep -rn 'createConnection\|new Pool\|createPool' {files}
# Check for pool size configuration
```

---

## python-django

### N+1 Queries

```bash
# Accessing related objects without select_related/prefetch_related
grep -rn 'select_related\|prefetch_related' {files}
# Check if views accessing foreign keys have these optimizations
```

**Fix pattern**: Use `select_related()` for ForeignKey, `prefetch_related()` for ManyToMany.

### Unbounded QuerySets

```bash
# QuerySets without slicing or pagination
grep -rn '\.objects\.all()\|\.objects\.filter(' {files}
# Check if results are sliced [:N] or paginated
```

### Sync I/O in Async Context

```bash
# Blocking calls in async views/handlers
grep -rn 'async def.*\n.*\.objects\.\|async def.*\n.*open(' {files}
# Django ORM is sync by default -- use sync_to_async or database_sync_to_async
```

### Missing Database Indexes

```bash
# Models with frequently queried fields lacking db_index
grep -rn 'class Meta\|db_index\|index_together\|indexes' {files}
# Check filter/order_by fields against model indexes
```

---

## go

### Goroutine Leaks

```bash
# Goroutines without proper lifecycle management
grep -rn 'go\s\+func\|go\s\+[a-zA-Z]' {files}
# Check for context cancellation, WaitGroup, or channel-based shutdown
grep -rn 'context\.WithCancel\|sync\.WaitGroup\|<-done\|<-ctx\.Done' {files}
```

### Unbuffered Channels in Hot Paths

```bash
# Channel creation without buffer size
grep -rn 'make(chan\s' {files}
# In hot paths, unbuffered channels cause goroutine blocking
```

### Missing Connection Pool Limits

```bash
# Database connections without pool limits
grep -rn 'SetMaxOpenConns\|SetMaxIdleConns\|SetConnMaxLifetime' {files}
# sql.Open() without pool configuration
grep -rn 'sql\.Open' {files}
```

### Inefficient String Concatenation

```bash
# String concatenation in loops (use strings.Builder)
grep -rn 'for.*\+=' {files}
grep -rn 'strings\.Builder\|bytes\.Buffer' {files}
```

---

## rust

### Unnecessary Cloning

```bash
# .clone() calls that may be avoidable
grep -rn '\.clone()' {files}
# Check if borrowing (&) would suffice
```

### Blocking in Async Context

```bash
# Sync I/O in async functions (blocks the runtime)
grep -rn 'std::fs::\|std::net::\|std::io::' {files}
# Should use tokio::fs, tokio::net, tokio::io in async context
```

### Missing Capacity Hints

```bash
# Vec/HashMap creation without capacity hints for known sizes
grep -rn 'Vec::new()\|HashMap::new()' {files}
# When size is known, use Vec::with_capacity() or HashMap::with_capacity()
```
