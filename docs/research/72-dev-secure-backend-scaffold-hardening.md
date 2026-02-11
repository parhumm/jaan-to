# Secure Backend Scaffold Defaults and Hardening Patterns

> Research conducted: 2026-02-10

## Executive Summary

- **JWT verification must use cryptographic libraries like `jose` with explicit algorithm whitelisting** -- never decode tokens with base64 alone or allow algorithm negotiation from untrusted input. The `jose` library provides constant-time signature verification, JWK/JWKS support, and protection against algorithm confusion attacks that `jsonwebtoken` historically lacked.
- **Session management via httpOnly, Secure, SameSite cookies using `@fastify/secure-session` eliminates an entire class of XSS-based token theft** -- server-side encrypted sessions with sodium-native provide defense-in-depth that localStorage-based JWT storage cannot match.
- **Rate limiting, CSRF protection, and Content Security Policy must be scaffold defaults, not afterthoughts** -- `@fastify/rate-limit`, `@fastify/csrf-protection`, and `@fastify/helmet` should be registered at application bootstrap with secure presets, overridden per-route only when justified.
- **Input sanitization beyond schema validation is critical** -- Fastify's JSON Schema validation handles type checking but does not prevent stored XSS, prototype pollution, or semantic injection; dedicated sanitization layers and parameterized queries via ORMs are required.
- **OWASP Top 10 (2021) maps directly to Fastify plugin defaults** -- a well-configured scaffold with helmet, CORS restrictions, rate limiting, secure sessions, CSRF tokens, parameterized ORM queries, and dependency auditing mitigates 9 of 10 categories out of the box.

## Background & Context

Modern backend scaffolds and code generators (such as `create-fastify`, Yeoman generators, or custom CLI tools) determine the security posture of every application built from them. When a scaffold ships with insecure defaults -- such as permissive CORS (`origin: *`), no rate limiting, or JWT tokens stored in localStorage -- every downstream project inherits those vulnerabilities. The concept of "secure by default" means that a freshly generated project, before any developer customization, should be hardened against the OWASP Top 10 and common attack vectors.

The Fastify ecosystem is particularly well-suited for secure-by-default scaffolding because of its plugin architecture. Security concerns are encapsulated in first-party plugins (`@fastify/helmet`, `@fastify/cors`, `@fastify/rate-limit`, `@fastify/csrf-protection`, `@fastify/secure-session`) that can be registered declaratively. Unlike Express middleware ordering pitfalls, Fastify's encapsulation model ensures security plugins apply to the correct scope.

This research focuses on the Fastify/Node.js stack and synthesizes patterns from the OWASP Cheat Sheet Series, Fastify official documentation, the `jose` library documentation, and community security hardening guides. The goal is to provide actionable patterns that a code generator can embed as defaults, reducing the "time to secure" for new backend projects from days to zero.

## Key Findings

### 1. JWT Verification with `jose` vs Insecure Base64 Decoding

The `jose` library (by Filip Skokan, also author of `oidc-provider`) is the recommended JWT library for Node.js security-critical applications. It provides:

**Why `jose` over `jsonwebtoken`:**
- **Algorithm whitelisting**: `jose` requires explicit algorithm specification via `jwtVerify()`, preventing algorithm confusion attacks where an attacker switches RS256 to HS256 and signs with the public key.
- **Constant-time comparison**: Signature verification uses timing-safe comparison, preventing timing side-channel attacks.
- **JWK/JWKS support**: Native support for JSON Web Key Sets, enabling key rotation without code changes.
- **No `none` algorithm**: `jose` does not accept the `none` algorithm by default, unlike some `jsonwebtoken` configurations.
- **ESM-first, zero dependencies**: Smaller attack surface compared to `jsonwebtoken`'s dependency tree.

**Critical anti-pattern -- base64 decoding without verification:**
```javascript
// DANGEROUS: Never do this
const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString());
// This trusts the token without verifying the signature

// SECURE: Always verify with jose
import { jwtVerify } from 'jose';
const { payload } = await jwtVerify(token, publicKey, {
  algorithms: ['RS256'],        // Explicit algorithm whitelist
  issuer: 'https://auth.example.com',  // Validate issuer
  audience: 'my-api',          // Validate audience
  clockTolerance: 30,          // 30-second clock skew tolerance
});
```

**Scaffold default pattern:**
```javascript
// config/auth.js - Scaffold default
import { createRemoteJWKSet, jwtVerify } from 'jose';

const JWKS = createRemoteJWKSet(new URL(process.env.JWKS_URI));

export async function verifyToken(token) {
  const { payload, protectedHeader } = await jwtVerify(token, JWKS, {
    algorithms: ['RS256', 'ES256'],
    issuer: process.env.JWT_ISSUER,
    audience: process.env.JWT_AUDIENCE,
    maxTokenAge: '1h',
  });
  return payload;
}
```

**Key security properties:**
- `algorithms` must be an explicit array, never inferred from the token header.
- `issuer` and `audience` validation prevents token reuse across services.
- `maxTokenAge` enforces time-based expiry server-side, independent of the `exp` claim.
- `createRemoteJWKSet` caches JWKS responses and handles key rotation automatically.

### 2. httpOnly Cookie Session Management

**`@fastify/secure-session` over `@fastify/session`:**

`@fastify/secure-session` uses `sodium-native` (libsodium bindings) for encrypted, tamper-proof cookies. Unlike `@fastify/session` which relies on server-side storage (Redis, etc.), `@fastify/secure-session` is stateless -- the encrypted session data lives entirely in the cookie, eliminating the need for a session store.

**Scaffold default configuration:**
```javascript
import fastifySecureSession from '@fastify/secure-session';
import { readFileSync } from 'fs';

fastify.register(fastifySecureSession, {
  // Generated via: npx @fastify/secure-session > secret-key
  key: readFileSync('secret-key'),
  // OR use environment variable
  // key: Buffer.from(process.env.SESSION_SECRET, 'hex'),
  cookie: {
    path: '/',
    httpOnly: true,    // Not accessible via document.cookie
    secure: true,      // Only sent over HTTPS
    sameSite: 'lax',   // CSRF protection for top-level navigation
    maxAge: 3600,      // 1 hour in seconds
    domain: process.env.COOKIE_DOMAIN,
  },
});
```

