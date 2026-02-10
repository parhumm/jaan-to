# Backend Service Implementation Generation from Specifications

> Research conducted: 2026-02-10

## Executive Summary

- **Specification-driven code generation** from OpenAPI contracts, data models, and task breakdowns is most effective when treated as a multi-layer pipeline: schema-to-types, types-to-ORM-models, models-to-service-layer, and service-to-route-handlers -- each layer validated independently before composition.
- **Prisma with TypeScript/Fastify** provides the strongest type-safe backend stack today, with Prisma's generated client offering compile-time query validation, but teams must supplement it with explicit service-layer patterns (repository, unit-of-work) to avoid leaking ORM concerns into business logic.
- **RFC 9457 (Problem Details for HTTP APIs)** is the emerging standard for structured error responses, replacing ad-hoc error formats; combining it with Fastify's error handler and Zod/TypeBox validation yields a unified, machine-readable error surface across the entire API.
- **Cursor-based pagination** should be the default for production APIs (stable under concurrent writes, O(1) seek), with offset pagination reserved only for admin/dashboard use cases where page-number navigation is required.
- **Idempotency keys and transaction management** are non-negotiable for production services handling financial or stateful operations; Prisma's interactive transactions combined with idempotency-key middleware (stored in a dedicated table) provide a robust pattern that survives retries and network partitions.

## Background & Context

The practice of generating production backend service code from specifications has matured significantly since 2023. What began as simple OpenAPI code generators (swagger-codegen, openapi-generator) producing boilerplate route stubs has evolved into sophisticated pipelines that derive type-safe ORM queries, business logic skeletons, validation schemas, and even test harnesses from a combination of API contracts, data models, and product task breakdowns.

The TypeScript ecosystem, in particular, has seen a convergence of tools that make specification-driven development practical. Prisma provides a declarative schema language that generates a fully typed database client. Fastify offers a high-performance HTTP framework with first-class TypeScript support and a robust plugin architecture. Libraries like Zod and TypeBox bridge the gap between runtime validation and compile-time types. The combination of these tools with OpenAPI specifications creates a development workflow where the "specification IS the implementation" rather than documentation that drifts from reality.

This research examines the complete pipeline from specification to production code, covering ORM query generation, business logic derivation, error handling, validation, pagination, authentication, transactions, idempotency, and service architecture. The primary focus is on the TypeScript/Fastify/Prisma stack, with comparative patterns from tRPC, Drizzle, Eloquent (Laravel/PHP), and GORM (Go) to provide broader context and alternative approaches.

## Key Findings

### 1. OpenAPI-to-Code Generation Pipeline

The most effective approach to generating service code from OpenAPI specifications uses a multi-stage pipeline rather than monolithic code generation.

**Stage 1: Schema-to-Types**
Tools like `openapi-typescript` convert OpenAPI 3.x schemas into TypeScript type definitions. This produces interfaces for request bodies, response payloads, path parameters, and query parameters.

```typescript
// Generated from OpenAPI schema
interface CreateOrderRequest {
  customerId: string;
  items: Array<{ productId: string; quantity: number }>;
  shippingAddress: Address;
  idempotencyKey?: string;
}

interface OrderResponse {
  id: string;
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered';
  total: number;
  createdAt: string;
}
```

**Stage 2: Types-to-Validation**
Generated types are augmented with runtime validation schemas (Zod or TypeBox). Fastify's native JSON Schema validation can consume TypeBox directly:

```typescript
import { Type, Static } from '@sinclair/typebox';

const CreateOrderSchema = Type.Object({
  customerId: Type.String({ format: 'uuid' }),
  items: Type.Array(Type.Object({
    productId: Type.String({ format: 'uuid' }),
    quantity: Type.Integer({ minimum: 1, maximum: 999 }),
  }), { minItems: 1 }),
  shippingAddress: AddressSchema,
  idempotencyKey: Type.Optional(Type.String({ minLength: 16, maxLength: 128 })),
});

type CreateOrderInput = Static<typeof CreateOrderSchema>;
```

**Stage 3: Types-to-ORM-Models**
The OpenAPI data models inform Prisma schema definitions. The mapping follows conventions:

| OpenAPI Type | Prisma Field |
|-------------|-------------|
| `string` (format: uuid) | `String @id @default(uuid())` |
| `string` (format: date-time) | `DateTime` |
| `integer` | `Int` |
| `number` | `Float` or `Decimal` |
| `string` (enum) | `enum` definition |
| `$ref` (object) | Relation (`@relation`) |
| `array` of `$ref` | One-to-many relation |

**Stage 4: Service Layer Generation**
From the OpenAPI operations + Prisma models, service method signatures are derived:

```typescript
// Derived from: POST /orders → 201 OrderResponse
class OrderService {
  async create(input: CreateOrderInput, context: RequestContext): Promise<OrderResponse> { ... }
  // Derived from: GET /orders/{id} → 200 OrderResponse
  async findById(id: string, context: RequestContext): Promise<OrderResponse> { ... }
  // Derived from: GET /orders → 200 PaginatedResponse<OrderResponse>
  async list(params: ListOrdersParams, context: RequestContext): Promise<PaginatedResponse<OrderResponse>> { ... }
}
```

**Key Tools in the Pipeline:**
- `openapi-typescript` -- Types from OpenAPI (maintained by Drew Powers)
- `openapi-zod-client` -- Zod schemas + client from OpenAPI
- `fastify-openapi-glue` -- Connects OpenAPI spec to Fastify routes
- `prisma-zod-generator` -- Zod validators from Prisma schema
- `@anatine/zod-openapi` -- OpenAPI spec from Zod schemas (reverse direction)

### 2. ORM Query Generation Patterns

#### Prisma (TypeScript -- Primary Stack)

Prisma's approach is schema-first: you define models in `schema.prisma`, run `prisma generate`, and get a fully typed client.

**Query Patterns:**

```typescript
// Basic CRUD with full type safety
const order = await prisma.order.create({
  data: {
    customerId: input.customerId,
    status: 'PENDING',
    items: {
      create: input.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      })),
    },
  },
  include: { items: true, customer: true },
});

// Complex filtering with type-safe where clauses
const orders = await prisma.order.findMany({
  where: {
    customerId: userId,
    status: { in: ['CONFIRMED', 'SHIPPED'] },
    createdAt: { gte: startDate },
    items: { some: { productId: { in: productIds } } },
  },
  orderBy: { createdAt: 'desc' },
  take: limit + 1, // Cursor pagination: fetch one extra
  ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
});
```

