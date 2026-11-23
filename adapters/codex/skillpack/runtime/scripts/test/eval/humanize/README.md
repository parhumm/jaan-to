# humanize — Eval Cases

> Semantic cases for `skills/humanize`. They need live model runs, so they are **not** wired into CI. The scripts' deterministic self-tests run in CI through `scripts/test/humanize-scripts-test.sh`.

## Cases

| Case | Pack | What it checks |
|------|------|----------------|
| `stakeholder-email-chat-artifacts` | en | Chat leftovers and placeholders removed, facts kept |
| `blog-intro-vague-claims` | en | Empty claims cut, nothing invented, `[ADD: …]` where specifics are missing |
| `research-abstract-keep-hedges` | en | Hedges and scope kept ("may", "in mice") |
| `fa-blog-post-ai-artifacts` | fa | Chat leftovers, em dashes, stock openers removed; `fa_lint.py --check` clean |
| `fa-admin-letter-register` | fa | Official letter conventions kept, filler cut, formal register |
| `fa-casual-caption-keep-verse` | fa | Written colloquial register; the Hafez lines stay word for word |
| `fa-request-en-email` | routing | A Persian request about an English email: English rewrite, Persian reply |
| `bilingual-event-notice` | routing | Each part rewritten and checked with its own pack, order kept |
| `arabic-out-of-scope` | routing | Arabic declined; no Persian cleanup applied |

## Layout

Each case folder holds `case.yaml` (expected outcome), `prompt.md` (the user turn, with run limits in its frontmatter), `place-files.sh` (copies `files/` into the working dir) and `graders/` (one pass/fail statement per file).

## Run

1. Make an empty project dir, run `jaan-init` in it, then run the case's `place-files.sh` there.
2. Run the prompt with the plugin loaded, for example `claude -p "$(sed '1,/^---$/d' prompt.md)"`, and keep the transcript.
3. Judge each grader against the files and the transcript. Report pass^k over at least 5 trials.

**Two-phase note:** the skill stops at its HARD STOP and again at "Keep this version?". In a headless run, answer `y` to both (or continue the session), otherwise the case ends at the preview and the file-based graders fail. The file the prompt names (for example `email-final.txt`) is written in Step 9, next to the copy in `jaan-to/outputs/writing/humanize/`.