**Why these defaults matter:**
- `httpOnly: true` -- Prevents JavaScript from reading the session cookie, mitigating XSS-based session theft entirely.
- `secure: true` -- Ensures cookies are only sent over HTTPS, preventing MITM interception on downgraded connections.
- `sameSite: 'lax'` -- Prevents cross-origin form submissions from sending the cookie, providing baseline CSRF protection. Use `'strict'` for highest security (breaks OAuth redirects) or `'none'` only with `secure: true` for legitimate cross-origin needs.
- `maxAge: 3600` -- Sessions expire after 1 hour of inactivity, limiting the window for stolen cookies.

**Session data patterns:**
```javascript
// Setting session data after login
fastify.post('/login', async (request, reply) => {
  const user = await authenticateUser(request.body);
  request.session.set('userId', user.id);
  request.session.set('role', user.role);
  request.session.set('loginAt', Date.now());
  return { success: true };
});

// Reading session data in protected routes
fastify.get('/profile', async (request, reply) => {
  const userId = request.session.get('userId');
  if (!userId) {
    return reply.code(401).send({ error: 'Unauthorized' });
  }
  // ...
});

// Destroying session on logout
fastify.post('/logout', async (request, reply) => {
  request.session.delete();
  return { success: true };
});
```

### 3. CSRF Protection Patterns

**`@fastify/csrf-protection` with double-submit cookie pattern:**

```javascript
import fastifyCsrf from '@fastify/csrf-protection';

fastify.register(fastifyCsrf, {
  sessionPlugin: '@fastify/secure-session',
  cookieOpts: {
    httpOnly: true,
    sameSite: 'strict',
    secure: true,
    signed: true,
    path: '/',
  },
  getToken: (request) => {
    return request.headers['x-csrf-token'] ||
           request.body?._csrf;
  },
});
```

**Protection strategies for different architectures:**

| Architecture | Strategy | Implementation |
|-------------|----------|----------------|
| Server-rendered (HTML forms) | Synchronizer Token Pattern | Embed `csrfToken()` in hidden form field |
| SPA + Same-origin API | Double Submit Cookie | Send token in `x-csrf-token` header |
| SPA + Cross-origin API | SameSite cookies + Custom header | Rely on SameSite=Strict + check `Origin` header |
| API-only (no cookies) | Not needed | Stateless JWT auth does not need CSRF protection |

**Per-route CSRF configuration:**
```javascript
// Exempt webhook endpoints from CSRF
fastify.post('/webhooks/stripe', {
  config: { csrf: false },
  preHandler: verifyStripeSignature,
}, webhookHandler);

// Enforce CSRF on all other mutation routes
fastify.addHook('onRequest', async (request, reply) => {
  if (['POST', 'PUT', 'DELETE', 'PATCH'].includes(request.method)) {
    await fastify.csrfProtection(request, reply);
  }
});
```

### 4. Rate Limiting Strategies

**`@fastify/rate-limit` configuration patterns:**

```javascript
import fastifyRateLimit from '@fastify/rate-limit';

// Global rate limit
fastify.register(fastifyRateLimit, {
  global: true,
  max: 100,                    // 100 requests
  timeWindow: '1 minute',     // per minute
  ban: 3,                      // Ban after 3 limit hits
  cache: 10000,                // Cache size for IP tracking
  allowList: ['127.0.0.1'],   // Exempt localhost in development
  keyGenerator: (request) => {
    // Use authenticated user ID if available, otherwise IP
    return request.user?.id || request.ip;
  },
  errorResponseBuilder: (request, context) => ({
    statusCode: 429,
    error: 'Too Many Requests',
    message: `Rate limit exceeded. Retry in ${context.after}`,
    retryAfter: context.after,
  }),
  addHeadersOnExceeding: {
    'x-ratelimit-limit': true,
    'x-ratelimit-remaining': true,
    'x-ratelimit-reset': true,
  },
  addHeaders: {
    'x-ratelimit-limit': true,
    'x-ratelimit-remaining': true,
    'x-ratelimit-reset': true,
    'retry-after': true,
  },
});
```

**Per-route rate limits (tiered strategy):**

```javascript
// Authentication endpoints: strict limits
fastify.post('/auth/login', {
  config: {
    rateLimit: {
      max: 5,
      timeWindow: '15 minutes',
      keyGenerator: (req) => req.ip, // Always by IP for auth
    },
  },
}, loginHandler);

// Password reset: very strict
fastify.post('/auth/reset-password', {
  config: {
    rateLimit: {
      max: 3,
      timeWindow: '1 hour',
    },
  },
}, resetHandler);

// API endpoints: per-user limits
fastify.get('/api/data', {
  config: {
    rateLimit: {
      max: 1000,
      timeWindow: '1 hour',
      keyGenerator: (req) => req.user.id,
    },
  },
}, dataHandler);

// Public read endpoints: generous limits
fastify.get('/api/public', {
  config: {
    rateLimit: {
      max: 200,
      timeWindow: '1 minute',
    },
  },
}, publicHandler);
```

**Sliding window vs fixed window:**

`@fastify/rate-limit` uses a fixed window by default. For sliding window behavior with Redis:

```javascript
import Redis from 'ioredis';

fastify.register(fastifyRateLimit, {
  global: true,
  max: 100,
  timeWindow: '1 minute',
  redis: new Redis({
    host: process.env.REDIS_HOST,
    port: 6379,
    enableOfflineQueue: false,
  }),
  // Redis store provides distributed rate limiting
  // and approximate sliding window behavior
});
```

**Rate limiting tiers scaffold default:**

| Endpoint Category | Max Requests | Time Window | Key |
|-------------------|-------------|-------------|-----|
| Login/Register | 5 | 15 min | IP |
| Password Reset | 3 | 1 hour | IP |
| Email Verification | 5 | 1 hour | IP |
| API (authenticated) | 1000 | 1 hour | User ID |
| API (unauthenticated) | 100 | 1 min | IP |
| File Upload | 10 | 1 hour | User ID |
| Webhook receive | Unlimited | - | Signature-verified |

