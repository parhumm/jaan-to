---
title: "DEVOPS Skills (1)"
sidebar_position: 9
---

# DEVOPS Skills (1)

> Part of [Role Skills Catalog](../role-skills.md) | Phase 4

**Chain**: project-assemble + sec-audit-remediate --> infra-scaffold

## Userflow Schema

```mermaid
flowchart TD
    jaan-to-dev-project-assemble["dev-project-assemble<br>DEV: project-assemble"] --> jaan-to-devops-infra-scaffold["devops-infra-scaffold<br>Infra Scaffold<br>CI/CD + Docker + deploy configs"]
    jaan-to-sec-audit-remediate["sec-audit-remediate<br>SEC: audit-remediate"] --> jaan-to-devops-infra-scaffold["devops-infra-scaffold<br>Infra Scaffold<br>CI/CD + Docker + deploy configs"]

    style jaan-to-dev-project-assemble fill:#f0f0f0,stroke:#999
    style jaan-to-sec-audit-remediate fill:#f0f0f0,stroke:#999
```

**Legend**: Solid = internal | Dashed = cross-role exit | Gray nodes = other roles

### ✅ /devops-infra-scaffold

- **Logical**: `devops-infra-scaffold`
- **Description**: Generate CI/CD workflows, Dockerfiles, and deployment configs from tech stack
- **Quick Win**: Yes - structured config generation
- **Key Points**:
  - CI/CD pipelines (GitHub Actions / GitLab CI) with lint, test, build, deploy stages
  - Multi-stage Dockerfiles per stack (Node.js, PHP, Go)
  - docker-compose for local dev, platform-specific deployment configs
- **→ Next**: —
- **MCP Required**: None
- **Input**: [tech.md] or interactive
- **Output**: `$JAAN_OUTPUTS_DIR/devops/infra-scaffold/{id}-{slug}/`
