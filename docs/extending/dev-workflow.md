# Development Workflow

## plugin.json Rules
- **Only declare**: `name`, `version`, `description`, `author`
- **Never declare**: `skills`, `agents`, `hooks`, `commands` — these are auto-discovered from standard directories
- Official Anthropic plugins use minimal manifests; follow their pattern
- Before every release, test install on a clean machine/session
- The `agents` field specifically causes validation failure: `agents: Invalid input`

## Git Branching Rules
**`dev` is the working branch. `main` is the release branch.**

1. **Never commit directly to `main`** — all changes go through `dev` first
2. **Start every task** by switching to `dev`:
   ```
   git checkout dev
   git pull origin dev
   ```
3. **Keep `dev` in sync** with `main` before starting work:
   ```
   git merge main
   ```
4. **Commit and push** changes to `dev`:
   ```
   git push origin dev
   ```
5. **Update `main` only via PR**: Create a PR from `dev` → `main`, review, then merge
6. **After merging to `main`**, sync back:
   ```
   git checkout dev
   git merge main
   git push origin dev
   ```

## Before Every Commit
1. Update [roadmap.md](docs/roadmap/roadmap.md) with completed tasks
2. Mark tasks as `[x]` with commit hash: `- [x] Task (\`abc1234\`)`
3. For new tasks, use `/jaan-to:roadmap-add`

## Releasing a Version
Every version bump MUST be a single atomic operation:
1. Update version in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
2. Add entry to [CHANGELOG.md](CHANGELOG.md) following Keep a Changelog format
3. Commit with message: `release: vX.Y.Z — {summary}`
4. Create git tag: `git tag vX.Y.Z`
5. Push with tags: `git push origin main --tags`

**Never** bump version without a CHANGELOG entry and git tag. These three are inseparable.
