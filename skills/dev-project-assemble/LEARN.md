# Lessons: dev-project-assemble

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-dev-project-assemble.learn.md`

## Better Questions

- Ask about existing project files before writing -- the target directory may already have a package.json, tsconfig.json, or .gitignore that should be merged, not overwritten
- Clarify shared types strategy early -- should Zod schemas and TypeScript interfaces live in a shared package, or be duplicated across frontend and backend?
- Ask about CI/CD expectations -- monorepo pipeline config (turbo.json) depends on deployment strategy (Vercel, Docker, custom)
- Ask about existing auth provider -- scaffold may reference NextAuth but project may use Clerk, Auth0, or custom JWT

## Edge Cases

- Target directory is not empty -- detect existing files and ask before overwriting
- Backend scaffold uses ESM (`"type": "module"`) but frontend bundler expects CJS -- ensure consistent module system
- Scaffold files may reference each other with placeholder imports that need rewriting during splitting
- Provider wiring may fail if scaffold references packages not in the dependency list
- Monorepo workspace protocol `workspace:*` requires all referenced packages to exist before `pnpm install`
- TailwindCSS v4 uses CSS-first config (`@import "tailwindcss"`) not `tailwind.config.js` -- do not generate the wrong config format
- Prisma schema may reference environment variables that differ between scaffold default and project reality

## Workflow

- Always read BOTH scaffold folders completely before starting any file writes -- cross-references between backend and frontend scaffolds need to be resolved holistically
- Split files in order: types/schemas first, then services, then routes/components, then entry points -- entry points depend on knowing all the pieces
- Generate and validate the directory tree BEFORE writing any files -- present it at the HARD STOP for user review
- Write config files LAST since they aggregate information from all other generated files (dependency lists, path aliases, etc.)

## Common Mistakes

- Losing code when splitting bundled scaffold files -- always verify line counts before and after splitting
- Wrong import paths after splitting -- relative paths change when files move from flat folder to nested directory structure
- Forgetting `.js` extensions in ESM imports for Fastify backend -- required with `moduleResolution: "NodeNext"`
- Generating `tailwind.config.js` for TailwindCSS v4 projects -- v4 uses CSS-first `@theme {}` configuration
- Hardcoding `localhost:3001` instead of using environment variable references
- Missing `"use client"` on the providers.tsx file -- layout.tsx is Server Component, providers.tsx must be Client Component
- Duplicating dependencies between root and app package.json in monorepo -- use workspace protocol
- Not including `postinstall: "prisma generate"` script for projects using Prisma
- Enabling a framework compiler/optimizer in config without adding its required build dependency — causes CI build failure
