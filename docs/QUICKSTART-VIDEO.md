# jaan.to Quickstart Video Script

3-5 minute demo video script showcasing jaan.to plugin capabilities.

**Target Audience:** Developers, PMs, and product teams evaluating the plugin
**Format:** Screen recording with voiceover
**Duration:** 3-5 minutes

---

## Setup Notes

**Before Recording:**
- Clean terminal (clear history, use large font)
- Claude Code installed with jaan.to plugin
- Test project ready (`~/demo-jaan-to`)
- Screen recording software ready (OBS, QuickTime, etc.)
- Microphone tested

**Screen Settings:**
- Terminal font: 18-20pt (readable)
- Window size: 1920x1080 or 1280x720
- Theme: High contrast (dark background, light text)

---

## Script

### [00:00 - 00:15] Opening (15 seconds)

**VISUAL:** Show terminal with Claude Code prompt

**NARRATION:**
> "Hi, I'm showing you jaan.to — a Claude Code plugin that gives soul to your product workflow. In the next 3 minutes, you'll see how it generates PRDs, user stories, task breakdowns, and more — all from simple commands."

**ON-SCREEN TEXT:**
- **jaan.to**
- Give soul to your workflow
- github.com/parhumm/jaan-to

---

### [00:15 - 00:45] Installation (30 seconds)

**VISUAL:** Install plugin from marketplace

**NARRATION:**
> "Installation is simple. From Claude Code, add the jaan.to marketplace, install the plugin, and you're ready."

**COMMANDS:**
```
claude

/plugin marketplace add parhumm/jaan-to
/plugin install jaan-to
```

**NARRATION (continued):**
> "Then run /jaan-init to activate jaan.to for your project. It creates a context directory with templates, learning files, and config — one command, fully set up."

**VISUAL:** Show `/jaan-init` command and `ls jaan-to/` output with directory structure

**ON-SCREEN TEXT:**
- ✅ One-command activation per project
- ✅ Creates jaan-to/ directory
- ✅ Copies templates and context files

---

### [00:45 - 01:30] Demo 1: Generate a PRD (45 seconds)

**VISUAL:** Run `/pm-prd-write` command

**NARRATION:**
> "Let's generate a PRD for a user authentication feature. Watch how jaan.to reads your tech stack and team context before generating."

**COMMANDS:**
```
/pm-prd-write "Add OAuth login with Google and GitHub"
```

**VISUAL:** Show skill reading context files (tech.md, team.md)

**NARRATION (continued):**
> "jaan.to follows a two-phase workflow. Phase 1 is read-only — it analyzes your context, gathers requirements, and plans the structure. Then it asks for your approval before writing anything."

**VISUAL:** Show Phase 1 output with plan and confirmation prompt

**NARRATION (continued):**
> "I confirm, and jaan.to generates a comprehensive PRD with problem statement, success metrics, user stories, technical approach, and testing plan — all tailored to my tech stack."

**VISUAL:** Show generated PRD in `jaan-to/outputs/pm/prd/01-oauth-login/`

**ON-SCREEN TEXT:**
- ✅ Reads project context
- ✅ Two-phase workflow (approval required)
- ✅ Comprehensive PRD in 30 seconds

---

### [01:30 - 02:15] Demo 2: Generate User Stories (45 seconds)

**VISUAL:** Run `/pm-story-write` command

**NARRATION:**
> "Now let's break this PRD into user stories. jaan.to can reference the PRD we just created."

**COMMANDS:**
```
/pm-story-write from prd at jaan-to/outputs/pm/prd/01-oauth-login/
```

**VISUAL:** Show skill reading PRD and extracting user flows

**NARRATION (continued):**
> "It reads the PRD, identifies user flows, and generates stories with Given/When/Then acceptance criteria following INVEST principles."

**VISUAL:** Show generated stories file with 3-4 stories visible

**NARRATION (continued):**
> "Each story is independent, valuable, and testable — ready to drop into your sprint planning."

**ON-SCREEN TEXT:**
- ✅ References PRD automatically
- ✅ Given/When/Then acceptance criteria
- ✅ INVEST principles

---

### [02:15 - 02:45] Demo 3: Generate Frontend Tasks (30 seconds)

**VISUAL:** Run `/frontend-task-breakdown` command

**NARRATION:**
> "For implementation, jaan.to can break down frontend tasks from the PRD."

**COMMANDS:**
```
/frontend-task-breakdown from prd at jaan-to/outputs/pm/prd/01-oauth-login/
```

**VISUAL:** Show skill generating component inventory and tasks

**NARRATION (continued):**
> "It analyzes the user flows, creates a component tree, and generates tasks with estimates. It knows our stack is React from the tech context, so it generates React-specific components and state management."

**VISUAL:** Show task breakdown with components and estimates

**ON-SCREEN TEXT:**
- ✅ Component inventory
- ✅ State management plan
- ✅ Story point estimates

---

### [02:45 - 03:15] Demo 4: Continuous Improvement (30 seconds)

**VISUAL:** Run `/learn-add` command

**NARRATION:**
> "What makes jaan.to unique is the learning system. After using a skill, you can capture lessons."

**COMMANDS:**
```
/learn-add "Always include redirect URI validation in OAuth PRDs - prevents open redirect attacks"
```

**VISUAL:** Show lesson being added to `jaan-to/learn/pm-prd-write.learn.md`

**NARRATION (continued):**
> "These lessons accumulate in skill-specific learning files. Over time, skills read these lessons before generating, avoiding past mistakes and handling edge cases you've discovered."

**VISUAL:** Show learning file with multiple lessons

