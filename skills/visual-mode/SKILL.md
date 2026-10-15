---
name: visual-mode
description: Attach a rendered Visual (a Sketch, a Walkthrough, or a Deck) to every Substantive reply, in place of explanatory prose. Use when the user says "visual mode", "show me visually", "draw it", or invokes /visual-mode. Stays on for the rest of the session until "stop visual mode".
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
- **Deck**: a stepped Visual that reveals a chunked explanation one Slide at a time.
- **Slide**: one chunk of a Deck: a title, at most 3 short lines, and optionally one small Sketch.
- **Child session**: a forked desktop session that answers "more detail" on one Slide, opened in split view next to the Deck.

## Rules

1. **One Visual per Substantive reply.** A long explanation may include more, with prose between them.
2. **Pick the kind from this menu:**

   | Kind | Use when the reply is about | Form |
   |---|---|---|
   | Flow | steps, requests, pipelines, decisions | Sketch: flowchart SVG |
   | Structure | modules, files, classes, schemas (UML) | Sketch: structural SVG; mermaid `classDiagram`/`erDiagram` inside the widget for classes and schemas |
   | Before→after | what a change does | Sketch: two panels side by side |
   | Walkthrough | how code executes, or why a bug happens | Stepped HTML widget (rule 3) |
   | Deck | an explanation with 4+ separate chunks (steps, options, findings), or the user says "as slides" | Stepped HTML widget (rule 4) |

   The more specific kind wins: Walkthrough for code execution, Before→after for a change, Flow or Structure when one picture holds it. Deck only when nothing else fits. Do not invent other kinds.
3. **Walkthrough controls**: Prev/Next buttons and a step counter (`3 / 7`). Each step shows the current code line highlighted, and next to it a table of the variable values at that line. Mark values that changed since the previous step. No autoplay, no slider.
4. **Deck controls**: Prev/Next buttons, a step counter (`3 / 5`), and a "Show all" button. Next reveals the next Slide below the earlier ones, which stay on screen dimmed. No autoplay, no slider. Hold the Slides in a JS array and build every string from it, so quotes in Slide text cannot break the markup.
5. **"More" button on every Slide**: it calls `sendPrompt('In a side session, give more detail on "<slide title>": <slide text>')`. When that message arrives:
   - A Child session for that Slide already exists (see the linked sessions list) → send the request to it with `SendMessage`.
   - Otherwise → `start_session` with `initiation: "user_asked"`, `context: "fork"`, `name: "slide-<short-slug>"`, the request as `prompt`; then open it in split view with `open_session_in`.
   - Reply in the main chat with one line linking the Child session. No Visual: it is a bare confirmation.
   - Session tools missing or the start refused → answer in the main chat under the normal rules.
   - The Child session's answers stay there. Nothing reports back to the main chat.
6. **The Visual replaces prose.** If the Visual shows it, the text does not repeat it. Text keeps only what the Visual cannot show: the next action, commands, and caveats. In a Deck, the explanation goes on the Slides; the next action and any command or code meant for copying stay in normal chat. At most 3 lines of text outside the Visual, not counting commands and code blocks. Anything longer goes into the Visual, or the reply becomes a Deck.
7. **Placement**: the reply's first line stays the next action. The Visual comes right after it.
8. **Size budget**: a Sketch has at most about 6 boxes (roughly 1–3k tokens). A Walkthrough has at most about 10 steps (roughly 4–8k tokens). A Deck has at most 6 Slides. Over budget: split Sketches and Walkthroughs into several Visuals or cut content; cut a Deck's content, do not split it.
9. **Setup**: call the widget tool's `read_me` once per session, before the first Visual, with the module matching the kind (`diagram` for Sketches, `interactive` for Walkthroughs and Decks). Do not mention this call in the reply.
10. **Fallback**: when no widget tool is available (terminal CLI, cloud session, subagent), draw an ASCII Sketch in a fenced code block instead. A Walkthrough falls back to a numbered list of states, one per line: `line N → var=value, …`. A Deck falls back to plain sections with numbered headers (`### 1/5 — title`), nothing hidden, ending with one line: type `/btw more on N` for detail on a section.
11. **Off switch**: "stop visual mode" turns it off for the rest of the session. Confirm in one line.
