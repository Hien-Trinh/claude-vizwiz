# claude-vizwiz

Claude Code mod that attaches a rendered Visual to every Substantive reply.

## Visual mode

**Visual mode**:
A session state in which Claude attaches a Visual to every Substantive reply.
_Avoid_: diagram mode, viz rule

**Visual**:
A rendered inline widget attached to a reply. It replaces explanatory prose instead of adding to it.
_Avoid_: image, picture, diagram (when the general thing is meant)

**Sketch**:
A small, static Visual showing one idea, such as a flow, a before→after, or a structure.
_Avoid_: thumbnail, mini-diagram

**Walkthrough**:
A stepped Visual where each step shows program state at one point in the code.
_Avoid_: Deck, trace, animation

**Deck**:
A stepped Visual that reveals a chunked explanation one Slide at a time, earlier Slides staying visible.
_Avoid_: slideshow, carousel, presentation

**Slide**:
One chunk of a Deck: a title, at most 3 short lines, and optionally one small Sketch.
_Avoid_: card, page, step (step belongs to a Walkthrough)

**Child session**:
A forked desktop session that answers "more detail" on one Slide, opened in split view next to the Deck.
_Avoid_: side chat, btw (that is `/btw`, which can't render Visuals)

**Flow**:
A Sketch of steps, requests, or decisions in sequence.

**Structure**:
A Sketch of what contains or depends on what: modules, files, classes, schemas.
_Avoid_: architecture diagram, UML (UML is one form of it)

**Before→after**:
A Sketch putting the state before a change next to the state after it.
_Avoid_: diff view

**Substantive reply**:
A reply that explains, proposes, or changes something. A bare confirmation like "done, tests pass" is not one.
_Avoid_: real reply, non-trivial reply