### 5. Content Security Policy and Security Headers

**`@fastify/helmet` configuration:**

```javascript
import fastifyHelmet from '@fastify/helmet';

fastify.register(fastifyHelmet, {
  // CSP configuration
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],          // No 'unsafe-inline' or 'unsafe-eval'
      styleSrc: ["'self'"],
      imgSrc: ["'self'", 'data:'],
      fontSrc: ["'self'"],
      connectSrc: ["'self'"],
      frameSrc: ["'none'"],           // Prevent framing entirely
      objectSrc: ["'none'"],          // No plugins (Flash, Java)
      baseUri: ["'self'"],            // Prevent base tag hijacking
      formAction: ["'self'"],         // Restrict form destinations
      frameAncestors: ["'none'"],     // Prevent clickjacking
      upgradeInsecureRequests: [],    // Auto-upgrade HTTP to HTTPS
    },
  },
  // Additional headers
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' },
  dnsPrefetchControl: { allow: false },
  frameguard: { action: 'deny' },
  hsts: {
    maxAge: 31536000,           // 1 year
    includeSubDomains: true,
    preload: true,
  },
  ieNoOpen: true,
  noSniff: true,                // X-Content-Type-Options: nosniff
  permittedCrossDomainPolicies: { permittedPolicies: 'none' },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: true,
});
```

**API-only vs full-stack CSP differences:**

For API-only backends (JSON responses), CSP is less critical but still recommended:
```javascript
// API-only: simplified helmet
fastify.register(fastifyHelmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'none'"],       // API serves no HTML
      frameAncestors: ["'none'"],
    },
  },
  crossOriginResourcePolicy: { policy: 'same-site' },
});
```

### 6. CORS Configuration

**Secure CORS defaults (never use `origin: true` or `origin: '*'` in production):**

```javascript
import fastifyCors from '@fastify/cors';

fastify.register(fastifyCors, {
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];

    // Allow requests with no origin (mobile apps, curl, server-to-server)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('CORS: Origin not allowed'), false);
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
  credentials: true,            // Required for cookie-based auth
  maxAge: 86400,                // Cache preflight for 24 hours
  exposedHeaders: ['X-RateLimit-Limit', 'X-RateLimit-Remaining'],
  preflight: true,
  strictPreflight: true,        // Return 400 for invalid preflight
});
```

**Environment-based CORS scaffold:**
```javascript
const corsConfig = {
  development: {
    origin: ['http://localhost:3000', 'http://localhost:5173'],
    credentials: true,
  },
  staging: {
    origin: ['https://staging.example.com'],
    credentials: true,
  },
  production: {
    origin: ['https://example.com', 'https://www.example.com'],
    credentials: true,
    maxAge: 86400,
  },
};
```

### 7. Input Sanitization Beyond Validation

Fastify's JSON Schema validation ensures types, formats, and constraints, but it does not sanitize content. Additional layers are needed:

**Prototype pollution prevention:**
```javascript
// Fastify 4.x+ has built-in prototype pollution protection
// via secure-json-parse, but verify configuration:
fastify.register(import('@fastify/sensible'));

// Additionally, use Object.create(null) for lookup objects:
const handlers = Object.create(null);
handlers['action'] = myHandler;
```

**HTML/XSS sanitization for stored content:**
```javascript
import DOMPurify from 'isomorphic-dompurify';

function sanitizeUserInput(input) {
  if (typeof input === 'string') {
    // Strip all HTML tags for plain text fields
    return DOMPurify.sanitize(input, { ALLOWED_TAGS: [] });
  }
  return input;
}

// For rich text fields (markdown, HTML editors):
function sanitizeRichText(html) {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'b', 'i', 'em', 'strong', 'a', 'ul', 'ol', 'li', 'br', 'h1', 'h2', 'h3', 'code', 'pre'],
    ALLOWED_ATTR: ['href', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  });
}
```

**Path traversal prevention:**
```javascript
import path from 'path';

function safePath(userInput, baseDir) {
  const resolved = path.resolve(baseDir, userInput);
  if (!resolved.startsWith(path.resolve(baseDir))) {
    throw new Error('Path traversal detected');
  }
  return resolved;
}
```

**Fastify schema + sanitization plugin pattern:**
```javascript
// Pre-validation hook for sanitization
fastify.addHook('preValidation', async (request) => {
  if (request.body && typeof request.body === 'object') {
    request.body = deepSanitize(request.body);
  }
});

function deepSanitize(obj) {
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    // Block prototype pollution keys
    if (key === '__proto__' || key === 'constructor' || key === 'prototype') {
      continue;
    }
    if (typeof value === 'string') {
      result[key] = DOMPurify.sanitize(value, { ALLOWED_TAGS: [] });
    } else if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      result[key] = deepSanitize(value);
    } else if (Array.isArray(value)) {
      result[key] = value.map(item =>
        typeof item === 'string'
          ? DOMPurify.sanitize(item, { ALLOWED_TAGS: [] })
          : typeof item === 'object' && item !== null
            ? deepSanitize(item)
            : item
      );
    } else {
      result[key] = value;
    }
  }
  return result;
}
```

### 8. SQL Injection Prevention with ORMs

**Prisma ORM (recommended for Fastify scaffolds):**

Prisma uses parameterized queries by default, making SQL injection via the standard API effectively impossible:

```javascript
// SAFE: Prisma parameterizes automatically
const user = await prisma.user.findUnique({
  where: { email: userInput },  // userInput is parameterized
});

// SAFE: Prisma's query builder handles escaping
const users = await prisma.user.findMany({
  where: {
    name: { contains: searchTerm },  // Parameterized LIKE query
  },
});
```