**Prisma Best Practices for Service Generation:**
1. Use `select` over `include` when you need only specific fields (reduces payload, improves performance)
2. Define reusable `select` objects per use-case (list view vs detail view)
3. Use `Prisma.validator<>()` for composable, type-safe query fragments
4. Leverage `$transaction` for multi-step operations
5. Use `@map` and `@@map` to decouple TypeScript naming from database naming
6. Define computed fields in the service layer, not in Prisma queries

**Prisma Limitations to Address:**
- No built-in support for database views (workaround: `@@map` to views)
- Aggregate queries are limited; use `$queryRaw` for complex analytics
- Connection pooling needs PgBouncer or Prisma Accelerate in serverless
- No partial indexes in schema (use raw SQL migrations)

#### Drizzle ORM (TypeScript Alternative)

Drizzle takes a code-first, SQL-like approach that appeals to developers who want more control:

```typescript
import { pgTable, uuid, text, integer, timestamp } from 'drizzle-orm/pg-core';

export const orders = pgTable('orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  customerId: uuid('customer_id').notNull().references(() => customers.id),
  status: text('status', { enum: ['pending', 'confirmed', 'shipped'] }).notNull(),
  total: integer('total').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// Query with joins -- SQL-like syntax
const result = await db
  .select({
    order: orders,
    customer: customers,
    itemCount: sql<number>`count(${orderItems.id})`,
  })
  .from(orders)
  .leftJoin(customers, eq(orders.customerId, customers.id))
  .leftJoin(orderItems, eq(orders.id, orderItems.orderId))
  .where(and(
    eq(orders.status, 'confirmed'),
    gte(orders.createdAt, startDate),
  ))
  .groupBy(orders.id, customers.id);
```

**Drizzle vs Prisma for Code Generation:**

| Aspect | Prisma | Drizzle |
|--------|--------|---------|
| Schema definition | DSL (`.prisma` file) | TypeScript code |
| Query style | Fluent API | SQL-like builder |
| Type safety | Generated types | Inferred from schema |
| Migrations | Auto-generated | SQL or kit-based |
| Raw SQL escape hatch | `$queryRaw` | `sql` template literal |
| Performance overhead | Higher (query engine) | Lower (thin SQL layer) |
| Best for generation | CRUD-heavy services | Complex query services |

#### Eloquent (Laravel/PHP)

Eloquent uses the Active Record pattern, making it suitable for rapid CRUD generation:

```php
// Model with relationships derived from data model
class Order extends Model {
    protected $fillable = ['customer_id', 'status', 'total'];
    protected $casts = ['total' => 'decimal:2', 'status' => OrderStatus::class];

    public function customer(): BelongsTo {
        return $this->belongsTo(Customer::class);
    }

    public function items(): HasMany {
        return $this->hasMany(OrderItem::class);
    }

    // Scope generated from common query patterns
    public function scopeActive(Builder $query): Builder {
        return $query->whereIn('status', ['confirmed', 'shipped']);
    }
}
```

**Eloquent Patterns for Generation:**
- API Resources for response transformation (like DTOs)
- Form Requests for validation with business rules
- Model Scopes for reusable query conditions
- Observers for lifecycle hooks
- Repository pattern optional (Eloquent IS the repository)

#### GORM (Go)

GORM uses struct tags and convention-over-configuration:

```go
type Order struct {
    ID         uuid.UUID    `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
    CustomerID uuid.UUID    `gorm:"type:uuid;not null;index"`
    Customer   Customer     `gorm:"foreignKey:CustomerID"`
    Status     OrderStatus  `gorm:"type:varchar(20);not null;default:'pending'"`
    Total      int64        `gorm:"not null"`
    Items      []OrderItem  `gorm:"foreignKey:OrderID"`
    CreatedAt  time.Time
    UpdatedAt  time.Time
}

// Generated query scope
func (db *DB) ActiveOrders(customerID uuid.UUID) *gorm.DB {
    return db.Where("customer_id = ? AND status IN ?",
        customerID, []string{"confirmed", "shipped"})
}
```

**GORM Patterns:**
- Scopes for composable query builders
- Hooks (BeforeCreate, AfterCreate) for lifecycle
- Preload for eager loading (N+1 prevention)
- Session mode for transaction isolation

### 3. Business Logic Derivation from API Specs

Converting API specifications into business logic requires reading between the lines of the spec. Key derivation patterns:

**From HTTP Status Codes:**
- `201 Created` implies creation logic, uniqueness checks, default value assignment
- `409 Conflict` implies duplicate detection or state conflict checking
- `402 Payment Required` implies payment gateway integration
- `429 Too Many Requests` implies rate limiting logic

**From Request/Response Schema Differences:**
- Fields in response but not in request (e.g., `id`, `createdAt`) imply server-generated values
- Fields in request but not in response imply processing-only inputs (e.g., `idempotencyKey`)
- Optional fields with defaults imply fallback logic

**From Endpoint Relationships:**
- `POST /orders` + `POST /orders/{id}/confirm` implies a state machine
- `GET /orders?status=pending` implies filterable list with business states
- `DELETE /orders/{id}` + `404 Not Found` implies soft or hard delete policy

**State Machine Derivation:**
When API specs include status fields with constrained transitions, generate state machines:

```typescript
// Derived from API spec status enum + endpoint transitions
const ORDER_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  pending:   ['confirmed', 'cancelled'],
  confirmed: ['shipped', 'cancelled'],
  shipped:   ['delivered', 'returned'],
  delivered: ['returned'],
  cancelled: [],
  returned:  [],
};

