# Lessons: frontend-story-generate

> Plugin-side lessons. Project-specific lessons go in:
> `$JAAN_LEARN_DIR/jaan-to-frontend-story-generate.learn.md`

---

## Better Questions

Questions that improve input quality:

- "Does this component use CVA or another variant system?" — Determines story generation strategy
- "What states does the component support?" — Loading, error, empty may not be obvious from props
- "Are there existing story conventions in the project?" — Match formatting and naming patterns
- "Which Storybook addons are installed?" — a11y, interactions, viewport affect story structure

## Edge Cases

Special cases to check:

- **Compound components** — Components like `<Tabs>` + `<TabsList>` + `<TabsTrigger>` need stories for the composed whole, not individual pieces
- **Server Components** — Cannot have stories (no client interactivity). Generate stories for client wrapper instead
- **Generic components** — Components with complex generics (e.g., `Table<T>`) need concrete type in stories
- **shadcn/ui components** — Already have variant props via CVA; detect `cva()` and extract all variants automatically

## Workflow

Process improvements:

- **Check for existing stories first** — Never overwrite without asking
- **Match project conventions** — Read 2-3 existing stories to learn formatting before generating
- **Scan mode** — When no input given, scan and list all components missing stories (efficient batch mode)
- **CVA detection** — Always grep for `cva(`, `variants:`, `defaultVariants:` before planning coverage

## Common Mistakes

Pitfalls to avoid:

- Using render functions instead of declarative args — CSF3 prefers declarative
- Missing `tags: ['autodocs']` — Needed for automatic documentation generation
- Wrong import path for component — Always verify the actual export path
- Generating stories for utility functions or types — Only components get stories
- Using `StoryObj<typeof Component>` instead of `StoryObj<typeof meta>` — The latter is correct CSF3
