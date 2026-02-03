# Safe Write Boundaries {#boundaries}

> Auto-detected by `/jaan-to-dev-stack-detect` on 2026-02-03
> Status: **Seed template** - Default safe paths only

---

## Allowed Write Locations {#allowed}

These directories are safe for Claude to create and modify files:

- `jaan-to/**` - jaan.to outputs, context, and metadata
- `docs/**` - Documentation (if exists)
- `.claude/**` - Claude configuration
- `test-fixtures/**` - Test data and fixtures

---

## Denied Locations {#denied}

**DO NOT** modify these without explicit user permission:

### Source Code
- `src/**`
- `lib/**`
- `app/**`
- `packages/**`
- `services/**`

### Configuration Files
- `.env*`
- `*.config.*`
- `tsconfig.json`
- `package.json`
- `pyproject.toml`
- `go.mod`
- `Cargo.toml`
- `composer.json`

### Build Outputs
- `dist/**`
- `build/**`
- `.next/**`
- `__pycache__/**`
- `target/**`

### Dependencies
- `node_modules/**`
- `vendor/**`
- `.venv/**`

### Git & CI
- `.git/**` (except hooks via Claude Code features)
- `.github/**` (except via explicit request)
- `.gitlab-ci.yml`

---

## Special Cases {#special-cases}

### Allowed with Confirmation
- Creating new directories in project root
- Modifying README.md (show diff first)
- Creating test files in detected test directories

### Never Allowed
- Deleting `.git/` or source code
- Modifying production deployment configs without review
- Committing secrets or credentials
