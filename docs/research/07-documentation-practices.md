# Claude Code Documentation Best Practices

> Summary of: `deepresearch/dev-workflow/claude-code-documentation-best-practices.md`

## Key Points

- **Documentation as context**: Well-structured docs improve AI understanding and output quality
- **README.md essentials**: Project purpose, setup instructions, architecture overview, key commands
- **API documentation**: Clear endpoint descriptions, request/response schemas, error codes
- **Code comments strategy**: Focus on "why" not "what"; avoid redundant comments that restate code
- **Architecture Decision Records (ADRs)**: Document significant technical decisions for AI and human context
- **Inline documentation**: JSDoc/PHPDoc for functions, interfaces, and complex logic
- **Living documentation**: Keep docs updated with code changes; stale docs are worse than no docs
- **AI-readable structure**: Use clear headings, code blocks, and structured formats

## Critical Insights

1. **Documentation serves dual purpose** - Helps both humans and AI understand codebase; invest in quality documentation
2. **Comments should explain intent** - "Why" comments are valuable; "what" comments are noise
3. **Structure matters for AI** - Well-formatted markdown with clear sections improves AI comprehension

## Quick Reference

| Document Type | Purpose | Key Content |
|---------------|---------|-------------|
| README.md | Project entry point | Setup, overview, quick start |
| CLAUDE.md | AI context | Standards, patterns, guidelines |
| ADRs | Decision history | Context, decision, consequences |
| API docs | Integration guide | Endpoints, schemas, examples |
| Inline docs | Code context | Function purpose, parameters, returns |

## Documentation Anti-Patterns
- Commenting every line of code
- Outdated docs that contradict code
- Documentation in silos (not near code)
- Missing "why" explanations
- Over-documentation of obvious code

## Recommended Structure
```
docs/
├── README.md           # Project overview
├── ARCHITECTURE.md     # System design
├── API.md              # API reference
├── DEVELOPMENT.md      # Dev setup guide
├── DEPLOYMENT.md       # Deployment procedures
└── adr/                # Architecture Decision Records
    ├── 001-database-choice.md
    └── 002-auth-strategy.md
```

