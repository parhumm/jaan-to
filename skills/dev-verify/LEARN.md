# Lessons: dev-verify

> Last updated: 2026-02-14

---

## Better Questions
- Ask about custom health endpoints early — many frameworks use non-standard paths
- Ask if services require authentication for health endpoints
- Ask about internal services (queues, workers) needing separate checks
- Ask "Has the ORM schema been updated since last scaffold?" before build verification
- Ask "Are all service dependencies listed in the manifest?" to catch missing installs

## Edge Cases
- Docker Compose services may use internal ports different from host-mapped ports
- Health endpoints behind reverse proxies may return 200 with wrong body
- Shared-port services (Laravel+Inertia, Go templates) need multiple route checks
- IPv4 vs IPv6 localhost differences across platforms
- Monorepo builds may need per-app type checks — turbo handles this but standalone pnpm doesn't
- Export names can drift between scaffold and service-implement outputs
- Auth-related packages often missing from scaffolds

## Workflow
- Always check port availability BEFORE HTTP requests to avoid long timeouts
- Run type check early before attempting full build — catches most issues faster
- Run docker compose ps before curl to avoid hitting dead containers
- Set curl --max-time to avoid 30+ second hangs on unreachable services
- Commit dependency fixes separately from code fixes for clean git history

## Common Mistakes
- Assuming all services expose HTTP — databases and caches are TCP-only
- Not handling shared ports (one port serves both backend API and frontend)
- Forgetting platform differences for port detection (lsof vs ss)
- Forgetting ORM generate step before type check (Prisma, Drizzle)
- Assuming single-package structure in monorepos