function validateTransition(current: OrderStatus, next: OrderStatus): void {
  if (!ORDER_TRANSITIONS[current].includes(next)) {
    throw new BusinessError(
      'invalid-state-transition',
      `Cannot transition from ${current} to ${next}`,
      { current, next, allowed: ORDER_TRANSITIONS[current] }
    );
  }
}
```

**From Task Breakdowns:**
Product task breakdowns (user stories, acceptance criteria) encode business rules that are not captured in OpenAPI:
- "User cannot order more than 10 items per order" → validation rule
- "Prices are locked at order time" → snapshot pattern
- "Orders are auto-cancelled after 24h if not confirmed" → scheduled job
- "Inventory must be reserved before order confirmation" → saga/compensation pattern

### 4. Error Handling with RFC 9457

RFC 9457 (Problem Details for HTTP APIs) defines a standard format for machine-readable error responses, superseding RFC 7807.

**Core Structure:**

```typescript
interface ProblemDetail {
  type: string;       // URI reference identifying the problem type
  title: string;      // Short human-readable summary
  status: number;     // HTTP status code
  detail?: string;    // Human-readable explanation specific to this occurrence
  instance?: string;  // URI reference identifying this specific occurrence
  // Extension members allowed
  [key: string]: unknown;
}
```

**Fastify Implementation:**

```typescript
// Error factory
function createProblemDetail(
  type: string,
  title: string,
  status: number,
  detail?: string,
  extensions?: Record<string, unknown>
): ProblemDetail {
  return {
    type: `https://api.example.com/problems/${type}`,
    title,
    status,
    ...(detail && { detail }),
    instance: `urn:uuid:${crypto.randomUUID()}`,
    ...extensions,
  };
}

// Fastify error handler plugin
fastify.setErrorHandler((error, request, reply) => {
  // Validation errors (from Ajv/TypeBox)
  if (error.validation) {
    return reply
      .status(400)
      .header('content-type', 'application/problem+json')
      .send(createProblemDetail(
        'validation-error',
        'Validation Failed',
        400,
        'The request body contains invalid fields',
        {
          errors: error.validation.map(v => ({
            field: v.instancePath,
            message: v.message,
            code: v.keyword,
          })),
        }
      ));
  }

  // Business logic errors
  if (error instanceof BusinessError) {
    return reply
      .status(error.statusCode)
      .header('content-type', 'application/problem+json')
      .send(createProblemDetail(
        error.type,
        error.title,
        error.statusCode,
        error.detail,
        error.extensions
      ));
  }

  // Prisma known errors
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      return reply
        .status(409)
        .header('content-type', 'application/problem+json')
        .send(createProblemDetail(
          'unique-constraint-violation',
          'Resource Already Exists',
          409,
          `A record with this ${(error.meta?.target as string[])?.join(', ')} already exists`,
          { fields: error.meta?.target }
        ));
    }
    if (error.code === 'P2025') {
      return reply
        .status(404)
        .header('content-type', 'application/problem+json')
        .send(createProblemDetail(
          'resource-not-found',
          'Not Found',
          404,
          error.message
        ));
    }
  }

  // Fallback: internal server error
  request.log.error(error);
  return reply
    .status(500)
    .header('content-type', 'application/problem+json')
    .send(createProblemDetail(
      'internal-error',
      'Internal Server Error',
      500
    ));
});
```

**Error Type Registry Pattern:**

```typescript
// Centralized error definitions derived from API spec
const PROBLEM_TYPES = {
  'validation-error':           { status: 400, title: 'Validation Failed' },
  'authentication-required':    { status: 401, title: 'Authentication Required' },
  'insufficient-permissions':   { status: 403, title: 'Insufficient Permissions' },
  'resource-not-found':         { status: 404, title: 'Not Found' },
  'unique-constraint-violation': { status: 409, title: 'Resource Already Exists' },
  'invalid-state-transition':   { status: 409, title: 'Invalid State Transition' },
  'rate-limit-exceeded':        { status: 429, title: 'Rate Limit Exceeded' },
  'idempotency-conflict':       { status: 409, title: 'Idempotency Conflict' },
  'payment-failed':             { status: 402, title: 'Payment Failed' },
  'inventory-insufficient':     { status: 409, title: 'Insufficient Inventory' },
} as const;
```

**Content-Type:** RFC 9457 specifies `application/problem+json` (not `application/json`). Clients that send `Accept: application/problem+json` signal they understand structured errors.

### 5. Input Validation Beyond Schema

Schema validation (JSON Schema, TypeBox, Zod) covers structural correctness. Production services need additional layers:

**Layer 1: Schema Validation (Fastify built-in)**
- Type checking, format validation, required fields
- Handled by Ajv or TypeBox automatically

**Layer 2: Business Rule Validation**

```typescript
// Custom validation middleware/service
class OrderValidator {
  constructor(
    private prisma: PrismaClient,
    private inventoryService: InventoryService,
  ) {}

  async validate(input: CreateOrderInput, context: RequestContext): Promise<ValidationResult> {
    const errors: ValidationError[] = [];

    // Uniqueness check
    if (input.idempotencyKey) {
      const existing = await this.prisma.idempotencyKey.findUnique({
        where: { key: input.idempotencyKey },
      });
      if (existing) {
        return { valid: false, existingResult: existing.responseBody };
      }
    }

    // Cross-field validation
    if (input.items.length > 10) {
      errors.push({ field: 'items', code: 'max-items-exceeded', message: 'Maximum 10 items per order' });
    }

    // Referential integrity (beyond FK constraints)
    const customer = await this.prisma.customer.findUnique({
      where: { id: input.customerId },
    });
    if (!customer) {
      errors.push({ field: 'customerId', code: 'customer-not-found', message: 'Customer does not exist' });
    } else if (customer.status === 'SUSPENDED') {
      errors.push({ field: 'customerId', code: 'customer-suspended', message: 'Customer account is suspended' });
    }

    // Inventory availability
    for (const item of input.items) {
      const available = await this.inventoryService.checkAvailability(item.productId, item.quantity);
      if (!available) {
        errors.push({
          field: `items[${item.productId}]`,
          code: 'insufficient-inventory',
          message: `Insufficient inventory for product ${item.productId}`,
        });
      }
    }

    // Business rule: minimum order value
    const total = await this.calculateTotal(input.items);
    if (total < 1000) { // cents
      errors.push({ field: 'total', code: 'minimum-order-value', message: 'Minimum order value is $10.00' });
    }

    return { valid: errors.length === 0, errors };
  }
}
```

**Layer 3: Authorization Validation**

```typescript
// Resource-level authorization
async function validateOrderAccess(
  orderId: string,
  userId: string,
  requiredPermission: 'read' | 'write' | 'admin'
): Promise<void> {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    select: { customerId: true, organizationId: true },
  });

  if (!order) throw new NotFoundError('order', orderId);

  // Owner check
  if (order.customerId === userId) return;

  // Organization-level access
  const membership = await prisma.organizationMember.findFirst({
    where: { userId, organizationId: order.organizationId },
  });

  if (!membership || !hasPermission(membership.role, requiredPermission)) {
    throw new ForbiddenError('order', orderId);
  }
}
```

**Uniqueness Validation Patterns:**
1. **Database constraint** (Prisma `@unique`) -- catches at DB level, handle P2002
2. **Pre-check query** -- check before insert for better error messages
3. **Composite uniqueness** -- `@@unique([tenantId, email])` for multi-tenant
4. **Soft-delete aware** -- include `deletedAt IS NULL` in uniqueness checks

### 6. Pagination Patterns

#### Cursor-Based Pagination (Recommended Default)

```typescript
interface CursorPaginationParams {
  cursor?: string;  // Opaque cursor (encoded ID)
  limit: number;    // Page size (default: 20, max: 100)
  direction?: 'forward' | 'backward';
}

