# devops-deploy-activate — Reference Material

> Extracted reference tables, code templates, and patterns for the `devops-deploy-activate` skill.
> This file is loaded by `devops-deploy-activate` SKILL.md via inline pointers.
> Do not duplicate content back into SKILL.md.

---

## GitHub Actions SHA Pinning

### Resolution Process

Resolve mutable tags to immutable SHA digests for supply chain security:

**Step 1**: Parse action reference from workflow YAML:
```yaml
# Before
- uses: actions/checkout@v4
```

**Step 2**: Resolve tag to SHA using GitHub API:
```bash
# Get the commit SHA for a tag
gh api repos/actions/checkout/git/ref/tags/v4 --jq '.object.sha'

# For tags pointing to tag objects (not commits), dereference:
gh api repos/actions/checkout/git/tags/{tag_sha} --jq '.object.sha'
```

**Step 3**: Replace in workflow:
```yaml
# After
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4
```

### Common Actions to Pin

| Action | Current Tag | Purpose |
|--------|------------|---------|
| `actions/checkout` | `v4` | Repository checkout |
| `actions/setup-node` | `v4` | Node.js environment |
| `actions/cache` | `v4` | Dependency caching |
| `docker/setup-buildx-action` | `v3` | Docker Buildx |
| `docker/build-push-action` | `v5` | Docker build + push |
| `docker/login-action` | `v3` | Container registry auth |
| `github/codeql-action/upload-sarif` | `v3` | SARIF security upload |
| `dorny/paths-filter` | `v3` | Monorepo path filtering |

### Handling Organization Actions

For org-scoped actions (e.g., `my-org/my-action@v1`):
```bash
gh api repos/my-org/my-action/git/ref/tags/v1 --jq '.object.sha'
```

If the tag does not exist (uses branch reference):
```bash
gh api repos/my-org/my-action/git/ref/heads/main --jq '.object.sha'
```

---

## Platform CLI Provisioning

### Railway

**Prerequisites**: `railway` CLI installed, authenticated via `railway login`

**Setup sequence**:
```bash
# 1. Create project
railway init

# 2. Link to repository
railway link

# 3. Set environment variables
railway variables set DATABASE_URL="postgresql://..."
railway variables set JWT_SECRET="..."
railway variables set NODE_ENV="production"

# 4. Configure deployment
railway up

# 5. Verify
railway status
railway logs --tail 50
```

**Error handling**:
| Exit Code | Meaning | Recovery |
|-----------|---------|----------|
| 0 | Success | Continue |
| 1 | Auth error | Re-run `railway login` |
| 2 | Project not found | Re-run `railway init` |

### Vercel

**Prerequisites**: `vercel` CLI installed, authenticated via `vercel login`

**Setup sequence**:
```bash
# 1. Link to project
vercel link

# 2. Set environment variables (per environment)
vercel env add DATABASE_URL production
vercel env add NEXT_PUBLIC_API_URL production

# 3. Configure project settings
vercel project settings --build-command "pnpm build"
vercel project settings --output-directory ".next"

# 4. Deploy preview
vercel

# 5. Deploy production
vercel --prod
```

**Preview deployments**: Automatic on PR creation when GitHub integration is connected.

### Fly.io

**Prerequisites**: `fly` CLI installed, authenticated via `fly auth login`

**Setup sequence**:
```bash
# 1. Launch app (creates fly.toml)
fly launch --no-deploy

# 2. Set secrets
fly secrets set DATABASE_URL="postgresql://..."
fly secrets set JWT_SECRET="..."

# 3. Create PostgreSQL (if needed)
fly postgres create --name myapp-db
fly postgres attach myapp-db

# 4. Deploy
fly deploy

# 5. Verify
fly status
fly logs
```

---

## Secret Management Patterns

### Per-Platform Secret Requirements

| Platform | Secrets Needed | Where to Set |
|----------|---------------|-------------|
| GitHub Actions | `DOCKER_USERNAME`, `DOCKER_PASSWORD` (or GHCR token) | `gh secret set` |
| Vercel | `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` | `gh secret set` |
| Railway | `RAILWAY_TOKEN` | `gh secret set` |
| Fly.io | `FLY_API_TOKEN` | `gh secret set` |
| Turborepo | `TURBO_TOKEN`, `TURBO_TEAM` | `gh secret set` |

### Secret Naming Conventions