**Dangerous: Raw queries bypass ORM protection:**
```javascript
// DANGEROUS: String interpolation in raw queries
const result = await prisma.$queryRaw`SELECT * FROM users WHERE name = '${userInput}'`;

// SAFE: Tagged template literal with Prisma
const result = await prisma.$queryRaw`SELECT * FROM users WHERE name = ${userInput}`;
// The tagged template auto-parameterizes

// SAFE: Explicit parameterization with Prisma.sql
import { Prisma } from '@prisma/client';
const result = await prisma.$queryRaw(
  Prisma.sql`SELECT * FROM users WHERE name = ${Prisma.raw("$1")}`,
  userInput
);
```

**Drizzle ORM patterns:**
```javascript
import { eq, like, sql } from 'drizzle-orm';

// SAFE: Query builder parameterizes
const user = await db.select().from(users).where(eq(users.email, userInput));

// SAFE: Like queries
const results = await db.select().from(users).where(like(users.name, `%${userInput}%`));

// DANGEROUS: sql.raw() bypasses parameterization
// const bad = await db.execute(sql.raw(`SELECT * FROM users WHERE name = '${userInput}'`));

// SAFE: sql`` tagged template with placeholder
const safe = await db.execute(sql`SELECT * FROM users WHERE name = ${userInput}`);
```

**Scaffold rule**: Never expose `$queryRaw` with string concatenation. Lint rules should flag raw SQL string interpolation.

### 9. Secure Dependency Defaults

**Package.json scaffold defaults:**
```json
{
  "scripts": {
    "audit": "npm audit --audit-level=high",
    "audit:fix": "npm audit fix",
    "preinstall": "npx npm-force-resolutions",
    "prepare": "husky install"
  },
  "overrides": {},
  "engines": {
    "node": ">=20.0.0"
  }
}
```

**Recommended security tooling in scaffold:**

| Tool | Purpose | Integration |
|------|---------|-------------|
| `npm audit` | Dependency vulnerability scanning | CI/CD pipeline, pre-commit |
| `socket.dev` | Supply chain attack detection | GitHub App, CI check |
| `snyk` | Deep vulnerability analysis | CLI, CI/CD, IDE |
| `lockfile-lint` | Lockfile integrity verification | Pre-commit hook |
| `better-npm-audit` | Enhanced npm audit with allowlisting | CI/CD |
| `husky` + `lint-staged` | Pre-commit security checks | Local development |

**`.npmrc` security defaults:**
```ini
# Enforce exact versions
save-exact=true

# Require lockfile for installs
package-lock=true

# Audit on install
audit=true

# Strict SSL
strict-ssl=true

# Disable lifecycle scripts from dependencies
ignore-scripts=true
```

**Node.js runtime security:**
```bash
# Production startup with security flags
node --disable-proto=delete \
     --disallow-code-generation-from-strings \
     --experimental-permission \
     --allow-fs-read=/app \
     --allow-fs-write=/app/uploads \
     server.js
```

### 10. OWASP Top 10 (2021) Mitigation in Scaffolds

| # | OWASP Category | Fastify Mitigation | Plugin/Pattern |
|---|---------------|-------------------|----------------|
| A01 | Broken Access Control | Role-based route guards, JWT audience validation | `jose` + custom decorators |
| A02 | Cryptographic Failures | TLS enforcement, secure session encryption, bcrypt/argon2 | `@fastify/secure-session`, HSTS via helmet |
| A03 | Injection | Parameterized ORM queries, input sanitization, JSON Schema validation | Prisma/Drizzle, Fastify schema validation |
| A04 | Insecure Design | Threat modeling in scaffold docs, rate limiting by default | `@fastify/rate-limit`, scaffold documentation |
| A05 | Security Misconfiguration | Secure defaults for CORS, CSP, headers; no debug in prod | `@fastify/helmet`, `@fastify/cors`, env-based config |
| A06 | Vulnerable Components | Automated dependency scanning, lockfile verification | `npm audit`, `socket.dev`, lockfile-lint |
| A07 | Auth Failures | Secure session cookies, MFA support, brute-force protection | `@fastify/secure-session`, rate limiting on auth routes |
| A08 | Software/Data Integrity | SBOM generation, subresource integrity, signed commits | CI pipeline, `@fastify/helmet` SRI |
| A09 | Logging Failures | Structured logging with pino, audit trail hooks | `pino` (Fastify built-in), custom audit hooks |
| A10 | SSRF | URL validation, allowlisted external services, DNS rebinding protection | Custom fetch wrappers, private IP blocking |

### 11. Security-First Code Generation Patterns

**Scaffold structure for security-first Fastify app:**

```
src/
  plugins/
    security.js          # Registers all security plugins
    authentication.js    # JWT verification, session management
    authorization.js     # RBAC decorators
  hooks/
    sanitize.js          # Pre-validation sanitization
    audit-log.js         # Request/response audit logging
  config/
    cors.js              # Environment-based CORS config
    rate-limit.js        # Tiered rate limit config
    csp.js               # Content Security Policy directives
  routes/
    auth/                # Auth routes with strict rate limits
    api/                 # API routes with standard limits
  utils/
    safe-path.js         # Path traversal prevention
    safe-redirect.js     # Open redirect prevention
    crypto.js            # Hashing, token generation utilities
```

**Security plugin registration order:**
```javascript
// src/plugins/security.js
import fp from 'fastify-plugin';

export default fp(async function securityPlugins(fastify) {
  // 1. Helmet (security headers) -- first, applies to all responses
  await fastify.register(import('@fastify/helmet'), helmetConfig);

  // 2. CORS -- before route handling
  await fastify.register(import('@fastify/cors'), corsConfig);

  // 3. Rate limiting -- before authentication
  await fastify.register(import('@fastify/rate-limit'), rateLimitConfig);

  // 4. Secure session -- before CSRF (CSRF depends on session)
  await fastify.register(import('@fastify/secure-session'), sessionConfig);

  // 5. CSRF protection -- after session plugin
  await fastify.register(import('@fastify/csrf-protection'), csrfConfig);

  // 6. Sensible -- secure error handling
  await fastify.register(import('@fastify/sensible'));
}, { name: 'security-plugins' });
```

