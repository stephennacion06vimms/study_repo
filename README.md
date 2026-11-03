# study_repo

My study repo notes, published as a local MkDocs site with the same look and
toolchain as VIMMS Engineering Docs.

## Read the notes

```powershell
.\scripts\docs.cmd          # live preview, opens http://127.0.0.1:8001
.\scripts\docs.cmd open     # strict build, then open site/index.html from disk
```

First run creates `tools\docs\.venv` (Python 3.13) and downloads the pinned
PlantUML jar (needs Java 11+). Details: `docs/writing-docs.md`.

## Layout

```text
docs/                      Notes (Markdown) -> the HTML site
  index.md                 Home page
  phono-360/roadmap.md     Phono 360 study roadmap
  sensors/ina226/          INA226 notes + datasheet
  lasers/                  Laser notes, images, datasheets
  electronics/, firmware/  Section pages pointing to the projects below
Electronics/               KiCad projects and manuals (kept in place for KiCad)
Firmware/                  nRF Connect / Zephyr study projects
mkdocs.yml                 Site config and navigation
tools/docs/                Pinned requirements + PlantUML build hook
scripts/docs.cmd|ps1       One-command launcher
.github/workflows/docs.yml Build-only CI check (mkdocs --strict)
```
