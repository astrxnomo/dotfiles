---
name: activity-report
description: >
  Draft activity-report text for the user's "Estudiante Auxiliar" position at
  Universidad Nacional de Colombia (Centro de Prototipado), based on his real
  git activity across his project repos. Covers two related documents: the
  weekly entries he pastes himself into his running "informe principal" log,
  and the formal monthly letter he sends to the director. Use whenever the
  user asks for this week's/this month's informe, to continue the informe
  principal, or says things like "hazme el informe de esta semana", "toca
  el informe del mes", "sigue con el informe principal", even without
  spelling out every step. Output is Spanish prose matching the exact
  institutional format and the user's own voice, not a generic AI summary.
---

# Activity reports (Informe de actividades)

The user holds down a paid research-assistant role and has to account for his
time in writing. There are two documents built from the same underlying
work, at two different levels of resolution:

1. **The informe principal.** A running log, one entry per Monday-Friday
   work week, grouped under month headers, that lives in a Word file the
   user edits himself. Detailed, slightly more technical, internal.
2. **The monthly letter.** A short formal letter to the director (fixed
   salutation, legal recital, closing/signature) that condenses a whole
   month's work into 2-4 paragraphs. External, sent out, more polished.

**Deliverable either way: plain text in chat.** This skill never touches a
`.docx` file; the user pastes what you write into the right document
himself. Don't ask to be handed the informe principal's file path. He'll
paste the relevant text directly when you need it (see below), since it
lives in a Drive export whose folder name changes every time.

## Shared step: gather real git activity for a date range

Both workflows below need this. The user runs this skill from **different
machines**, each with its own projects folder (e.g. `D:\Code` on one PC,
something else on another), and which repos exist or saw work changes
constantly. Don't hardcode a projects-root path or project names into this
skill; resolve them fresh every time:

1. **Find this machine's projects root.** If you don't already know it this
   session, ask the user (or check the obvious candidates: the current
   working directory's parent, a `Code`/`dev`/`projects`-style folder in the
   home directory) rather than assuming a path from a different machine
   still applies here.
2. List the git repos under that root (directories containing a `.git`).
3. For each, check whether it has commits in the target range
   (`git log --since=<start> --until=<end> --oneline --stat`). Use
   `git config user.name`/`user.email` if you need to filter by author.
4. **Filter to the projects that actually belong in this report.** The user
   has personal/portfolio repos (his own site, side projects) mixed in with
   the paid Centro de Prototipado work; only the latter goes in either
   document. If it's unclear which bucket a repo falls in, ask rather than
   guess. Getting this wrong means either padding the report with irrelevant
   work or silently dropping real work.
5. If a project mentioned in a recent report has since moved, been renamed,
   or isn't under the projects root on this machine, don't guess. Ask the
   user, or check `gh repo list` (some repos are also tracked via `gh`, per
   the user).
6. For repos with real activity, read enough commits/diffs to understand
   what actually shipped, not just the commit subject lines; they're terse
   dev shorthand. You need to know what it does and why it matters, so you
   can translate that into prose a non-technical director can read.

## Workflow A: weekly entry for the informe principal

Triggered by things like "dame el informe de esta semana" or "sigue con el
informe principal."

1. **Get your bearings from the user, don't assume.** You have no memory of
   the document's current state across sessions, and it changes as the user
   keeps editing it by hand. If you don't already know, in this
   conversation, what the last recorded week was and what the entries around
   it look like, ask the user to paste the tail of the informe principal
   (the last week or two) so you match its exact header style and rhythm
   instead of guessing at the format.
2. **Pick the target week.** Default to the most recently fully elapsed
   Monday-Friday week if the user doesn't name one. Never write a week that
   hasn't finished yet; there's nothing real to report.
3. **Gather that week's git activity** (see shared step above).
4. **Write the entry**, matching the document's established shape: a
   `Semana: D mes - D mes` line, an optional month header (`Mes AAAA`, or
   `Mes1 - Mes2 AAAA` when the week spans two months) only if this is the
   first week under that header and the user's pasted context confirms one
   isn't already there, then paragraphs, usually one per project with real
   activity that week, with an intro sentence first when the week touched
   more than one. This document runs more detailed and itemized than the
   monthly letter, since it's the internal record and not the polished
   external version, so it's fine to name more specific sub-changes here
   than you would in a letter paragraph.
5. **Ask about non-git activity for that specific week**: event support,
   school visits, competitions judged, trainings. Do this before finishing.
   Don't invent one and don't skip asking just because recent weeks didn't
   have one. If yes, it usually becomes a short closing sentence or short
   paragraph in that week's entry, in the same voice as the rest.
6. Hand back just that week's entry text (with the month header only if it
   applies), ready to paste in after the last existing week.

## Workflow B: the monthly letter

Triggered near month's end by things like "dame el informe del mes" or
"hazme el informe de julio."

**Prefer condensing already-written weekly entries over re-deriving from
git.** If the user has been using Workflow A throughout the month, those
entries are the vetted, human-approved account of what happened. Building
the letter from them, rather than re-reading git independently, guarantees
the two documents never disagree, and saves you re-doing analysis that's
already settled. Ask the user to paste that month's weekly entries from the
informe principal. Only fall back to gathering git activity directly (shared
step above) for weeks that got skipped, or if the user says he didn't keep
the weekly log that month.