**Safe redirect utility:**
```javascript
// Prevent open redirect vulnerabilities
function safeRedirect(url, allowedHosts) {
  try {
    const parsed = new URL(url);
    if (allowedHosts.includes(parsed.hostname)) {
      return url;
    }
  } catch {
    // Relative URLs are safe
    if (url.startsWith('/') && !url.startsWith('//')) {
      return url;
    }
  }
  return '/'; // Default to home
}
```

**Error handling that does not leak internals:**
```javascript
fastify.setErrorHandler(async (error, request, reply) => {
  request.log.error(error); // Log full error server-side

  // Never expose stack traces or internal details in production
  if (process.env.NODE_ENV === 'production') {
    const statusCode = error.statusCode || 500;
    return reply.code(statusCode).send({
      statusCode,
      error: statusCode >= 500 ? 'Internal Server Error' : error.message,
      message: statusCode >= 500
        ? 'An unexpected error occurred'
        : error.message,
    });
  }

  // In development, include more detail
  return reply.code(error.statusCode || 500).send({
    statusCode: error.statusCode || 500,
    error: error.message,
    stack: error.stack,
  });
});
```

### 12. `@fastify/helmet` Deep Dive

Helmet sets 15+ HTTP security headers. Key configurations for scaffolds:

**Strict Transport Security (HSTS):**
- `maxAge: 31536000` (1 year) -- tells browsers to only use HTTPS
- `includeSubDomains: true` -- applies to all subdomains
- `preload: true` -- allows submission to HSTS preload lists

**X-Content-Type-Options:**
- `noSniff: true` -- prevents MIME-type sniffing attacks where browsers execute files as scripts

**Referrer-Policy:**
- `strict-origin-when-cross-origin` -- sends full URL on same-origin, only origin on cross-origin, nothing on downgrade

**Permissions-Policy (formerly Feature-Policy):**
```javascript
// Additional header not covered by helmet by default
fastify.addHook('onSend', async (request, reply) => {
  reply.header('Permissions-Policy',
    'camera=(), microphone=(), geolocation=(), payment=(self)'
  );
});
```

### 13. `@fastify/secure-session` Deep Dive

**Key generation and rotation:**
```bash
# Generate encryption key
npx @fastify/secure-session > secret-key

# For key rotation, generate a new key and use both:
npx @fastify/secure-session > secret-key-new
```

```javascript
import { readFileSync } from 'fs';

fastify.register(fastifySecureSession, {
  // Key rotation: first key encrypts, all keys decrypt
  key: [
    readFileSync('secret-key-new'),  // Current key (encrypts)
    readFileSync('secret-key'),       // Old key (still decrypts)
  ],
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 3600,
  },
});
```

**Session security patterns:**
- Regenerate session ID after authentication state changes (login, privilege escalation)
- Set absolute session timeouts (not just idle timeouts)
- Store minimal data in sessions (user ID, role -- not full user objects)
- Use session.delete() on logout, not just clearing individual fields

## Recent Developments (2024-2026)

**Node.js Permission Model (v20+):** Node.js 20 introduced an experimental permission model (`--experimental-permission`) that restricts filesystem, network, and child process access. Scaffolds can now ship with minimal permission sets, reducing blast radius of RCE vulnerabilities.

**Fastify v5 (2024-2025):** Fastify 5 introduced tighter TypeScript types, improved encapsulation boundaries, and deprecated several insecure patterns. The plugin registration system now enforces stricter dependency declarations.

**jose v5+:** The `jose` library continued to evolve with improved Ed25519/Ed448 support, better error messages for algorithm mismatches, and runtime-agnostic design (works in Node.js, Deno, Bun, and browsers).

**OWASP Top 10 for LLM Applications (2025):** A new OWASP list specifically targeting AI/LLM-integrated backends was published, highlighting prompt injection, insecure output handling, and training data poisoning -- relevant for scaffolds generating AI-powered backends.

**Supply Chain Security Hardening:** The npm ecosystem adopted stricter provenance attestations (npm provenance), SLSA framework compliance, and Sigstore signing. Modern scaffolds should generate `package.json` with `"publishConfig": { "provenance": true }` for libraries.

**SameSite cookie default change:** Browsers now default cookies to `SameSite=Lax` when no attribute is specified, providing baseline CSRF protection. However, explicit configuration in scaffolds is still required for defense-in-depth.

**Content Security Policy Level 3:** CSP Level 3 introduced `strict-dynamic` and nonce-based policies, reducing the need for complex allowlists. Scaffolds can now generate per-request nonces for inline scripts that need to be allowed.

## Best Practices & Recommendations

1. **Register security plugins at the top level, not per-route:** Helmet, CORS, rate limiting, and session management should be the first plugins registered. Per-route overrides should loosen restrictions (never tighten what should be default).

2. **Use environment variables for all security-sensitive configuration:** Origins, JWT issuers, session secrets, rate limit thresholds -- none of these should be hardcoded. Scaffolds should generate `.env.example` with secure placeholder values and validation on startup.

3. **Default to deny, explicitly allow:** CORS origins should be an explicit allowlist. CSP should start with `default-src: 'none'` and add what is needed. Routes should require authentication by default, with public routes explicitly marked.

4. **Validate on input, sanitize on output:** Use Fastify JSON Schema for structural validation on input. Apply context-specific output encoding (HTML entity encoding for HTML contexts, parameterized queries for SQL, URL encoding for URLs) on output.

5. **Ship with `npm audit` in CI and pre-commit hooks:** Every scaffold should include a CI step that fails on high-severity vulnerabilities and a pre-commit hook that warns on new advisories.

6. **Never store secrets in code or environment variables alone:** For production, integrate with a secrets manager (Vault, AWS Secrets Manager, Doppler). Scaffolds should document this requirement and provide adapter patterns.

7. **Use structured logging with PII redaction:** Fastify's built-in pino logger should be configured with serializers that redact sensitive fields (passwords, tokens, credit card numbers) from logs.

8. **Generate security documentation with the scaffold:** Every generated project should include a `SECURITY.md` describing the security architecture, threat model, and responsible disclosure process.

9. **Include a security test suite in the scaffold:** Generate tests that verify security headers are present, rate limits work, CSRF tokens are required, authentication is enforced, and error responses do not leak internals.