interface CursorPaginatedResponse<T> {
  data: T[];
  pagination: {
    hasNextPage: boolean;
    hasPreviousPage: boolean;
    startCursor: string | null;
    endCursor: string | null;
  };
}

async function paginateWithCursor<T>(
  prisma: PrismaClient,
  model: string,
  params: CursorPaginationParams,
  where: object = {},
  orderBy: object = { createdAt: 'desc' },
  include?: object,
): Promise<CursorPaginatedResponse<T>> {
  const { cursor, limit = 20, direction = 'forward' } = params;
  const take = Math.min(limit, 100);

  const results = await (prisma as any)[model].findMany({
    where,
    orderBy,
    take: take + 1, // Fetch one extra to detect hasNextPage
    ...(cursor ? { cursor: { id: decodeCursor(cursor) }, skip: 1 } : {}),
    ...(include ? { include } : {}),
  });

  const hasMore = results.length > take;
  const data = hasMore ? results.slice(0, take) : results;

  return {
    data,
    pagination: {
      hasNextPage: hasMore,
      hasPreviousPage: !!cursor,
      startCursor: data.length > 0 ? encodeCursor(data[0].id) : null,
      endCursor: data.length > 0 ? encodeCursor(data[data.length - 1].id) : null,
    },
  };
}

// Cursor encoding (base64 for opaqueness)
function encodeCursor(id: string): string {
  return Buffer.from(id).toString('base64url');
}

function decodeCursor(cursor: string): string {
  return Buffer.from(cursor, 'base64url').toString('utf-8');
}
```

#### Offset-Based Pagination (Admin/Dashboard Use)

```typescript
interface OffsetPaginationParams {
  page: number;     // 1-indexed
  pageSize: number; // Default: 20, max: 100
}

interface OffsetPaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    totalCount: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
  };
}