**ON-SCREEN TEXT:**
- ✅ Capture lessons as you go
- ✅ Skills read lessons before generating
- ✅ Continuous improvement

---

### [03:15 - 03:40] Other Capabilities (25 seconds)

**VISUAL:** Quick montage showing other skills

**NARRATION:**
> "jaan.to has 18 skills across product management, development, UX, QA, and data analytics."

**VISUAL:** Show quick command list or skill menu

**COMMANDS (flash on screen, don't execute):**
```
/qa-test-cases         # Generate BDD test scenarios
/data-gtm-datalayer    # GTM tracking code
/ux-heatmap-analyze    # Analyze user behavior
/backend-task-breakdown # Backend task breakdown
```

**NARRATION (continued):**
> "You can generate test cases, GTM tracking code, analyze heatmaps, break down backend tasks, and much more."

**ON-SCREEN TEXT:**
- ✅ 18 skills
- ✅ PM, Dev, UX, QA, Data
- ✅ End-to-end workflows

---

### [03:40 - 04:00] Wrap-up (20 seconds)

**VISUAL:** Show terminal with jaan.to logo or GitHub page

**NARRATION:**
> "Install jaan.to from the Claude Code marketplace, or visit github.com/parhumm/jaan-to for documentation and examples."

**ON-SCREEN TEXT:**
- **jaan.to**
- Give soul to your workflow
- github.com/parhumm/jaan-to
- Proprietary License

**NARRATION (continued):**
> "Give soul to your workflow. Try jaan.to today."

**FADE OUT**

---

## B-Roll Suggestions (Optional)

If creating a more polished video with B-roll:

1. **Context Files:** Show `tech.md`, `team.md` being customized
2. **Output Files:** Show generated PRD being opened in editor
3. **File Tree:** Show `jaan-to/` directory structure expanding
4. **GitHub:** Show repository page with README
5. **Documentation:** Show docs site or skill reference

---

## Editing Notes

### Pacing

- **Fast cuts** for installation and setup (30 seconds max)
- **Slower pacing** for demo workflows (show outputs, let viewers read)
- **Quick montage** for capability overview (flash commands)

### Visual Hierarchy

1. **Primary:** Terminal commands and output
2. **Secondary:** File tree, generated files
3. **Tertiary:** On-screen text annotations

### Audio

- **Background music:** Subtle, instrumental, low volume (10-15%)
- **Voiceover:** Clear, conversational tone
- **Sound effects:** Minimal (optional key press sounds, success chimes)

---

## Recording Checklist

### Pre-Recording
- [ ] Terminal cleaned and configured (large font, high contrast)
- [ ] Test project created with clean state
- [ ] Plugin installed and tested
- [ ] Script rehearsed (timing verified)
- [ ] Microphone tested
- [ ] Screen recording software ready

### During Recording
- [ ] Speak clearly and at moderate pace
- [ ] Pause after each command (let output display)
- [ ] Keep mouse cursor out of critical areas
- [ ] Monitor recording quality (check first 30 seconds)

### Post-Recording
- [ ] Add on-screen text annotations
- [ ] Add background music (if applicable)
- [ ] Add intro/outro graphics
- [ ] Trim dead space and mistakes
- [ ] Export at 1080p or 720p
- [ ] Upload to YouTube with SEO-friendly title/description

---

## YouTube Metadata

**Title:**
> jaan.to — AI-Powered Product Workflow Plugin for Claude Code (3-min Demo)

**Description:**
```
jaan.to is a Claude Code plugin that automates product workflows with 18 AI-powered skills for PM, Dev, UX, QA, and Data teams.

🎯 What you'll see in this demo:
• Generate a comprehensive PRD in 30 seconds
• Break down user stories with acceptance criteria
• Create frontend task breakdowns with estimates
• Capture lessons for continuous improvement

✨ Key Features:
• Two-phase workflow with human approval
• Context-aware (reads your tech stack and team setup)
• 18 skills across PM, Dev, UX, QA, Data
• Learning system for continuous improvement

🔗 Links:
• GitHub: https://github.com/parhumm/jaan-to
• Documentation: https://github.com/parhumm/jaan-to/tree/main/docs
• Installation: /plugin marketplace add parhumm/jaan-to

📖 Chapters:
00:00 - Introduction
00:15 - Installation
00:45 - Generate PRD
01:30 - Generate User Stories
02:15 - Frontend Task Breakdown
02:45 - Learning System
03:15 - Other Capabilities
03:40 - Wrap-up

Give soul to your workflow. Try jaan.to today.

#ClaudeCode #AI #ProductManagement #DeveloperTools #Productivity
```

**Tags:**
- Claude Code
- AI plugins
- Product management
- PRD generator
- User stories
- Developer tools
- Productivity
- Workflow automation
- SaaS tools

**Thumbnail:**
- Large text: "jaan.to"
- Subtitle: "Give soul to your workflow"
- Visual: Terminal screenshot with PRD output
- High contrast, readable at small sizes

---

## Alternate Versions

### Short Version (60 seconds)

For social media (Twitter, LinkedIn):
1. Installation (10s)
2. Generate PRD (25s)
3. Show other skills montage (15s)
4. Wrap-up (10s)

### Long Version (8-10 minutes)

Deep dive for technical audience:
1. Installation and setup (1 min)
2. PRD generation with context explanation (2 min)
3. User stories (1 min)
4. Frontend tasks (1 min)
5. Backend tasks (1 min)
6. QA test cases (1 min)
7. Learning system and LEARN.md (1 min)
8. Customization (tech.md, team.md) (1 min)
9. Wrap-up (30s)

---

**Last Updated:** 2026-02-03