1. **Get the current boilerplate.** The skeleton below is what the letters
   looked like as of mid-2026; treat it as a starting shape, not a fixed
   template, since the director, the resolution, or the closing details can
   change over time. If you don't already know this session that it's still
   current, ask the user (or have him paste the header/closing of his most
   recent sent letter) rather than assume it's unchanged:

   ```
   Manizales, <mes> de <año>
   Señor
   FREDDY LEONARDO FRANCO IDARRAGA
   Director de investigación y Extensión
   Universidad Nacional de Colombia - Sede Manizales
   Asunto: Informe de actividades Estudiante Auxiliar.
   A través de este documento, se presenta el informe de actividades
   correspondiente al mes de <mes> del año <año>, en el marco de la
   RESOLUCIÓN 0337 de 2026, expedida por la Vicerrectoría de la sede
   Manizales de la Universidad Nacional de Colombia el 23 de febrero de
   2026 en la que se establece "Apoyar el desarrollo de actividades del
   Centro de Prototipado para la Innovación Académica y el Fortalecimiento
   Empresarial en el marco del proyecto Estampilla, adscrita a la
   Dirección de Investigación y Extensión." A continuación, se mencionan
   las actividades desarrolladas durante el periodo de vinculación con un
   total de 20 horas semanales:

   <body paragraphs go here>

   Atentamente,
   [firma]
   Luis Felipe Giraldo Ortega
   Estudiante Auxiliar Universidad Nacional de Colombia, sede Manizales
   C.C. 1193568820
   ```

   Two other things to calibrate, also worth double-checking rather than
   assuming they haven't drifted:
   - **The current voice/register.** Some months are impersonal
     ("se implementó"), at least one was first-person plural ("añadimos").
     Ask the user which one his last letter used if you don't already know,
     and don't mix registers within one letter.
   - **The condensation ratio**: how much of a week's detail survives into
     the letter's paragraph. The letter should read like a summary written
     by someone who did the work and is being concise for an executive
     reader, not like an itemized changelog.
2. **Condense**, one paragraph per project with real work that month,
   ordered by how much of the month it took (main project first, then "en
   paralelo, ..." / "por otro lado, ..." for the rest; reuse these existing
   connectors rather than inventing new transitions each time). Compress
   several weeks of itemized entries into the handful of sentences that
   matter: what shipped and why it matters, not a week-by-week recap.
3. **Non-git activities**: if the weekly entries you're condensing from
   already mention any, fold them into a closing paragraph the same way
   past letters do. If you're deriving straight from git instead (no weekly
   entries given), ask the user directly before finishing, same as
   Workflow A.
4. **Assemble**: boilerplate around the new body, target month/year
   substituted everywhere the old one appeared (salutation date,
   "correspondiente al mes de \<mes\> del año \<año\>", etc.).

## Every sentence should trace back to a real change

In both workflows: don't invent, round up, or pad. If a week or month was
genuinely thin, write a thin entry. A short honest one beats an inflated
one, and whoever reads these across months will notice padding. Write for
the reader, not for a code reviewer: say what a feature does and why it
matters (who it helps, what it replaces, what it makes possible), the way
the real reports do. For example: "se implementó la firma digital sobre el
PDF con soporte para posicionar y redimensionar la firma directamente sobre
el documento" rather than a list of function names. Concrete technical
nouns (Next.js, Supabase, OCR, webhook de Gmail/Pub-Sub, MQTT) are fine and
expected; they read as substance. The thing to avoid is vague praise
standing in for a concrete detail you could have just looked up in the diff.

## Writing it so it doesn't read as AI-generated

This is the part the user explicitly cares about. Formal Spanish
institutional writing has its own real conventions (impersonal "se"
constructions, "Atentamente", etc.); keep those, they're the house style.
What reads as AI-generated on top of that house style is a narrower, very
recognizable set of tics. Hunt for these specifically before delivering, in
both the weekly entries and the letter:

- **Em dashes and other typographic tells.** Use plain periods, commas, or
  parentheses instead of "—". The real reports don't use them, and neither
  should you; it's one of the most obvious AI tells in Spanish prose.
- **Hedge/filler connectives that say nothing**: "cabe destacar que",
  "es importante mencionar", "sin duda", "en definitiva", "de manera
  significativa". The real reports never use these; they just state the
  fact. Delete the hedge, keep the fact.
- **Adjective stacking instead of a concrete detail**: "una solución robusta
  y eficiente", "un sistema integral e innovador". Reaching for two
  adjectives usually means you're missing the actual detail that would make
  either one unnecessary; go find it in the diff instead.
- **Uniform sentence rhythm**: every sentence the same length, every
  paragraph the same shape (claim, list of three, wrap-up). Real writing has
  a long sentence next to a short one. If a paragraph scans like a slide
  deck, rewrite it.
- **Over-enumeration**: turning normal prose into an implicit bullet list
  for everything, rather than only where the source documents actually do
  this (they do it sometimes, for a genuine list of discrete features, not
  for connected narrative).
- **Restating the obvious close**: don't end a paragraph by summarizing what
  it just said. The real entries just stop once the last fact is stated.
- **Reusing your own last entry's exact phrasing.** If you drafted last
  week's or last month's text too, don't recycle its sentence openers or
  transitions verbatim; a human's writing drifts over time even when the
  format doesn't.

## Checklist

- [ ] Resolved this machine's projects root instead of assuming one, and
      confirmed which repos in it are in-scope (job work, not personal/
      portfolio projects) for this range
- [ ] (Weekly) Got the informe principal's recent tail from the user if its
      current state/format wasn't already known this session
- [ ] (Weekly) Target week has actually finished (Mon-Fri fully elapsed)
- [ ] (Monthly) Asked for that month's weekly entries first; only fell back
      to raw git if the user didn't have them
- [ ] (Monthly) Boilerplate and voice confirmed current (not just assumed
      from the reference skeleton), month/year substituted everywhere
- [ ] Every claim traceable to an actual commit/change, nothing invented
- [ ] Asked about non-git activities for this specific range
- [ ] Register (impersonal vs. plural) consistent throughout
- [ ] No em dashes; re-read against the AI-tics list above before handing it
      over