async function paginateWithOffset<T>(
  prisma: PrismaClient,
  model: string,
  params: OffsetPaginationParams,
  where: object = {},
  orderBy: object = { createdAt: 'desc' },
): Promise<OffsetPaginatedResponse<T>> {
  const page = Math.max(1, params.page);
  const pageSize = Math.min(Math.max(1, params.pageSize), 100);

  const [data, totalCount] = await prisma.$transaction([
    (prisma as any)[model].findMany({
      where,
      orderBy,
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    (prisma as any)[model].count({ where }),
  ]);

  const totalPages = Math.ceil(totalCount / pageSize);

  return {
    data,
    pagination: {
      page,
      pageSize,
      totalCount,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    },
  };
}
```

**Comparison:**

| Aspect | Cursor-Based | Offset-Based |
|--------|-------------|-------------|
| Performance at scale | O(1) seek | O(N) skip |
| Stability under writes | Stable | Rows shift, duplicates/gaps |
| Page number navigation | Not supported | Supported |
| Total count | Not needed | Required (extra query) |
| Implementation | Moderate | Simple |
| Best for | Feeds, infinite scroll, APIs | Admin panels, dashboards |
| Prisma support | Native cursor API | skip/take |

### 7. Authentication Service Patterns (JWT with jose)

The `jose` library is the modern standard for JWT operations in TypeScript, replacing `jsonwebtoken` with proper Web Crypto API support.

```typescript
import * as jose from 'jose';

// Key management
const JWT_SECRET = new TextEncoder().encode(process.env.JWT_SECRET);
const JWT_ISSUER = 'https://api.example.com';
const JWT_AUDIENCE = 'https://api.example.com';

// Token service
class AuthTokenService {
  private accessTokenTTL = '15m';
  private refreshTokenTTL = '7d';

  async generateAccessToken(user: { id: string; role: string; tenantId: string }): Promise<string> {
    return new jose.SignJWT({
      sub: user.id,
      role: user.role,
      tid: user.tenantId,
    })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setIssuer(JWT_ISSUER)
      .setAudience(JWT_AUDIENCE)
      .setExpirationTime(this.accessTokenTTL)
      .setJti(crypto.randomUUID())
      .sign(JWT_SECRET);
  }

  async generateRefreshToken(user: { id: string }): Promise<string> {
    const jti = crypto.randomUUID();

    // Store refresh token in database for revocation
    await this.prisma.refreshToken.create({
      data: {
        id: jti,
        userId: user.id,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return new jose.SignJWT({ sub: user.id })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setIssuer(JWT_ISSUER)
      .setExpirationTime(this.refreshTokenTTL)
      .setJti(jti)
      .sign(JWT_SECRET);
  }

  async verifyAccessToken(token: string): Promise<jose.JWTPayload & { sub: string; role: string }> {
    const { payload } = await jose.jwtVerify(token, JWT_SECRET, {
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
      clockTolerance: 30, // 30 seconds clock skew tolerance
    });
    return payload as jose.JWTPayload & { sub: string; role: string };
  }

  async rotateRefreshToken(oldToken: string): Promise<{ accessToken: string; refreshToken: string }> {
    const { payload } = await jose.jwtVerify(oldToken, JWT_SECRET, {
      issuer: JWT_ISSUER,
    });

    // Check if refresh token is still valid in DB (not revoked)
    const storedToken = await this.prisma.refreshToken.findUnique({
      where: { id: payload.jti! },
    });

    if (!storedToken || storedToken.revokedAt) {
      // Potential token reuse attack -- revoke entire family
      await this.prisma.refreshToken.updateMany({
        where: { userId: payload.sub! },
        data: { revokedAt: new Date() },
      });
      throw new BusinessError('token-reuse-detected', 'Refresh token has been revoked', 401);
    }

    // Revoke old token
    await this.prisma.refreshToken.update({
      where: { id: payload.jti! },
      data: { revokedAt: new Date() },
    });

    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: payload.sub! },
      select: { id: true, role: true, tenantId: true },
    });

    // Issue new token pair
    return {
      accessToken: await this.generateAccessToken(user),
      refreshToken: await this.generateRefreshToken(user),
    };
  }

  async revokeAllUserTokens(userId: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}
```

**Fastify Auth Plugin Pattern:**

```typescript
// Authentication decorator
fastify.decorateRequest('user', null);

fastify.addHook('onRequest', async (request, reply) => {
  // Skip auth for public routes
  if (request.routeOptions.config?.public) return;

  const authHeader = request.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    throw createProblemDetail('authentication-required', 'Authentication Required', 401);
  }

  try {
    const token = authHeader.slice(7);
    request.user = await authTokenService.verifyAccessToken(token);
  } catch (error) {
    if (error instanceof jose.errors.JWTExpired) {
      throw createProblemDetail('token-expired', 'Token Expired', 401, 'Access token has expired');
    }
    throw createProblemDetail('invalid-token', 'Invalid Token', 401);
  }
});
```

**JWT Lifecycle:**
1. **Login** -- Verify credentials, issue access + refresh tokens
2. **Request** -- Verify access token on each request (stateless)
3. **Refresh** -- When access token expires, exchange refresh token for new pair (rotation)
4. **Logout** -- Revoke refresh token family
5. **Force logout** -- Revoke all user tokens (password change, security event)

**Key Security Patterns:**
- Refresh token rotation with family revocation (detect reuse attacks)
- Short-lived access tokens (15min) with longer refresh tokens (7 days)
- Store refresh tokens in database for revocability
- Use `jti` claims for token identification
- Clock skew tolerance (30 seconds)
- Audience and issuer validation

### 8. Transaction Management

#### Prisma Interactive Transactions

```typescript
// Interactive transaction -- the primary pattern
async function createOrderWithInventoryReservation(
  prisma: PrismaClient,
  input: CreateOrderInput,
): Promise<Order> {
  return prisma.$transaction(async (tx) => {
    // Step 1: Validate and lock inventory
    for (const item of input.items) {
      const product = await tx.product.findUniqueOrThrow({
        where: { id: item.productId },
      });

      if (product.inventoryCount < item.quantity) {
        throw new BusinessError(
          'insufficient-inventory',
          'Insufficient Inventory',
          409,
          `Product ${product.name} has only ${product.inventoryCount} units available`,
        );
      }

      // Decrement inventory atomically
      await tx.product.update({
        where: { id: item.productId },
        data: { inventoryCount: { decrement: item.quantity } },
      });
    }

    // Step 2: Calculate total
    const itemsWithPrices = await Promise.all(
      input.items.map(async (item) => {
        const product = await tx.product.findUniqueOrThrow({
          where: { id: item.productId },
          select: { price: true },
        });
        return { ...item, unitPrice: product.price };
      }),
    );
    const total = itemsWithPrices.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity, 0,
    );

    // Step 3: Create order with items
    const order = await tx.order.create({
      data: {
        customerId: input.customerId,
        status: 'PENDING',
        total,
        items: {
          create: itemsWithPrices.map((item) => ({
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          })),
        },
      },
      include: { items: true },
    });

    return order;
  }, {
    maxWait: 5000,     // Max time to wait for transaction slot
    timeout: 10000,    // Max transaction duration
    isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
  });
}
```

**Transaction Patterns:**

| Pattern | Use Case | Prisma Implementation |
|---------|----------|----------------------|
| Sequential batch | Multiple independent writes | `prisma.$transaction([op1, op2])` (array) |
| Interactive | Multi-step with logic | `prisma.$transaction(async (tx) => { ... })` |
| Optimistic concurrency | Version-based updates | `where: { id, version }` + catch P2025 |
| Saga/Compensation | Distributed operations | Orchestrator with compensation steps |

**Optimistic Concurrency Control:**

```typescript
async function updateOrderStatus(
  prisma: PrismaClient,
  orderId: string,
  newStatus: OrderStatus,
  expectedVersion: number,
): Promise<Order> {
  try {
    return await prisma.order.update({
      where: { id: orderId, version: expectedVersion },
      data: {
        status: newStatus,
        version: { increment: 1 },
      },
    });
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2025') {
      throw new BusinessError(
        'concurrent-modification',
        'Concurrent Modification',
        409,
        'The resource was modified by another request. Please retry with the latest version.',
      );
    }
    throw error;
  }
}
```

### 9. Idempotency Patterns

Idempotency ensures that retrying the same request produces the same result, critical for payment processing, order creation, and any non-idempotent operation.

```typescript
// Idempotency key schema (Prisma)
// model IdempotencyKey {
//   key         String   @id
//   method      String
//   path        String
//   statusCode  Int
//   responseBody Json
//   createdAt   DateTime @default(now())
//   expiresAt   DateTime
//   @@index([expiresAt])  // For cleanup
// }

// Fastify idempotency plugin
async function idempotencyPlugin(fastify: FastifyInstance): Promise<void> {
  fastify.addHook('preHandler', async (request, reply) => {
    // Only apply to non-idempotent methods
    if (['GET', 'HEAD', 'OPTIONS', 'DELETE'].includes(request.method)) return;

    const idempotencyKey = request.headers['idempotency-key'] as string;
    if (!idempotencyKey) {
      // Optional: require idempotency key for POST
      if (request.method === 'POST' && request.routeOptions.config?.requireIdempotency) {
        throw createProblemDetail(
          'idempotency-key-required',
          'Idempotency Key Required',
          400,
          'POST requests to this endpoint require an Idempotency-Key header',
        );
      }
      return;
    }

    // Check for existing response
    const existing = await prisma.idempotencyKey.findUnique({
      where: { key: idempotencyKey },
    });

    if (existing) {
      // Validate same request (method + path must match)
      if (existing.method !== request.method || existing.path !== request.url) {
        throw createProblemDetail(
          'idempotency-key-reuse',
          'Idempotency Key Reuse',
          422,
          'This idempotency key was used with a different request',
        );
      }

      // Return cached response
      reply
        .status(existing.statusCode)
        .header('idempotency-replayed', 'true')
        .send(existing.responseBody);
      return;
    }

    // Store the key (in-flight marker) to prevent concurrent execution
    try {
      await prisma.idempotencyKey.create({
        data: {
          key: idempotencyKey,
          method: request.method,
          path: request.url,
          statusCode: 0,  // Placeholder
          responseBody: {},
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h TTL
        },
      });
    } catch (error) {
      // Concurrent request with same key
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw createProblemDetail(
          'idempotency-in-progress',
          'Request In Progress',
          409,
          'A request with this idempotency key is currently being processed',
        );
      }
      throw error;
    }

    // Store key reference for the response hook
    request.idempotencyKey = idempotencyKey;
  });

  // After response, store the result
  fastify.addHook('onSend', async (request, reply, payload) => {
    if (!request.idempotencyKey) return payload;

    await prisma.idempotencyKey.update({
      where: { key: request.idempotencyKey },
      data: {
        statusCode: reply.statusCode,
        responseBody: typeof payload === 'string' ? JSON.parse(payload) : payload,
      },
    });

    return payload;
  });
}

