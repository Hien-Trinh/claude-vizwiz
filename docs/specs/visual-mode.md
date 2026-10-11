# Visual mode — spec

Status: agreed 2026-10-11, not built.
Self-contained: this file does not depend on anything else in the repo, so it can move.

## Goal

The reader builds understanding from pictures. In Visual mode, every Substantive reply from Claude carries a Visual, a rendered inline widget. The Visual replaces explanatory prose. It does not sit on top of it.

## Terms

- **Visual mode**: the session state where this rule is on.
- **Visual**: a rendered inline widget attached to a reply.
- **Substantive reply**: a reply that explains, proposes, or changes something. A bare confirmation like "done, tests pass" is not one and gets no Visual.
- **Sketch**: a small, static Visual showing one idea.
- **Walkthrough**: a stepped Visual. Each step shows program state at one point in the code.

## Rules Claude follows

1. Every Substantive reply includes exactly one Visual. A long explanation may include more, with prose between them.
2. Pick the Visual kind from the menu:

   | Kind | Use when the reply is about | Form |
   |---|---|---|
   | Flow | steps, requests, pipelines, decisions | Sketch: flowchart SVG |
   | Structure | modules, files, classes, schemas (UML) | Sketch: structural SVG; mermaid `classDiagram`/`erDiagram` inside the widget for classes and schemas |
   | Before→after | what a change does | Sketch: two panels side by side |
   | Walkthrough | how code executes, or why a bug happens | Stepped HTML widget (below) |

   Add a kind only when the same need keeps coming up and none of the four fits.
3. **Walkthrough controls**: Prev/Next buttons and a step counter (`3 / 7`). Each step shows the current code line highlighted, and next to it a table of the variable values at that line. Values that changed since the previous step are marked. No autoplay, no slider.
4. **Visual replaces prose.** If the Visual shows it, the text does not repeat it. Text keeps only what the Visual cannot show: the next action, commands, and caveats.
5. **Placement**: the reply's first line stays the next action (ADHD mode rule 1). The Visual comes right after it.
6. **Size budget**: a Sketch has at most about 6 boxes, roughly 1–3k tokens. A Walkthrough has at most about 10 steps, roughly 4–8k tokens. Over budget means split it into several Visuals or cut content.
7. **Setup**: call the widget tool's `read_me` once per session, before the first Visual, with the module matching the kind (`diagram`, `interactive`). Don't mention this call in the reply.
8. **Fallback**: when no widget tool is available (terminal CLI, cloud session, subagent), draw an ASCII Sketch in a fenced code block instead. A Walkthrough falls back to a numbered list of states, one per line: `line N → var=value, …`.
9. **Off switch**: "stop visual mode" turns it off for the rest of the session. Confirm in one line.

## Mechanism

- **Enforcement**: instructions only. A SessionStart hook injects the rules above into context at session start. No Stop-hook checker for now. Add one only if Claude keeps skipping Visuals.
- **Always-on**: the hook fires only when the flag file `~/.claude/.visual-mode-always` exists. Deleting the file turns it off for good.
- **Re-injection**: the hook matcher is `startup|resume|clear|compact`, so the rules come back after a compaction.
- **Packaging**: a Claude Code plugin, the same shape as `i-have-adhd`:

  ```
  visual-mode/
  ├── .claude-plugin/plugin.json
  ├── hooks/hooks.json          # SessionStart → hooks/always-on.sh
  ├── hooks/always-on.sh        # flag present → print banner + SKILL.md body
  └── skills/visual-mode/SKILL.md   # the rules, also invocable as /visual-mode
  ```

## Cost (accepted)

Roughly 100–200k extra output tokens across 50 replies, plus a few seconds of render time per Visual.

## Not doing (yet)

- Stop-hook enforcement (add if Visuals get skipped)
- Autoplay or slider Walkthroughs
- Artifact pages per reply (too heavy)
- Visual kinds beyond the four above

## Done when

1. With the flag file present, a fresh desktop session shows the "VISUAL MODE ACTIVE" banner in its SessionStart context.
2. Asking "explain this function" produces a Walkthrough with Prev/Next, a highlighted line, and a variable table.
3. Asking "what does this PR change" produces a Before→after Sketch.
4. "done" or "yes" replies have no Visual.
5. The same prompt in the terminal CLI produces an ASCII Sketch.
6. "stop visual mode" ends it for the session.