| Pattern | Example | Use |
|---------|---------|-----|
| `{SERVICE}_{TYPE}` | `DATABASE_URL` | Service connection strings |
| `{PLATFORM}_TOKEN` | `VERCEL_TOKEN` | Platform API tokens |
| `{TOOL}_{PURPOSE}` | `TURBO_TOKEN` | Tool-specific credentials |

### GitHub Environments

For environment-scoped secrets:
```bash
# Set secret for specific environment
gh secret set DATABASE_URL --env production
gh secret set DATABASE_URL --env staging
```

---

## Supply Chain Hardening

### .npmrc Security Defaults

Verify these settings exist in `.npmrc`:
```ini
save-exact=true        # Pin exact versions
strict-ssl=true        # Enforce SSL for registry
ignore-scripts=true    # Prevent install scripts (enable per-package)
audit=true             # Auto-audit on install
```

### Node.js Runtime Security Flags

Verify Dockerfile CMD includes security flags:
```dockerfile
CMD ["node", "--disable-proto=delete", "--no-experimental-fetch", "dist/server.js"]
```

### SLSA Framework Compliance

| Level | Requirement | Implementation |
|-------|------------|----------------|
| SLSA 1 | Build process documented | GitHub Actions workflow |
| SLSA 2 | Build service + signed provenance | GitHub Actions + npm provenance |
| SLSA 3 | Hardened build platform | SHA-pinned actions + OIDC |

Enable npm provenance attestations:
```bash
npm publish --provenance
# or in package.json:
# "publishConfig": { "provenance": true }
```

---

## SARIF CI Gate Configuration

### Severity/Confidence Matrix

| Severity | High Confidence | Medium Confidence | Low Confidence |
|----------|----------------|-------------------|----------------|
| Critical | **Block** | **Block** | Warn |
| High | **Block** | Warn | Info |
| Medium | Warn | Info | Info |
| Low | Info | Info | — |

### Baseline Diffing

Only fail on NEW findings (not pre-existing):
```yaml
# In CI workflow
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@{sha}
  with:
    sarif_file: results.sarif
    category: security

# Gate: compare against baseline
- name: Security Gate
  run: |
    # Compare current SARIF against baseline
    # Fail only on new critical/high findings
    # 14-day grace period for pre-existing findings
```

---

## Caching Hierarchy

Ordered from most specific to most general:

| Layer | Tool | Key Pattern | Restore Keys |
|-------|------|------------|-------------|
| 1 | pnpm store | `pnpm-store-{os}-{hash(pnpm-lock.yaml)}` | `pnpm-store-{os}-` |
| 2 | Next.js | `nextjs-{os}-{hash(pnpm-lock.yaml)}` | `nextjs-{os}-` |
| 3 | Docker | `type=gha,scope={branch}` | `type=gha` |
| 4 | Turborepo | Remote cache via `TURBO_TOKEN` | N/A (remote) |

### pnpm Store Cache (GitHub Actions)

```yaml
- uses: actions/setup-node@{sha} # v4
  with:
    node-version: '22'
    cache: 'pnpm'
```

### Next.js Build Cache

```yaml
- uses: actions/cache@{sha} # v4
  with:
    path: ${{ github.workspace }}/apps/web/.next/cache
    key: nextjs-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}
    restore-keys: nextjs-${{ runner.os }}-
```

### Docker Layer Cache

```yaml
- uses: docker/build-push-action@{sha} # v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## OIDC Federation Setup

### GitHub → AWS

```bash
# 1. Create OIDC provider in AWS
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1" \
  --client-id-list "sts.amazonaws.com"

# 2. Create IAM role with trust policy
# Trust policy allows GitHub Actions from specific repo
```

### GitHub → GCP

```bash
# 1. Create Workload Identity Pool
gcloud iam workload-identity-pools create github-pool \
  --location="global"

# 2. Create Provider
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --attribute-mapping="google.subject=assertion.sub" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### GitHub → Azure

```bash
# 1. Create app registration with federated credential
az ad app create --display-name "GitHub Actions"
az ad app federated-credential create --id {app-id} \
  --parameters '{"issuer":"https://token.actions.githubusercontent.com",...}'
```

**Workflow usage** (all providers):
```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@{sha}
    with:
      role-to-assume: arn:aws:iam::123456789:role/github-actions
      aws-region: us-east-1
```