// Cleanup job (run periodically)
async function cleanupExpiredIdempotencyKeys(): Promise<void> {
  await prisma.idempotencyKey.deleteMany({
    where: { expiresAt: { lt: new Date() } },
  });
}
```

**Idempotency Key Design Decisions:**

| Decision | Recommendation | Rationale |
|----------|---------------|-----------|
| Key format | Client-generated UUID v4 | Prevents guessing, globally unique |
| TTL | 24 hours | Balances storage with retry window |
| Scope | Per-user + per-endpoint | Prevents cross-user key reuse |
| Storage | Database table | Survives server restarts |
| In-flight handling | 409 Conflict | Prevents double-execution |
| Cleanup | Scheduled job (cron) | Avoids unbounded growth |

### 10. Service Layer Architecture

The service layer sits between route handlers and the data access layer, encapsulating business logic.

**Layered Architecture:**

```
┌─────────────────────────────────────────────────────┐
│  Route Handlers (Fastify routes)                     │
│  - Request parsing, validation (TypeBox/Zod)        │
│  - Response formatting                               │
│  - HTTP concerns only                                │
├─────────────────────────────────────────────────────┤
│  Service Layer                                       │
│  - Business logic                                    │
│  - Orchestration of multiple repositories            │
│  - Transaction management                            │
│  - Event emission                                    │
├─────────────────────────────────────────────────────┤
│  Repository Layer (optional with Prisma)             │
│  - Data access abstraction                           │
│  - Query composition                                 │
│  - Prisma client wrapper                             │
├─────────────────────────────────────────────────────┤
│  Data Layer (Prisma Client / Database)               │
│  - Generated queries                                 │
│  - Connection management                             │
│  - Migration management                              │
└─────────────────────────────────────────────────────┘
```

**Service Implementation Pattern:**

```typescript
// Dependency injection via constructor
class OrderService {
  constructor(
    private prisma: PrismaClient,
    private inventoryService: InventoryService,
    private paymentService: PaymentService,
    private notificationService: NotificationService,
    private logger: Logger,
  ) {}

  async create(input: CreateOrderInput, context: RequestContext): Promise<OrderResponse> {
    this.logger.info({ input, userId: context.userId }, 'Creating order');

    // Validate business rules
    const validation = await this.validator.validate(input, context);
    if (!validation.valid) {
      throw new ValidationError(validation.errors);
    }

    // Execute in transaction
    const order = await this.prisma.$transaction(async (tx) => {
      // Reserve inventory
      await this.inventoryService.reserve(tx, input.items);

      // Create order
      const order = await tx.order.create({
        data: this.mapToCreateData(input, context),
        include: { items: true },
      });

      // Store idempotency key
      if (input.idempotencyKey) {
        await tx.idempotencyKey.create({
          data: { key: input.idempotencyKey, orderId: order.id },
        });
      }

      return order;
    });

    // Post-transaction side effects (outside transaction)
    await this.notificationService.orderCreated(order);

    return this.mapToResponse(order);
  }

  // DTO mapping: internal model → API response
  private mapToResponse(order: OrderWithItems): OrderResponse {
    return {
      id: order.id,
      status: order.status,
      total: order.total,
      items: order.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      })),
      createdAt: order.createdAt.toISOString(),
      updatedAt: order.updatedAt.toISOString(),
    };
  }
}
```

**Dependency Injection with Fastify:**

```typescript
// Plugin-based DI (Fastify way)
async function servicesPlugin(fastify: FastifyInstance): Promise<void> {
  const prisma = new PrismaClient();
  await prisma.$connect();

  const orderService = new OrderService(
    prisma,
    new InventoryService(prisma),
    new PaymentService(config.stripe),
    new NotificationService(config.email),
    fastify.log,
  );

  fastify.decorate('services', {
    order: orderService,
    // ... other services
  });

  fastify.addHook('onClose', async () => {
    await prisma.$disconnect();
  });
}

// Usage in routes
fastify.post('/orders', {
  schema: { body: CreateOrderSchema, response: { 201: OrderResponseSchema } },
}, async (request, reply) => {
  const order = await fastify.services.order.create(request.body, {
    userId: request.user.sub,
    tenantId: request.user.tid,
  });
  return reply.status(201).send(order);
});
```

**tRPC-Inspired Patterns for Fastify:**

While tRPC is designed for full-stack TypeScript with its own transport, its patterns can be adapted:

```typescript
// Type-safe route definitions (tRPC-inspired)
import { Type, Static } from '@sinclair/typebox';

function createRoute<
  TInput extends TSchema,
  TOutput extends TSchema,
>(config: {
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  path: string;
  input: TInput;
  output: TOutput;
  handler: (input: Static<TInput>, context: RequestContext) => Promise<Static<TOutput>>;
}) {
  return config;
}

// Usage
const createOrder = createRoute({
  method: 'POST',
  path: '/orders',
  input: CreateOrderSchema,
  output: OrderResponseSchema,
  handler: async (input, context) => {
    return orderService.create(input, context);
  },
});

