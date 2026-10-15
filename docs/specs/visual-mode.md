# Visual mode — spec

Status: agreed 2026-10-11, built. Deck kind agreed 2026-10-15.
Self-contained: this file does not depend on anything else in the repo, so it can move.

## Goal

The reader builds understanding from pictures. In Visual mode, every Substantive reply from Claude carries a Visual, a rendered inline widget. The Visual replaces explanatory prose. It does not sit on top of it.

## Terms

- **Visual mode**: the session state where this rule is on.
- **Visual**: a rendered inline widget attached to a reply.
- **Substantive reply**: a reply that explains, proposes, or changes something. A bare confirmation like "done, tests pass" is not one and gets no Visual.
- **Sketch**: a small, static Visual showing one idea.
- **Walkthrough**: a stepped Visual. Each step shows program state at one point in the code.
- **Deck**: a stepped Visual that reveals a chunked explanation one Slide at a time.
- **Slide**: one chunk of a Deck: a title, at most 3 short lines, and optionally one small Sketch.
- **Child session**: a forked desktop session that answers "more detail" on one Slide, opened in split view next to the Deck.

## Rules Claude follows

1. Every Substantive reply includes exactly one Visual. A long explanation may include more, with prose between them.
2. Pick the Visual kind from the menu:

   | Kind | Use when the reply is about | Form |
   |---|---|---|
   | Flow | steps, requests, pipelines, decisions | Sketch: flowchart SVG |
   | Structure | modules, files, classes, schemas (UML) | Sketch: structural SVG; mermaid `classDiagram`/`erDiagram` inside the widget for classes and schemas |
   | Before→after | what a change does | Sketch: two panels side by side |
   | Walkthrough | how code executes, or why a bug happens | Stepped HTML widget (below) |
   | Deck | an explanation with 4+ separate chunks (steps, options, findings), or the user says "as slides" | Stepped HTML widget (below) |

   The more specific kind wins: Walkthrough for code execution, Before→after for a change, Flow or Structure when one picture holds it. Deck only when nothing else fits.

   Add a kind only when the same need keeps coming up and none of the four fits.
3. **Walkthrough controls**: Prev/Next buttons and a step counter (`3 / 7`). Each step shows the current code line highlighted, and next to it a table of the variable values at that line. Values that changed since the previous step are marked. No autoplay, no slider.
4. **Deck controls**: Prev/Next buttons, a step counter (`3 / 5`), and a "Show all" button. Next reveals the next Slide below the earlier ones, which stay on screen dimmed (accumulate, not replace: what leaves the screen is forgotten). No autoplay, no slider.
5. **"More" button on every Slide**: it calls `sendPrompt('In a side session, give more detail on "<slide title>": <slide text>')`. The Slide's text goes in, not just its number, so the request makes sense on its own. Claude then:
   - sends the request to the Slide's existing Child session, if there is one (one Child per Slide);
   - otherwise forks a Child session (`start_session`, `context: "fork"`) and opens it in split view, so the Deck stays visible;
   - replies in the main chat with one line linking the Child, and no Visual;
   - answers in the main chat under the normal rules when session tools are missing or the start is refused.

   The Child session runs the same hooks, so Visual mode is on there. Its answers stay there and never report back.
6. **Visual replaces prose.** If the Visual shows it, the text does not repeat it. Text keeps only what the Visual cannot show: the next action, commands, and caveats. In a Deck, the explanation goes on the Slides; the next action and any command or code meant for copying stay in normal chat. At most 3 lines of text outside the Visual, not counting commands and code blocks. Anything longer goes into the Visual, or the reply becomes a Deck.
7. **Placement**: the reply's first line stays the next action (ADHD mode rule 1). The Visual comes right after it.
8. **Size budget**: a Sketch has at most about 6 boxes, roughly 1–3k tokens. A Walkthrough has at most about 10 steps, roughly 4–8k tokens. A Deck has at most 6 Slides. Over budget means split it into several Visuals or cut content; a Deck gets cut, never split.
9. **Setup**: call the widget tool's `read_me` once per session, before the first Visual, with the module matching the kind (`diagram`, `interactive`). Don't mention this call in the reply.
10. **Fallback**: when no widget tool is available (terminal CLI, cloud session, subagent), draw an ASCII Sketch in a fenced code block instead. A Walkthrough falls back to a numbered list of states, one per line: `line N → var=value, …`. A Deck falls back to plain sections with numbered headers (`### 1/5 — title`), nothing hidden, ending with one line: type `/btw more on N` for detail on a section.
11. **Off switch**: "stop visual mode" turns it off for the rest of the session. Confirm in one line.

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
- Visual kinds beyond the five above
- "More" via `/btw`: it has no tools, so it can't render Visuals, and whether `sendPrompt` runs slash commands is undocumented
- Child sessions reporting back to the main chat
- Splitting a Deck over budget (cut instead)

## Done when

1. With the flag file present, a fresh desktop session shows the "VISUAL MODE ACTIVE" banner in its SessionStart context.
2. Asking "explain this function" produces a Walkthrough with Prev/Next, a highlighted line, and a variable table.
3. Asking "what does this PR change" produces a Before→after Sketch.
4. "done" or "yes" replies have no Visual.
5. The same prompt in the terminal CLI produces an ASCII Sketch.
6. "stop visual mode" ends it for the session.
7. A question with 5 separate options produces a Deck: Slides revealed one at a time, earlier ones dimmed, with Prev/Next, a counter, and "Show all".
8. Clicking "More" on a Slide opens a forked Child session in split view, and the main chat gets one line.
9. Clicking "More" on the same Slide again reuses that Child session.
10. The same prompt in the terminal CLI produces numbered `### 1/5 — title` sections.
