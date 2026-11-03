# Writing notes and diagrams

| Rev | Date | Author | Description |
|---|---|---|---|
| 0.1 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Docs site setup copied from vimms-engineering (MkDocs Material + local PlantUML), plus Mermaid |

This site uses the same toolchain as VIMMS Engineering Docs:
[MkDocs](https://www.mkdocs.org/) with the
[Material theme](https://squidfunk.github.io/mkdocs-material/). Pages are
Markdown under `docs/`. PlantUML diagrams under `docs/<topic>/diagrams/` are
rendered to SVG on your machine by `tools/docs/hooks.py` with a pinned
PlantUML jar. No diagram text is sent to a server. Mermaid diagrams (used in
the INA226 notes) are drawn by the browser.

The site is **local only**. Some notes (for example the Phono 360 roadmap)
describe internal VIMMS designs, so don't publish the site.

## Quick start (one command)

```powershell
.\scripts\docs.cmd          # live preview, opens http://127.0.0.1:8001
.\scripts\docs.cmd build    # strict build into site/
.\scripts\docs.cmd open     # strict build, then open site/index.html
```

The default port is 8001, so this site can run next to the VIMMS Engineering
Docs site on 8000. The first run creates `tools\docs\.venv` and installs the
pinned requirements (`tools/docs/requirements.txt`, same pins as
vimms-engineering). Needs Python 3.13 and Java 11 or newer on `PATH`.

## Adding a note

1. Create `docs/<topic>/<name>.md`, file names in lowercase kebab-case.
2. Start with a `#` title and a revision table:

    ```markdown
    | Rev | Date | Author | Description |
    |---|---|---|---|
    | 0.1 | 2026-11-03 | Stephen Nacion | First version |
    ```

3. Add the page to `nav:` in `mkdocs.yml`.
4. Put the datasheets it uses in `docs/<topic>/datasheets/` and link them.
5. Run `.\scripts\docs.cmd build`. `--strict` fails on broken links.

## Adding a diagram

PlantUML (preferred for block and sequence diagrams):

1. Create `docs/<topic>/diagrams/<name>.puml`:

    ```text
    @startuml <name>
    !include ../../_plantuml/study-style.puml
    title Short title that says what the reader learns
    ...
    legend right
      Source: <datasheet, repo file at commit, or KB note ID>
    endlegend
    @enduml
    ```

2. Embed the SVG in the page: `![Alt text](diagrams/<name>.svg)`.
3. Add a short "What to notice" list under it.

Generated `.svg` files aren't committed; only the `.puml` source is.

Mermaid works too: use a fenced block with the language `mermaid`.

## Rules for content

- Cite the source of every value (datasheet + section, or file at commit).
- Label **measured**, **calculated** (show the working) and **assumption**.
  Write `TBD` instead of guessing.
- Give each page a revision table with ISO 8601 dates.
- Don't copy confidential VIMMS material (lab reports, quotes, NDA datasheets)
  into this repo. It has a public-facing GitHub remote.