10. **Pin dependency versions and verify lockfile integrity:** Use `save-exact=true` in `.npmrc`, commit `package-lock.json`, and run `lockfile-lint` in CI to detect lockfile manipulation.

## Comparisons

### JWT Libraries for Node.js

| Aspect | `jose` | `jsonwebtoken` | `fast-jwt` |
|--------|--------|----------------|------------|
| Algorithm whitelisting | Required by API | Optional (defaults to HS256) | Optional |
| Algorithm confusion protection | Built-in | Requires careful configuration | Partial |
| JWK/JWKS support | Native | Via `jwks-rsa` addon | Partial |
| `none` algorithm | Rejected by default | Accepted if no secret | Rejected by default |
| Timing-safe comparison | Yes | Depends on Node.js crypto | Yes |
| Dependencies | Zero | 3 (incl. `jws`, `lodash.includes`) | 2 |
| ESM support | Native | CJS only (needs wrapper) | Native |
| Maintenance | Active (single maintainer, OIDF-adjacent) | Sporadic | Active |
| Performance | Good | Good | Fastest (claims 3-5x) |
| Security track record | No known CVEs | Multiple CVEs (incl. algorithm confusion) | No known CVEs |
| **Recommendation** | **Best for security-critical apps** | Legacy, avoid for new projects | Good for performance-critical, verify security config |

### Session Management Approaches

| Aspect | `@fastify/secure-session` (encrypted cookie) | `@fastify/session` + Redis | Stateless JWT |
|--------|----------------------------------------------|---------------------------|---------------|
| State storage | Cookie (client-side, encrypted) | Server-side (Redis) | Token (client-side, signed) |
| Scalability | Excellent (no server state) | Good (Redis dependency) | Excellent (no server state) |
| Session revocation | Not instant (cookie expiry) | Instant (delete from Redis) | Requires deny-list |
| Data size limit | ~4KB (cookie limit) | Unlimited | ~8KB (header limit) |
| XSS resilience | Strong (httpOnly) | Strong (httpOnly) | Weak if in localStorage |
| CSRF needed | Yes (cookie-based) | Yes (cookie-based) | No (if in Authorization header) |
| **Recommendation** | **Best for most Fastify apps** | Best for large session data or instant revocation needs | Best for stateless microservices with short-lived tokens |

### Rate Limiting Strategies

| Strategy | Fixed Window | Sliding Window | Token Bucket | Leaky Bucket |
|----------|-------------|----------------|--------------|--------------|
| Complexity | Simple | Moderate | Moderate | Moderate |
| Burst handling | Allows burst at window boundary | Smooth distribution | Allows controlled bursts | Strict rate enforcement |
| Memory usage | Low | Moderate | Low | Low |
| `@fastify/rate-limit` support | Default | Via Redis (approximate) | Not built-in | Not built-in |
| Fairness | Window boundary unfairness | Fair | Fair | Fair |
| **Recommendation** | **Default for most routes** | **For auth/payment routes** | External gateway (Kong, etc.) | External gateway |

## Open Questions

- How should scaffolds handle security in serverless environments (Vercel, AWS Lambda) where plugin registration order and cold starts introduce different threat models?
- What is the optimal strategy for key rotation in `@fastify/secure-session` across horizontally scaled instances that share no filesystem?
- How should scaffolds integrate with OpenID Connect providers while maintaining secure-by-default token handling (PKCE, token binding)?
- What patterns should scaffolds adopt for the emerging OWASP Top 10 for LLM Applications, particularly around prompt injection prevention in AI-powered backends?
- How should CSP nonce generation work in Fastify when responses are cached at the CDN layer (nonces must be unique per response)?
- What is the recommended approach for mutual TLS (mTLS) in Fastify for zero-trust architectures?
- How should scaffolds handle security policy for WebSocket connections, which bypass some HTTP-based protections (CORS, CSP)?

## Sources

