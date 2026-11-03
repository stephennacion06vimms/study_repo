# Stephen's Study Notes

| Rev | Date | Author | Description |
|---|---|---|---|
| 0.1 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Notes moved into a MkDocs site with the same look and toolchain as VIMMS Engineering Docs |

Personal study notes on electronics, firmware and sensors, and the learning
plan for VIMMS products. Pick a topic below or use the tabs at the top.

| Topic | Start here | What's in it |
|---|---|---|
| Phono 360 | [Study roadmap](phono-360/roadmap.md) | Hardware-first plan for the Phono 360 mic board (power, clocks, interfaces, protection, layout, acoustics, bring-up, EMC) plus the firmware and DSP an electronics engineer needs, in 14 phases with exercises |
| Electronics | [Electronics](electronics/index.md) | KiCad study projects, ESP32 sensor board, KiCad manuals, high-speed layout guide |
| Firmware | [Firmware](firmware/index.md) | nRF Connect SDK / Zephyr blinky study |
| Sensors | [INA226 current sensor](sensors/ina226/index.md) | Summary, averaging and conversion time, MCU wiring, I2C timing |
| Lasers | [Lasers](lasers/index.md) | Beam divergence and a comparison of six laser diode datasheets |

## How to read these pages

- Pages follow the VIMMS Engineering Docs conventions: a revision table at the
  top, values tied to a source (datasheet, repo file at a commit, or a
  knowledge-base note ID), and **measured**, **calculated** and **assumption**
  kept apart.
- Click a diagram or image to zoom.
- Datasheets sit next to the notes that use them and open in the browser.
- Project files that aren't notes (KiCad projects, firmware code) stay in their
  folders at the repo root. The section pages tell you where.

## Viewing the site

```powershell
.\scripts\docs.cmd          # live preview at http://127.0.0.1:8001
.\scripts\docs.cmd open     # strict build, then open site/index.html from disk
```

See [Writing notes and diagrams](writing-docs.md) for setup and conventions.
