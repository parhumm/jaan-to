# React Monorepo Tech Stack Architecture 2025

> Summary of: `deepresearch/dev-workflow/react-monorepo-tech-stack-2025.md`

## Key Points

- **NX vs Turborepo**: NX 7x faster for large repos but steeper learning curve; Turborepo adds speed in 10 minutes
- **Two-tool state management**: TanStack Query for server state, Redux Toolkit for client state is the 2025 pattern
- **Vite replacing Webpack**: 76.7% faster dev startup, 96.3% faster HMR, but Module Federation support immature
- **React 19 requires patience**: 38% faster loads, 32% fewer re-renders, but ecosystem compatibility is blocker
- **TypeScript 5.8**: Better tsconfig discovery, improved ESM support, direct Node.js execution
- **pnpm dominance**: 2-3x faster than npm, 15GB disk savings, strict dependency resolution
- **Next.js 15**: Requires React 19, explicit caching control, Turbopack stable

## Critical Insights

1. **Delay React 19 until Q2-Q3 2026** - Performance gains don't outweigh ecosystem instability risk
2. **Use right tool for each state type** - Server state (TanStack Query), client state (Redux), URL state (Router)
3. **Module Federation is the blocking factor** - Keeps teams on Webpack despite Vite's superior DX

## Quick Reference

| Tool | 2025 Status | Recommendation |
|------|-------------|----------------|
| NX | Best for complex projects | New projects, long-term codebases |
| Turborepo | Best for quick wins | Add speed to existing repos |
| TanStack Query | Industry standard for server state | Use for all new API data |
| Redux Toolkit | Best for client state | Auth, theme, preferences |
| Vite | Best DX | New SPAs without MF |
| Webpack | Required for MF | Micro-frontends |
| React 18 | Stable | Stay until ecosystem ready |
| React 19 | Bleeding edge | Wait for library support |
| TypeScript 5.8 | Stable | Upgrade immediately |
| pnpm | Package manager standard | Use for all new projects |

## State Management Pattern 2025
```typescript
// Redux for client state
const user = useSelector(state => state.auth.user)
const theme = useSelector(state => state.theme)

// TanStack Query for server state
const { data: movies } = useQuery(['movies'], fetchMovies)
const { data: profile } = useQuery(['profile'], fetchProfile)
```

## Migration Priorities
1. TypeScript 5.8 - Stable, immediate upgrade
2. pnpm - If not already using
3. TanStack Query - For new features
4. React 19 - Q2-Q3 2026 after ecosystem stabilizes
5. Vite - When Module Federation support matures

