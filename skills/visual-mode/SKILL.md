---
name: visual-mode
description: Attach a rendered Visual (a Sketch or a Walkthrough) to every Substantive reply, in place of explanatory prose. Use when the user says "visual mode", "show me visually", "draw it", or invokes /visual-mode. Stays on for the rest of the session until "stop visual mode".
---

# Visual mode

The reader builds understanding from pictures. Every Substantive reply carries a Visual: a rendered inline widget. The Visual replaces explanatory prose. It does not sit on top of it.

## Persistence

These rules apply to every reply for the rest of the session, not only this one. They do not lapse when the topic changes. If you are unsure whether they still apply, they do.

Turn them off only when the user says "stop visual mode". Confirm in one line, then return to your default style.

## Terms

- **Substantive reply**: a reply that explains, proposes, or changes something. A bare confirmation like "done, tests pass" or "yes" is not one and gets no Visual.
- **Sketch**: a small, static Visual showing one idea.
- **Walkthrough**: a stepped Visual. Each step shows program state at one point in the code.

## Rules

1. **One Visual per Substantive reply.** A long explanation may include more, with prose between them.
2. **Pick the kind from this menu:**

   | Kind | Use when the reply is about | Form |
   |---|---|---|
   | Flow | steps, requests, pipelines, decisions | Sketch: flowchart SVG |
   | Structure | modules, files, classes, schemas (UML) | Sketch: structural SVG; mermaid `classDiagram`/`erDiagram` inside the widget for classes and schemas |
   | Before→after | what a change does | Sketch: two panels side by side |
   | Walkthrough | how code executes, or why a bug happens | Stepped HTML widget (rule 3) |

   Do not invent other kinds.
3. **Walkthrough controls**: Prev/Next buttons and a step counter (`3 / 7`). Each step shows the current code line highlighted, and next to it a table of the variable values at that line. Mark values that changed since the previous step. No autoplay, no slider.
4. **The Visual replaces prose.** If the Visual shows it, the text does not repeat it. Text keeps only what the Visual cannot show: the next action, commands, and caveats.
5. **Placement**: the reply's first line stays the next action. The Visual comes right after it.
6. **Size budget**: a Sketch has at most about 6 boxes (roughly 1–3k tokens). A Walkthrough has at most about 10 steps (roughly 4–8k tokens). Over budget: split into several Visuals or cut content.
7. **Setup**: call the widget tool's `read_me` once per session, before the first Visual, with the module matching the kind (`diagram` for Sketches, `interactive` for Walkthroughs). Do not mention this call in the reply.
8. **Fallback**: when no widget tool is available (terminal CLI, cloud session, subagent), draw an ASCII Sketch in a fenced code block instead. A Walkthrough falls back to a numbered list of states, one per line: `line N → var=value, …`.
9. **Off switch**: "stop visual mode" turns it off for the rest of the session. Confirm in one line.
