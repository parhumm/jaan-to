# Lessons: devops-deploy-activate

> Last updated: 2026-02-12

Accumulated lessons from past executions.

---

## Better Questions

- Ask which deployment environments are needed (dev/staging/production) before planning secrets
- Confirm the user has CLI tools installed and authenticated before starting activation
- Ask about existing monitoring/alerting setup to include in next steps

## Edge Cases

- GitHub Actions tags may point to tag objects, not commits — need to dereference to get the commit SHA
- Some org-scoped actions use branch references instead of tags — handle differently for SHA pinning
- Platform CLI tools may require interactive auth flows — guide user through these
- OIDC federation requires specific IAM permissions — user may not have admin access

## Workflow

- Always check current state first (existing secrets, linked platforms) to avoid re-provisioning
- Configure secrets before platform provisioning — platforms may need secrets to connect
- Pin GitHub Actions SHA digests before triggering verification pipeline
- Trigger a full pipeline run after all activation steps to verify end-to-end

## Common Mistakes

- Logging or displaying secret values after user entry — never do this
- Using mutable tags (`v4`, `latest`) instead of SHA digests for GitHub Actions
- Forgetting to set secrets per-environment (staging vs production)
- Not verifying CLI tool authentication before attempting platform commands
- Skipping the verification pipeline run — always validate the full pipeline works
