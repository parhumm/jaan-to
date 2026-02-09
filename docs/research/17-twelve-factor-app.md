# The Twelve-Factor App: Modern Software Deployment

> Summary of: `deepresearch/dev-workflow/the-twelve-factor-app-comprehensive-modern-software-deployment.md`

## Key Points

- **Origins**: Developed at Heroku in 2011, remains foundational for cloud-native applications 15 years later
- **I. Codebase**: One repo, many deploys - same code across dev/staging/prod
- **II. Dependencies**: Explicit declaration and isolation - never rely on system packages
- **III. Config**: Store in environment variables, never in code
- **IV. Backing Services**: Treat as attached resources, swappable via config
- **V. Build/Release/Run**: Strict separation with immutable releases
- **VI. Processes**: Stateless, share-nothing - persist data in backing services
- **VII. Port Binding**: Self-contained services export via port
- **VIII. Concurrency**: Scale horizontally via process model
- **IX. Disposability**: Fast startup, graceful shutdown
- **X. Dev/Prod Parity**: Minimize gaps in time, personnel, tools
- **XI. Logs**: Treat as event streams, write to stdout
- **XII. Admin Processes**: Run as one-off tasks in same environment

## Critical Insights

1. **Start with Factor III (Config)** - Environment variables provide immediate security and flexibility benefits
2. **Statelessness (Factor VI) enables everything else** - Horizontal scaling, zero-downtime deploys, disaster recovery
3. **Containers naturally enforce many factors** - Dependency isolation, port binding, statelessness, disposability

## Quick Reference

| Factor | Principle | Modern Implementation |
|--------|-----------|----------------------|
| I. Codebase | One repo, many deploys | Git + branch strategy |
| II. Dependencies | Explicit + isolated | package.json + node_modules |
| III. Config | Environment variables | ConfigMaps/Secrets |
| IV. Backing Services | Attached resources | Connection URLs in config |
| V. Build/Release/Run | Immutable releases | Docker + CI/CD |
| VI. Processes | Stateless | Redis/DB for state |
| VII. Port Binding | Self-contained | EXPOSE + PORT env |
| VIII. Concurrency | Horizontal scaling | Kubernetes HPA |
| IX. Disposability | Fast start/stop | Probes + preStop hooks |
| X. Parity | Same services everywhere | Docker Compose |
| XI. Logs | Event streams | stdout + log aggregation |
| XII. Admin | One-off processes | Kubernetes Jobs |

## Beyond Twelve Factors (Kevin Hoffman, 2016)
- **XIII. API First**: Design API contract before implementation
- **XIV. Telemetry**: Metrics, monitoring, health checks
- **XV. Auth**: Security as integral design concern

## Kubernetes Mapping
- ConfigMaps → Non-sensitive config
- Secrets → Credentials
- Deployments → Immutable releases
- Services → Port binding
- HPA → Concurrency scaling
- Probes → Disposability
- Jobs → Admin processes