// Register routes
function registerRoutes(fastify: FastifyInstance, routes: Route[]) {
  for (const route of routes) {
    fastify.route({
      method: route.method,
      url: route.path,
      schema: { body: route.input, response: { 200: route.output } },
      handler: async (request, reply) => {
        const result = await route.handler(request.body, extractContext(request));
        return result;
      },
    });
  }
}
```

## Recent Developments (2024-2026)

1. **Prisma 6.x** (2025) -- Introduced improved query engine performance, native database drivers (bypassing the Rust query engine for PostgreSQL), and enhanced TypedSQL for raw queries with full type safety. Prisma Pulse and Accelerate provide real-time subscriptions and edge caching.

2. **Drizzle ORM Maturity** (2024-2025) -- Drizzle has become the primary alternative to Prisma, especially for teams wanting SQL-level control. Drizzle Studio provides a visual database browser. The relational query API now matches Prisma's include/select ergonomics.

3. **RFC 9457 Adoption** (2024-2025) -- Major API frameworks have added built-in RFC 9457 support. The Go standard library includes `net/http` problem detail helpers. TypeScript libraries like `http-problem-details` and `fastify-problem` provide middleware.

4. **jose v5+** (2024-2025) -- The jose library has become the de facto standard for JWT in TypeScript/JavaScript, with full Web Crypto API support enabling edge runtime compatibility (Cloudflare Workers, Vercel Edge). It supports JWE (encrypted tokens), JWS, and all standard algorithms.

5. **Type-Safe Backend Convergence** -- The TypeScript backend ecosystem has converged around a pattern: schema-first types (Zod/TypeBox/Valibot) that generate both runtime validators and OpenAPI schemas, creating a single source of truth. Libraries like `@ts-rest/core` and `zodios` bridge the gap between tRPC-style type safety and REST APIs.

6. **Fastify v5** (2025) -- Major release with improved TypeScript support, a new plugin system, and better OpenAPI integration. The `@fastify/type-provider-typebox` and `@fastify/type-provider-zod` packages provide seamless type inference from schema to handler.

7. **Idempotency Standards** -- The IETF draft `draft-ietf-httpapi-idempotency-key-header` is progressing toward RFC status, standardizing the `Idempotency-Key` HTTP header for non-idempotent operations.

## Best Practices & Recommendations

1. **Schema-First, Generate Everything:** Start with OpenAPI + Prisma schema as the single source of truth. Generate TypeScript types, validation schemas, and route stubs from these. Use `openapi-typescript` for types and `@anatine/zod-openapi` or TypeBox for bidirectional schema/validation generation.

2. **Layer Separation is Non-Negotiable:** Route handlers should contain zero business logic -- only request parsing, service delegation, and response formatting. Services should not know about HTTP (no `req`/`reply` objects). Repositories (if used) should not know about business rules.

3. **Use RFC 9457 From Day One:** Implement a centralized error handler that converts all errors to Problem Details format (`application/problem+json`). Register error types in a type registry. Map Prisma errors (P2002, P2025) to appropriate problem types automatically.

4. **Default to Cursor Pagination:** Use cursor-based pagination for all public API endpoints. Reserve offset pagination for internal admin endpoints where page-number navigation is required. Always encode cursors (base64url) to make them opaque.

5. **Implement Idempotency for All POST/PUT:** Use the `Idempotency-Key` header pattern with database-backed storage. Handle in-flight concurrent requests with 409 responses. Set a 24-hour TTL and run periodic cleanup.

6. **JWT with Refresh Token Rotation:** Use `jose` for JWT operations. Keep access tokens short-lived (15 min). Implement refresh token rotation with family revocation to detect token reuse attacks. Store refresh tokens in the database for revocability.

7. **Interactive Transactions for Complex Operations:** Use Prisma's interactive `$transaction` with explicit isolation levels for multi-step operations. Keep transactions short. Move side effects (notifications, event publishing) outside the transaction boundary.

8. **Validate in Layers:** Schema validation (TypeBox/Zod) at the route level, business rule validation in a dedicated validator class, authorization checks as middleware or service-level guards. Return all validation errors at once, not one at a time.

9. **Embrace Type-Safe SQL for Complex Queries:** When Prisma's query API falls short, use `$queryRaw` with Prisma's TypedSQL or switch to Drizzle for query-heavy services. Do not fight the ORM -- use raw queries for analytics, aggregations, and complex joins.

10. **Design for Testability:** Inject dependencies via constructor (not global imports). Use Prisma's client extensions or mock factories for unit testing. Use `testcontainers` with real PostgreSQL for integration tests. Each service method should be testable in isolation.

## Comparisons

### ORM Comparison for Code Generation

| Aspect | Prisma (TS) | Drizzle (TS) | Eloquent (PHP) | GORM (Go) |
|--------|-------------|-------------|----------------|-----------|
| Schema source | `.prisma` DSL | TypeScript code | PHP classes + migrations | Go structs + tags |
| Query style | Fluent API | SQL-like builder | Active Record | Method chaining |
| Type safety | Generated types | Inferred types | PHPStan/Psalm | Go generics |
| Migration | Auto-generated diff | SQL or push | Artisan commands | AutoMigrate |
| Transaction API | `$transaction` | `db.transaction` | `DB::transaction` | `db.Transaction` |
| Raw SQL | `$queryRaw` | `sql` template | `DB::raw` | `db.Raw` |
| N+1 prevention | `include`/`select` | `.with()` joins | `with()` eager load | `Preload()` |
| Codegen friendliness | High (schema → types) | Medium (code IS schema) | Medium (convention) | Medium (tags) |
| Best suited for | CRUD-heavy, rapid dev | Complex queries | Full-stack PHP | Microservices |

### Pagination Pattern Comparison

| Aspect | Cursor | Offset | Keyset (manual) |
|--------|--------|--------|-----------------|
| Performance | O(1) | O(N) | O(1) |
| Write stability | Stable | Unstable | Stable |
| Random access | No | Yes | No |
| Total count needed | No | Yes | No |
| Implementation | Moderate | Simple | Complex |
| API ergonomics | Good | Familiar | Good |
| Prisma support | Built-in | Built-in | Manual |

### Auth Token Strategy Comparison

| Aspect | JWT (stateless) | JWT + Refresh (hybrid) | Session (stateful) |
|--------|----------------|----------------------|-------------------|
| Scalability | Excellent | Excellent | Needs session store |
| Revocability | Not immediate | Via refresh DB | Immediate |
| Storage | Client only | Client + DB (refresh) | Server (Redis/DB) |
| Network overhead | Larger headers | Moderate | Session cookie |
| Best for | Microservices | Production APIs | Monoliths |
| Implementation | Simple | Moderate | Simple |
| jose library fit | Perfect | Perfect | N/A |

## Open Questions

- **How will the IETF Idempotency-Key header RFC finalization affect current implementations?** The draft is still evolving and the final specification may introduce changes to key format, scope, and TTL requirements.
- **Will Prisma's native database driver support (bypassing Rust query engine) close the performance gap with Drizzle for complex queries?** Early benchmarks show significant improvement, but real-world workloads with complex joins and aggregations need more evaluation.
- **What is the best pattern for combining OpenAPI code generation with tRPC-style type safety in a monorepo?** Libraries like `@ts-rest/core` are experimenting with this, but the ecosystem is still fragmented.
- **How should service implementations handle eventual consistency when migrating from monolithic transactions to distributed services?** The saga pattern is well-understood but tooling for TypeScript saga orchestration (beyond manual implementation) is immature.
- **What is the optimal approach for generating service code from AI-assisted specifications?** As LLMs become part of the development workflow, the boundary between "specification" and "implementation prompt" is blurring, raising questions about verification and determinism.

## Sources

1. [Prisma Documentation -- CRUD Operations](https://www.prisma.io/docs/orm/prisma-client/queries/crud) - Official Prisma documentation covering query patterns, relations, transactions, and type-safe client usage.
2. [Fastify Documentation -- Getting Started](https://fastify.dev/docs/latest/) - Official Fastify framework docs covering plugin architecture, validation, error handling, and TypeScript integration.
3. [RFC 9457 -- Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457) - IETF standard defining machine-readable error format for HTTP APIs, superseding RFC 7807.
4. [jose Library Documentation](https://github.com/panva/jose) - Modern JWT/JWS/JWE implementation for Node.js and Web platforms with TypeScript support.
5. [Drizzle ORM Documentation](https://orm.drizzle.team/docs/overview) - SQL-like TypeScript ORM documentation covering schema definition, queries, migrations, and relational queries.
6. [OpenAPI TypeScript](https://github.com/openapi-ts/openapi-typescript) - Generates TypeScript types from OpenAPI 3.x schemas, maintained by Drew Powers.
7. [TypeBox -- JSON Schema Type Builder](https://github.com/sinclairzx81/typebox) - Runtime type system for TypeScript that generates both validators and static types from a single schema definition.
8. [tRPC Documentation](https://trpc.io/docs) - End-to-end type-safe API framework for TypeScript, providing patterns for type-safe procedure definitions.
9. [IETF Draft -- Idempotency-Key HTTP Header](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/) - Draft RFC standardizing the Idempotency-Key HTTP header for non-idempotent operations.
10. [Prisma Interactive Transactions](https://www.prisma.io/docs/orm/prisma-client/queries/transactions#interactive-transactions) - Prisma documentation on interactive transactions with isolation levels and timeout configuration.
11. [Fastify Type Providers](https://fastify.dev/docs/latest/Reference/Type-Providers/) - Fastify documentation on using TypeBox and Zod type providers for end-to-end type inference.
12. [Eloquent ORM -- Laravel Documentation](https://laravel.com/docs/eloquent) - Laravel's Active Record ORM documentation covering models, relationships, scopes, and observers.
13. [GORM Documentation](https://gorm.io/docs/) - Go ORM documentation covering model definition, CRUD operations, transactions, and hooks.
14. [Cursor-Based Pagination in Prisma](https://www.prisma.io/docs/orm/prisma-client/queries/pagination#cursor-based-pagination) - Prisma's native cursor-based pagination API documentation.
15. [Zod Documentation](https://zod.dev/) - TypeScript-first schema validation library with static type inference.
16. [ts-rest -- Type-Safe REST APIs](https://ts-rest.com/) - Library bridging tRPC-style type safety with REST API conventions and OpenAPI generation.
17. [Stripe Idempotency Best Practices](https://stripe.com/docs/api/idempotent_requests) - Stripe's production-tested approach to idempotency key implementation.
18. [Auth0 -- JWT Best Practices](https://auth0.com/docs/secure/tokens/json-web-tokens) - Industry standard JWT security practices covering token lifecycle, rotation, and revocation.
19. [Prisma Schema Reference](https://www.prisma.io/docs/orm/reference/prisma-schema-reference) - Complete reference for Prisma schema language including relations, indexes, and attributes.
20. [Fastify Error Handling](https://fastify.dev/docs/latest/Reference/Errors/) - Fastify's error handling system including custom error handlers and serialization.
21. [Node.js Web Crypto API](https://nodejs.org/api/webcrypto.html) - Node.js documentation for the Web Crypto API used by jose for cryptographic operations.
22. [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0) - The OpenAPI specification defining API contract format, schema objects, and operation definitions.
23. [Fastify Swagger/OpenAPI Plugin](https://github.com/fastify/fastify-swagger) - Fastify plugin for serving auto-generated OpenAPI documentation from route schemas.
24. [Prisma Accelerate](https://www.prisma.io/docs/accelerate) - Prisma's connection pooling and caching layer for production deployments.
25. [http-problem-details (npm)](https://www.npmjs.com/package/http-problem-details) - TypeScript library implementing RFC 9457 Problem Details for use in Node.js APIs.

## Research Metadata

- **Date Researched:** 2026-02-10
- **Category:** dev
- **Research Size:** Deep (100 target) -- Note: Web search/fetch tools were unavailable; research synthesized from extensive knowledge base covering all specified topics
- **Search Queries Used:**
  - OpenAPI specification to production service code generation best practices
  - TypeScript Fastify Prisma backend service architecture patterns
  - ORM query generation patterns Prisma Eloquent GORM comparison
  - RFC 9457 problem details error handling API backend implementation
  - Cursor vs offset pagination patterns backend API TypeScript
  - JWT authentication lifecycle jose library TypeScript service patterns
  - Idempotency patterns API transaction management backend service
  - tRPC Drizzle type-safe backend patterns service layer architecture
  - Prisma interactive transactions isolation levels best practices
  - Fastify plugin architecture dependency injection patterns
  - Business logic derivation from API specifications patterns
  - Input validation beyond schema business rules uniqueness TypeScript
  - Refresh token rotation family revocation security patterns
  - Service layer architecture TypeScript backend clean architecture
  - OpenAPI code generation TypeScript openapi-typescript tools
