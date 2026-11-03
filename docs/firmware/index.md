# Firmware

| Rev | Date | Author | Description |
|---|---|---|---|
| 0.1 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Section page for the firmware study projects |

Firmware projects stay in `Firmware/` at the repo root so the nRF Connect for
VS Code extension can build them (`.vscode/settings.json` points to the blinky app).

| Project | Where (repo root) | What it shows |
|---|---|---|
| nRF blinky | `Firmware/NRF_Study/blinky/` | The Zephyr `blinky` sample: a GPIO LED toggled every 1000 ms through the `led0` devicetree alias. Includes board overlays for `nrf54l15dk_nrf54l15_cpuapp_hpf_gpio` and `nrf54h20dk_nrf54h20_cpuppr`; `prj.conf` only sets `CONFIG_GPIO=y` |

## Concepts the blinky covers

These are the first Zephyr ideas you need for VIMMS firmware (Phase 9 of the
[Phono 360 roadmap](../phono-360/roadmap.md)):

- **Devicetree aliases:** `DT_ALIAS(led0)` finds the LED without hard-coding a pin.
- **Board overlays:** `boards/<board>.overlay` changes the devicetree for one board.
- **Kconfig:** `prj.conf` turns on subsystems (`CONFIG_GPIO`).
- **GPIO API:** `gpio_dt_spec`, `gpio_pin_configure_dt()`, `gpio_pin_toggle_dt()`.
- **Kernel sleep:** `k_msleep()` yields the CPU to other threads.

## Next steps

- Nordic DevAcademy *nRF Connect SDK Fundamentals*, then *Intermediate*.
- Then Phase 9 of the [Phono 360 roadmap](../phono-360/roadmap.md#phase-9-firmware-for-hardware-engineers-weeks-10-to-11).