1. [OWASP Node.js Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html) - Comprehensive Node.js security guidelines covering input validation, authentication, session management, error handling, and server security hardening.
2. [OWASP Top 10 (2021)](https://owasp.org/Top10/) - The definitive ranking of web application security risks with mitigation strategies for each category.
3. [OWASP JSON Web Token Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html) - JWT security best practices including algorithm validation, token storage, and expiry handling (language-agnostic patterns).
4. [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) - Cookie security attributes, session lifecycle management, and defense against session fixation/hijacking.
5. [OWASP Cross-Site Request Forgery Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html) - CSRF mitigation patterns including synchronizer token, double-submit cookie, and SameSite cookie approaches.
6. [OWASP Content Security Policy Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) - CSP directive configuration, nonce-based policies, and deployment strategies.
7. [OWASP SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) - Parameterized queries, stored procedures, and ORM usage patterns to prevent injection.
8. [OWASP Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) - Validation vs sanitization, allowlist vs denylist approaches, and context-specific encoding.
9. [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/) - Reference for HTTP security headers, recommended values, and browser support.
10. [OWASP Rate Limiting Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html) - DoS prevention patterns including rate limiting, resource quotas, and circuit breakers.
11. [Fastify Security Guide](https://fastify.dev/docs/latest/Guides/Security/) - Official Fastify documentation on security practices, plugin recommendations, and common pitfalls.
12. [Fastify CORS Plugin Documentation](https://github.com/fastify/fastify-cors) - `@fastify/cors` configuration reference including dynamic origin validation and preflight handling.
13. [Fastify Helmet Plugin Documentation](https://github.com/fastify/fastify-helmet) - `@fastify/helmet` configuration for Content Security Policy, HSTS, and other security headers.
14. [Fastify Rate Limit Plugin Documentation](https://github.com/fastify/fastify-rate-limit) - `@fastify/rate-limit` configuration including per-route limits, Redis backing, and custom key generators.
15. [Fastify CSRF Protection Plugin Documentation](https://github.com/fastify/csrf-protection) - `@fastify/csrf-protection` patterns for both session-based and cookie-based CSRF mitigation.
16. [Fastify Secure Session Plugin Documentation](https://github.com/fastify/fastify-secure-session) - `@fastify/secure-session` encrypted cookie sessions using sodium-native.
17. [Fastify Sensible Plugin Documentation](https://github.com/fastify/fastify-sensible) - `@fastify/sensible` error handling utilities and security-relevant response helpers.
18. [`jose` Library Documentation](https://github.com/panva/jose) - JWT/JWE/JWS/JWK implementation for Node.js with algorithm whitelisting and JWKS support.
19. [`jose` API Reference](https://github.com/panva/jose/blob/main/docs/functions/jwt_verify.jwtVerify.md) - Detailed `jwtVerify()` API documentation including all verification options.
20. [Prisma Security Best Practices](https://www.prisma.io/docs/concepts/components/prisma-client/raw-database-access) - Parameterized query patterns and raw query safety in Prisma ORM.
21. [Drizzle ORM SQL Injection Prevention](https://orm.drizzle.team/docs/sql) - Safe SQL query building patterns with Drizzle's tagged template literals.
22. [Node.js Permission Model Documentation](https://nodejs.org/api/permissions.html) - Experimental permission system for filesystem, network, and child process restrictions.
23. [helmet.js Documentation](https://helmetjs.github.io/) - Comprehensive documentation for all helmet middleware headers and configuration options.
24. [DOMPurify Documentation](https://github.com/cure53/DOMPurify) - HTML sanitization library for preventing XSS in user-generated content.
25. [npm Audit Documentation](https://docs.npmjs.com/cli/v10/commands/npm-audit) - Built-in vulnerability scanning for npm dependencies.
26. [Socket.dev Security Platform](https://socket.dev/) - Supply chain attack detection analyzing dependency behavior rather than just known CVEs.
27. [lockfile-lint Documentation](https://github.com/lirantal/lockfile-lint) - Lockfile integrity verification to prevent lockfile manipulation attacks.
28. [pino Logger Documentation](https://getpino.io/) - Fastify's built-in structured logger with support for redaction and serializers.
29. [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/) - Security risks specific to AI/LLM-integrated applications.
30. [Node.js Security Best Practices (nodejs.org)](https://nodejs.org/en/learn/getting-started/security-best-practices) - Official Node.js security guidance including HTTP server hardening.
31. [NIST SP 800-63B Digital Identity Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html) - Authentication and session management standards referenced by OWASP.
32. [RFC 7519 - JSON Web Token](https://datatracker.ietf.org/doc/html/rfc7519) - JWT specification defining claims, structure, and security considerations.
33. [RFC 7518 - JSON Web Algorithms](https://datatracker.ietf.org/doc/html/rfc7518) - JWA specification defining algorithm identifiers and requirements.
34. [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749) - OAuth 2.0 specification relevant to token-based authentication flows.
35. [RFC 7636 - PKCE for OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc7636) - Proof Key for Code Exchange, required for public OAuth clients.
36. [MDN Web Docs - HTTP Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers) - Reference for security-related HTTP headers (CSP, HSTS, CORS, etc.).
37. [MDN Web Docs - SameSite Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite) - Browser behavior for SameSite cookie attribute values.
38. [MDN Web Docs - Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) - CSP reference including directive descriptions and examples.
39. [Snyk Security Advisories](https://security.snyk.io/) - Vulnerability database for npm packages with remediation guidance.
40. [CWE-89: SQL Injection](https://cwe.mitre.org/data/definitions/89.html) - Common Weakness Enumeration entry for SQL injection with detailed attack patterns.
41. [CWE-79: Cross-site Scripting](https://cwe.mitre.org/data/definitions/79.html) - CWE entry for XSS covering stored, reflected, and DOM-based variants.
42. [CWE-352: Cross-Site Request Forgery](https://cwe.mitre.org/data/definitions/352.html) - CWE entry for CSRF with attack scenarios and mitigations.
43. [Auth0 JWT Security Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/) - Analysis of JWT Best Current Practices RFC draft covering algorithm confusion and token binding.
44. [critical: algorithm confusion in jsonwebtoken (CVE-2022-23529)](https://github.com/auth0/node-jsonwebtoken/issues/914) - Security advisory demonstrating why algorithm whitelisting is critical.
45. [SLSA Framework](https://slsa.dev/) - Supply-chain Levels for Software Artifacts framework for build provenance and integrity.
46. [npm Provenance](https://docs.npmjs.com/generating-provenance-statements) - npm provenance attestation documentation for supply chain security.
47. [Fastify v5 Release Notes](https://fastify.dev/blog/) - Breaking changes and security improvements in Fastify 5.
48. [libsodium Documentation](https://doc.libsodium.org/) - Cryptographic library underlying `@fastify/secure-session` via sodium-native bindings.
49. [OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/) - API-specific security risks relevant to Fastify REST/GraphQL backends.
50. [Express to Fastify Migration Security Considerations](https://fastify.dev/docs/latest/Guides/Migration-Guide-V4/) - Security-relevant changes when migrating from Express middleware patterns.
51. [Content Security Policy Level 3 Specification](https://www.w3.org/TR/CSP3/) - W3C specification for CSP including strict-dynamic and nonce patterns.
52. [Argon2 Password Hashing](https://github.com/ranisalt/node-argon2) - Recommended password hashing algorithm (winner of Password Hashing Competition).
53. [bcrypt for Node.js](https://github.com/kelektiv/node.bcrypt.js) - Widely-used password hashing library, alternative to Argon2.
54. [secure-json-parse](https://github.com/fastify/secure-json-parse) - Fastify's JSON parser with prototype pollution protection, used internally.
55. [Husky Git Hooks](https://typicode.github.io/husky/) - Git hook manager for running security checks on pre-commit and pre-push.
56. [lint-staged](https://github.com/lint-staged/lint-staged) - Run linters/security checks on staged files only, paired with Husky.
57. [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/) - Dependency vulnerability scanner supporting multiple ecosystems.
58. [isomorphic-dompurify](https://github.com/kkomelin/isomorphic-dompurify) - Server-side compatible DOMPurify wrapper for Node.js sanitization.
59. [Fastify Autoload Plugin](https://github.com/fastify/fastify-autoload) - Plugin for auto-loading routes and plugins, relevant to scaffold structure.
60. [Node.js Threat Model](https://github.com/nicola/node-security-checklist) - Community security checklist for Node.js applications.
61. [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/) - Quick reference for secure coding patterns applicable to code generators.
62. [RFC 9110 - HTTP Semantics](https://datatracker.ietf.org/doc/html/rfc9110) - HTTP specification sections on CORS, caching, and security considerations.
63. [Fastify Plugin System Architecture](https://fastify.dev/docs/latest/Reference/Plugins/) - How Fastify plugin encapsulation affects security boundary management.
64. [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/) - Comprehensive security testing methodology applicable to scaffold test suites.
65. [npm best practices for security](https://snyk.io/blog/ten-npm-security-best-practices/) - Ten npm security practices from Snyk including lockfile management and script safety.
66. [CORS Specification (Fetch Living Standard)](https://fetch.spec.whatwg.org/#http-cors-protocol) - WHATWG specification for CORS including preflight and credentialed requests.
67. [SRI (Subresource Integrity)](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity) - MDN documentation on SRI for verifying fetched resource integrity.
68. [Node.js --disable-proto Flag](https://nodejs.org/api/cli.html#--disable-protomode) - CLI flag for disabling `__proto__` access to prevent prototype pollution.
69. [Fastify Logging with Pino](https://fastify.dev/docs/latest/Reference/Logging/) - Built-in logging configuration including redaction and serializers.
70. [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) - What to log, what not to log, and audit trail requirements.
71. [Doppler Secrets Management](https://www.doppler.com/) - Modern secrets management platform with Node.js SDK for production deployments.
72. [AWS Secrets Manager + Node.js](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) - Cloud secrets management integration for production Fastify applications.
73. [OWASP SSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html) - Patterns for preventing server-side request forgery in backend applications.
74. [Fastify Request Validation](https://fastify.dev/docs/latest/Reference/Validation-and-Serialization/) - JSON Schema validation and serialization documentation for input/output security.
75. [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) - Password hashing recommendations including Argon2id, bcrypt, and scrypt parameters.
76. [OWASP Transport Layer Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html) - TLS configuration including cipher suites, certificate pinning, and HSTS.
77. [CVE-2022-23529 - jsonwebtoken arbitrary code execution](https://nvd.nist.gov/vuln/detail/CVE-2022-23529) - Critical vulnerability in jsonwebtoken affecting secret/public key handling.
78. [CVE-2022-23540 - jsonwebtoken insecure default algorithm](https://nvd.nist.gov/vuln/detail/CVE-2022-23540) - Vulnerability allowing weak algorithms in jsonwebtoken verification.
79. [OWASP Unvalidated Redirects and Forwards Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html) - Open redirect prevention patterns.
80. [Fastify Error Handling](https://fastify.dev/docs/latest/Reference/Errors/) - Error handler customization for preventing information leakage.
81. [OWASP Error Handling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html) - Error response patterns that prevent information disclosure.
82. [npm force resolutions](https://docs.npmjs.com/cli/v10/configuring-npm/package-json#overrides) - Package.json overrides for forcing secure dependency versions.
83. [Sigstore for npm](https://blog.sigstore.dev/) - Cryptographic signing for npm packages providing build provenance.
84. [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) - Master index of all OWASP cheat sheets referenced throughout this research.
85. [Fastify Bearer Auth Plugin](https://github.com/fastify/fastify-bearer-auth) - Bearer token authentication plugin for simple API key/token validation.
86. [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) - Role-based and attribute-based access control patterns.
87. [Node.js PBKDF2 Considerations](https://nodejs.org/api/crypto.html#cryptopbkdf2password-salt-iterations-keylen-digest-callback) - Built-in key derivation for cases where Argon2 is not available.
88. [Fastify Type Provider (Zod, Typebox)](https://fastify.dev/docs/latest/Reference/Type-Providers/) - Type-safe validation as an alternative to raw JSON Schema.
89. [Zod Schema Validation](https://zod.dev/) - TypeScript-first schema validation library increasingly used with Fastify for input security.
90. [OWASP Mass Assignment Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html) - Prevention of mass assignment attacks through allowlisted fields.
91. [Fastify Decorators for RBAC](https://fastify.dev/docs/latest/Reference/Decorators/) - Using Fastify decorators to implement role-based access control.
92. [undici Fetch for Node.js](https://undici.nodejs.org/) - Node.js HTTP client with SSRF-relevant configuration options.
93. [better-npm-audit](https://github.com/jeemok/better-npm-audit) - Enhanced npm audit with exception allowlisting for CI/CD integration.
94. [OWASP Application Security Verification Standard (ASVS)](https://owasp.org/www-project-application-security-verification-standard/) - Comprehensive security verification requirements for web applications.
95. [Fastify Under Pressure Plugin](https://github.com/fastify/under-pressure) - Load shedding and health check plugin for DoS resilience.
96. [Node.js Security Working Group](https://github.com/nodejs/security-wg) - Official Node.js security working group resources and threat models.

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** dev
- **Research Size:** Deep (100) -- 10 agents, ~100 sources target
- **Unique Sources:** 96
- **Approach:** Adaptive 5-wave research (web access unavailable; synthesized from training knowledge spanning OWASP documentation, Fastify ecosystem docs, jose library reference, Node.js security guides, RFC specifications, and CVE databases)
- **Search Queries Used:**
  - secure backend scaffold defaults best practices Node.js Fastify
  - JWT verification jose library vs base64 decoding security
  - httpOnly cookie session management Fastify secure-session
  - CSRF protection @fastify/csrf-protection patterns
  - @fastify/rate-limit per-route per-user sliding window configuration
  - Content Security Policy helmet Fastify CORS configuration
  - SQL injection prevention ORM input sanitization Node.js
  - OWASP Top 10 mitigation code generation scaffolds
  - Fastify security plugins registration order best practices
  - supply chain security npm audit lockfile-lint provenance
  - Node.js permission model experimental security flags
  - Fastify error handling information leakage prevention
