# Electronics

| Rev | Date | Author | Description |
|---|---|---|---|
| 0.1 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Section page listing the electronics study material |

The electronics material is mostly KiCad projects and PDF references. They
stay in `Electronics/` at the repo root, because KiCad needs its project
folders intact. Open them from there.

| What | Where (repo root) | Contents |
|---|---|---|
| KiCad PCB study | `Electronics/Kicad/PCB_Kicad_study/` | `pcb_study` KiCad project with Gerbers, a local symbol library and footprints |
| ESP32 sensor board | `Electronics/Kicad/KLP-5e-ESP32-sensor-board/` | Separate git repo: ESP32-C3-02 IoT board with TP4056 charger, BME280, OLED, SD card. See its `README.md` |
| KiCad manuals | `Electronics/Kicad/Manual_References/` | Official KiCad manuals as PDF (getting started, schematic editor, PCB editor, CLI, Gerber viewer, calculator) |
| High-speed layout | `Electronics/PCB Study/high_speed_interface_layout_guide.pdf` | High-speed interface layout guide |

## Related

- The Phono 360 hardware reading list is in the
  [Phono 360 study roadmap](../phono-360/roadmap.md) (STM32U5 clock, SAI, DMA).
