# Phono 360: study roadmap

A plan for learning what you need to develop Phono 360 as its **electronics
engineer**: the mic board hardware first, plus enough firmware, signal
processing and acoustics to bring boards up, debug them and design v03 with the
firmware owner.

| Rev | Date | Author | Description |
|---|---|---|---|
| 0.1 | 2026-11-03 | Claude Code (agent) for VIMMS AS | First version, built from `Phono360` @ `d49d732` (branch with "v02 cleanup + SAI circular DMA") |
| 0.2 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Moved into the docs site; system diagram as PlantUML; links point to the VIMMS docs site |
| 0.3 | 2026-11-03 | Claude Code (agent) for VIMMS AS | Refocused on hardware for an electronics engineer: power, clocks, interfaces, protection, layout, sensors, acoustic integration, bring-up, EMC. Firmware and DSP condensed to what the hardware role needs |

!!! tip "How to use this roadmap"

    - Work through the phases in order. Each phase lists the **concepts**, **where
      they are on the board or in the code**, **what to read**, and an **exercise**
      that proves you understand it. Don't move on until you can do the exercise.
    - Hardware paths are relative to
      `C:\Users\steph\dev\vimms_hardware\VIMMS_Phono_360\VIMMS_MEMS_Interface_v02\`.
      Firmware paths are relative to `C:\Users\steph\dev\Phono360\`.
    - Knowledge-base (KB) note IDs, for example `SRC-PCB-mems-interface-v02 §7`, are
      in `C:\Users\steph\dev\vimms-engineering\knowledge\notes\`. All of them are
      still `draft`.
    - Values marked **calculated** are worked out here; **assumption** means
      check it; `TBD` means nobody has a source yet. Nothing on v02 has been
      **measured** so far.
    - Tick the boxes in the [progress checklist](#progress-checklist) at the end.

!!! note "Links to VIMMS Engineering Docs"

    Links to the Fundamentals and reference pages open the VIMMS Engineering Docs site
    at `http://127.0.0.1:8000`. Start it first with `.\scripts\docs.cmd` in
    `C:\Users\steph\dev\vimms-engineering`. This study site runs on port 8001.

!!! warning "Confidential sources stay out of this repo"

    The sensiBel SBM100B datasheet, user guide and the sensiBel email
    (`SRC-DOC-sensibel-sbm100b-feedback-2026-10-30`) are confidential. This page
    only refers to them by name or note ID. Read them in SharePoint or the
    vimms-engineering KB; don't copy their numbers into study_repo, which has a GitHub remote.

Time estimates assume about 8 to 10 hours a week next to normal work. The whole
plan is about 16 weeks. They're guesses, not a plan you have to hit.

---

## 1. What Phono 360 is, in one page

Phono 360 is a fixed outdoor noise monitor. It measures **how loud** (dB levels),
**which pitches** (spectrum) and **from which direction** (DOA, direction of
arrival) sound comes, and sends the results to the cloud.

![Phono 360 system: mics, STM32U575, LTE Node, cloud](diagrams/system-overview.svg)

What to notice:

- The STM32 does all the measuring and DSP. It only speaks **phonocom**; it never sees Protobuf or MQTT.
- The nRF9161 is a relay: phonocom frames in, Protobuf over MQTT out, and cloud commands back the other way.
- Time (UTC) and firmware updates for the STM32 both arrive through the nRF9161.

### Your board: MEMS Interface v02

| Item | Value | Source |
|---|---|---|
| Board | Round, Ø 132 mm, 4 layers, 1.6 mm, ENIG, 151 parts | `SRC-PCB-mems-interface-v02 §1` |
| Status | Rev v02.4, frozen and ordered from JLCPCB 2026-05-28. Changes go to **v03** | `§1`, VIMMS docs [Hardware](http://127.0.0.1:8000/phono-360/hardware.html) |
| MCU | STM32U575VGT6 (LQFP-100), all I/O at 1.8 V | `§5` |
| Mics | 4 × sensiBel SBM100B-I2S on 8-pin 0.5 mm FFC (J1–J4), ≈ 61 mm from centre | `§1`, `§8` |
| Power in | 3.3 V from the LTE Node over J6 today; 12/24 V field power over J7 later | `§7` |
| Rails | eFuse TPS26600 → buck LMR51420 (3.3 V) → LM66100 ideal-diode OR with the UART 3.3 V → TPS62840 buck → +1V8 for everything | `§7` |
| Interfaces | SAI1 (I2S), I2C2 (sensors + mic control), USART2 via TXU0202 level shifter, USART3 RS-485 (THVD1424), OCTOSPI flash (MX25R3235), SWD on Tag-Connect | `§6.1` |
| Sensors | LSM6DSR IMU, MMC5603NJ magnetometer, HDC2080 T/RH (firmware calls it HDC2021) | `§5` |
| Clock | 8 MHz HSE crystal, **no LSE** | `§9` |

The project files:

| File | What's in it |
|---|---|
| `VIMMS_MEMS_Interface_v02.kicad_sch` (root) + `_Power`, `_MCU_v2`, `_MIC`, `_UART` sheets | Schematic, five sheets |
| `VIMMS_MEMS_Interface_v02.kicad_pcb`, `.kicad_dru` | Layout and custom design rules |
| `VIMMS_MEMS_Interface_v02_Fabrication_Outputs/` | JLCPCB set. The folder-level `BOM.csv` and root PDF are **stale** (open issue #13) |
| `ELECTRICAL_PREFLIGHT_CHECK.md` | First power-on procedure, abort limits |
| `FIRMWARE_DEVELOPER_SUMMARY.md` | Hardware facts for firmware, first bring-up checklist, known v02 constraints |
| `Phono360/bw/` | 3D-printed enclosure ("BoxWare"), Fusion `.f3d` and `.3mf` |

---

## 2. The concept map

Everything you need, grouped by area. **Depth** is for your role:
**own** = you design it and defend it in review, **work** = you can change it
safely with help, **use** = you know what it is and what it needs from the hardware.

### Hardware (your main track)

| # | Area | Key concepts | Depth | Where |
|---|---|---|---|---|
| H1 | MEMS microphones | Sensitivity (dBFS @ 94 dB SPL), digital full scale vs AOP, EIN / self noise, SNR, PSRR, LF roll-off and phase matching, I2S output, L/R slot straps, batch matching | own | J1–J4, `_MIC` sheet; sensiBel docs (confidential) |
| H2 | Power | eFuse (UVLO/OVP divider, current limit, dV/dt, auto-retry), buck converter design and feedback dividers, ideal-diode OR-ing and priority, ferrite beads, LDO vs buck noise, split low-noise mic rail, power budget, inrush | own | `_Power` sheet, U1/U3/U4/U15/U2 |
| H3 | MCU hardware | STM32U5 supply pins (VDD, VDDA, VBAT, VDDUSB, VCAP), decoupling, NRST and BOOT0, HSE crystal and load caps, why no LSE matters, PLL to an exact 48 kHz audio clock, SWD | own | `_MCU_v2` sheet, U6, Y1, J5 |
| H4 | Digital interfaces and signal integrity | I2S clock distribution over flex, series (source) termination, rise time vs trace length, two mics sharing one data line, I2C pull-up sizing and rise time, level translation with OE, QSPI, UART at 1 Mbaud | own | R10–R17, U8, U7 |
| H5 | Field interface and protection | RS-485 half duplex (DE, RE, termination switching, fail-safe), common-mode choke, TVS, fuses, ESD arrays, cable shield bonding (RC vs hard bond), isolation trade-off | own | `_UART` sheet, J6, J7, U11, D2, D3, L3, U12 |
| H6 | Sensors in hardware | IMU and magnetometer placement, magnetic interference from currents and inductors, T/RH sensor self-heating and placement, interrupt and DRDY routing | work | U13, U5, U14 |
| H7 | PCB layout and manufacturing | 4-layer stackup, ground and power planes, buck loop and switch-node layout, net classes and custom DRC rules, ERC/DRC triage, BOM and library hygiene, JLCPCB outputs, test pads and bed-of-nails (DFT) | own | `.kicad_pcb`, `.kicad_dru`, TP1–TP25 |
| H8 | Acoustic and mechanical integration | Acoustic port length and diameter, resonance (quarter-wave / Helmholtz), gaskets, waterproof membranes and insertion loss, IP rating, condensation and icing at −20 °C, identical paths for DOA | own | `Phono360/bw/`, AN4427 |
| H9 | Bring-up and validation | Preflight checks, current-limited power-up, rail and clock measurements, scope checks of I2S and I2C, RS-485 tests, mic noise floor, channel mapping | own | `ELECTRICAL_PREFLIGHT_CHECK.md`, firmware `bringup` shell |
| H10 | EMC, safety and compliance | CE for Norway/EEA, EMC Directive, generic EMC standards (EN 61000-6-x, which parts `TBD`), ESD/EFT/surge tests (IEC 61000-4-2/-4/-5), emission sources (bucks, clocks), pre-scan, firmware freeze for testing, IP code (IEC 60529) | work | `compliance-and-testing` skill in vimms-engineering |

### Firmware, DSP and system (enough to co-design and debug)

| # | Area | Key concepts | Depth | Where |
|---|---|---|---|---|
| F1 | Acoustics | Pa, dB SPL, A/C/Z weighting, Fast/Slow, Leq, 1/3-octave bands | work | `audio/audio_dsp.c` |
| F2 | Zephyr for hardware engineers | west build and flash, devicetree and overlays (pins, peripherals), Kconfig, J-Link and RTT logs, the `bringup` shell | work | `fw/boards/`, `prj.conf`, `bringup_shell.c` |
| F3 | Audio capture | SAI master + synchronous slave, circular DMA, half-buffer timing, overrun, A/B slip | work | `audio/sai_hal.c` |
| F4 | Spectrum and direction finding | FFT bins, cross-spectra, coherence, time delay between mics, spatial aliasing, SRP-PHAT, phase calibration, c(T) | use | `fft/*.c` |
| F5 | Orientation | Tilt, eCompass, hard/soft-iron calibration, tamper | use | `sensors/*.c` |
| F6 | Link and updates | phonocom framing, link ACK, no CRC yet, MCUboot signed FOTA | use | `include/phonocom.h`, `phono_fota.c` |
| F7 | Measurement quality | Calibrator, lab vs field gain, IEC 61672-1 Class 1 (algorithm vs instrument), traceability | work | `weight_settings.c`, `tests/dsp_conformance/` |

---

## 3. The roadmap, phase by phase

### Phase 0: Orientation (week 1)

**Goal:** know the system and open every design file without errors.

Read:
- VIMMS docs: [Overview](http://127.0.0.1:8000/phono-360/index.html),
  [Hardware](http://127.0.0.1:8000/phono-360/hardware.html) (block diagram, power tree, pin map, connectors),
  [Known issues](http://127.0.0.1:8000/phono-360/open-issues.html)
- `FIRMWARE_DEVELOPER_SUMMARY.md` and `ELECTRICAL_PREFLIGHT_CHECK.md`
- KB topic `TOP-product-phono-360`, then notes `SRC-SCH-mems-interface-v02.4-sch` and `SRC-PCB-mems-interface-v02`

Do:
1. Open the v02 project in KiCad 10 with the libraries set up per `vimms_hardware/README.md`.
   Expect library-path warnings: symbol links point to the designer's Mac (`SRC-PCB-mems-interface-v02 §4`).
2. Walk the five schematic sheets and mark each block on the VIMMS block diagram.
3. Run ERC and DRC (kicad-cli, or the `kicad-design` skill in vimms-engineering).
   Compare with the KB numbers: ERC 0 errors / 41 warnings, DRC 11 errors (all U13 pad-to-pad).

**Exercise:** redraw the block diagram and power tree from the schematic alone, then
compare with the VIMMS [Hardware](http://127.0.0.1:8000/phono-360/hardware.html) page.

---

### Phase 1: Acoustics and MEMS microphones (weeks 1 to 2)

**Goal:** you can read a MEMS mic datasheet and say what each number means for the product.

Concepts:
- Sound basics: Pa, dB SPL (0 dB = 20 µPa, 94 dB ≈ 1 Pa), adding levels, A/C/Z weighting, Leq.
- Mic specs: sensitivity in dBFS at 94 dB SPL, digital full scale, AOP (a distortion
  limit), EIN and SNR, PSRR (why the supply rail matters), LF corner and its phase
  shift, sensitivity tolerance and why batch matching matters for four mics.
- The SBM100B is an **optical** MEMS mic with I2S output and an I2C control port;
  its slot straps (CFG0 on the board, others on the flex) set the L/R slot.

Read:
- VIMMS Fundamentals [Sound and decibels](http://127.0.0.1:8000/phono-360/fundamentals/sound-and-decibels.html) and
  [Digital audio](http://127.0.0.1:8000/phono-360/fundamentals/digital-audio.html)
- KB `SRC-DS-sbm100b-product-brief-2025` (public), then the confidential sensiBel datasheet and
  email note in SharePoint / the KB
- `Phono360/docs/an4427-gasket-design-…pdf` (ST AN4427, MEMS mic acoustic path)

**Exercises**
1. Sensitivity −46 dBFS at 94 dB SPL (from `fw/README.md`). What SPL is digital
   full scale? (**calculated:** 140 dB SPL.) Why is the 146 dB AOP in the README
   a different limit? (open issue #18)
2. Two mics have first-order LF corners at 8 Hz and 12 Hz (example values). At
   234 Hz, the lowest frequency used for direction finding, the phase difference is
   atan(12/234.4) − atan(8/234.4) ≈ 0.98° (**calculated**). Convert it to a time
   delay and then to a bearing error for the 122 mm pair (Δτ·c/d). Why does this
   argue for buying mics from one batch?
3. Why does mic PSRR make the DNP low-noise mic rail (FB1/C4/C6) a real decision for v03?

---

### Phase 2: Power (weeks 2 to 4)

**Goal:** you can explain and recalculate every power part on the board, and judge the v03 options.

Concepts:
- **Input protection:** F1 fuse, D2 SMAJ33CA TVS, TPS26600 eFuse: UVLO and OVP set
  by one divider (R1/R2/R3), current limit (R7), dV/dt (C8), auto-retry mode.
- **Buck converters:** LMR51420 (field VIN → 3.3 V), feedback divider R8/R9,
  inductor choice (L2), input/output caps; TPS62840 (3.3 V → 1.8 V, VSET strap).
- **OR-ing:** two LM66100 ideal diodes; field power has priority and disables the
  UART 3.3 V path (CE pin wiring). Reverse-current blocking.
- **Noise:** ferrite beads (FB2 before the 1.8 V buck), buck ripple vs mic PSRR,
  the option of a split mic rail.
- **Budget:** the DRU comment says "+3V3 supplies up to ~275 mA". That's a
  comment, not a measured budget.

Read: `_Power` sheet; KB `SRC-PCB-mems-interface-v02 §7`, `SRC-SCH-mems-interface-v02.4-sch §3, §6`,
`SRC-DS-lm66100-ds-slvsez8a`; the TPS26600, LMR51420 and TPS62840 datasheets from TI
(not in the KB yet: a good first `kb-ingest`).

**Exercises**
1. TPS26600 divider (R1 909 k, R2 97.6 k, R3 38.3 k): UVLO node fraction =
   (R2 + R3)/(R1 + R2 + R3) = 0.1301; OVP node fraction = R3/total = 0.0367
   (**calculated** in the KB). Find the UVLO/OVP reference voltages in the TPS26600
   datasheet and work out the real trip points. Do they match the schematic note
   "9 V UVLO, 31 V OVP"? (KB says `TBD`.)
2. LMR51420: Vout = VFB × (1 + R8/R9) = VFB × 5.525. Look up VFB and check the 3.3 V
   rail. The KB assumes 0.6 V, which gives 3.315 V.
3. Trace what happens when both J6 3.3 V and J7 field power are present, then when
   field power drops out. Which LM66100 conducts in each case?
4. The preflight check asks you to measure the "mic quiet rail" after FB2, but on
   the built board FB2 feeds the 1.8 V buck input (≈ 3.3 V), and the mic rail parts
   are DNP. Write the corrected step (`SRC-SCH-mems-interface-v02.4-sch §3`).
5. Write a per-rail power budget table (MCU at 160 MHz, four mics, sensors,
   flash, RS-485 transmitting, level shifter) with datasheet typ/max values, and compare it with the 275 mA comment.

---

### Phase 3: MCU hardware and clocks (week 4)

**Goal:** the STM32U575 is powered, clocked and debuggable by design, and you know why each part is there.

Concepts:
- Supply pins: all on +1V8 (VDD ×5, VDDA, VREF+, VBAT, VDDUSB), VCAP with 4.7 µF,
  decoupling per pin, analog supply filtering.
- Reset and boot: NRST with 10 k pull-up, 100 nF, reset button SW1, reset from the LTE
  Node through R35 1 k; BOOT0 (PH3) pulled down by R18 100 k.
- HSE: 8 MHz crystal Y1, C21/C22 18 pF, R20 0 Ω. Load capacitance, drive level,
  start-up margin (gain margin).
- No LSE: no 32 kHz crystal, so the MSI can't be trimmed by PLL mode. The audio clock
  must come from the HSE through PLL2 to get an exact 48 kHz sample rate.
- Why the sample clock matters: a sample-rate error shifts the A-weighting curve and
  the 1/3-octave band edges by the same fraction.
- Debug: SWD on a TC2030 Tag-Connect (J5), no SWO, no USB on v02.

Read: `_MCU_v2` sheet; KB `SRC-UM-rm0456-stm32u5-rm` (RCC, power chapters); ST AN2867
"Oscillator design guide for STM8AF/AL/S, STM32 MCUs and MPUs"; ST's hardware
getting-started application note for STM32U5; open issue #5 (HSE vs MSIS for PLL2).

**Exercises**
1. Crystal load: CL ≈ C21·C22/(C21 + C22) + Cstray = 9 pF + Cstray. With Cstray ≈ 3 pF
   (**assumption**) that's ≈ 12 pF. Find the crystal's specified CL in the ECS datasheet
   and decide whether 18 pF is right.
2. Using AN2867, calculate the oscillator gain margin for Y1 with the STM32U5 HSE gm value.
3. In `fw/boards/stm32u575vg_vimms.overlay`, find how the PLLs are clocked. Which
   clock source does the SAI get at run time, and how would you **measure** the real
   sample rate on the bench? (Hint: WS is 48 kHz on the scope.)

---

### Phase 4: Digital interfaces and signal integrity (weeks 5 to 6)

**Goal:** every bus on the board works with margin over the real cables.

Concepts:
- **I2S to four flex cables:** one BCLK and one WS shared by all four mics, up to
  ~150 mm away (`SRC-PCB-mems-interface-v02 §6.2`). BCLK = 48 kHz × 2 slots × 32 bit
  = 3.072 MHz. 22 Ω series resistors at the source (R12–R15). Source termination,
  reflections, edge rate vs trace length, crosstalk from BCLK into SD lines.
- **Shared data lines:** N/S share SD_A, W/E share SD_B; each mic drives only its slot
  and tri-states the other. Turn-around timing matters.
- **I2C2:** one bus for the IMU, magnetometer, T/RH and all four mic control ports,
  partly out on the flexes. 1.8 kΩ pull-ups to 1.8 V, 22 Ω series on the mic side.
  Bus capacitance, rise time, Fast-mode limits.
- **Level shifting:** TXU0202 fixed-direction translator, OE driven by TXS_EN (PD4); the
  firmware must enable it before the first UART byte.
- **QSPI:** MX25R3235 at 1.8 V, NCS pull-up.

Read: `_MIC` and `_UART` sheets; NXP UM10204 *I2C-bus specification* (rise time and
pull-up sections); Howard Johnson, *High-Speed Digital Design* (termination
chapter) or Eric Bogatin, *Signal and Power Integrity, Simplified*; the TXU0202 datasheet.

**Exercises**
1. I2C rise time: t_r ≈ 0.8473·R·C. With R = 1.8 kΩ and an **assumed** 100 pF bus
   (board + four flexes + seven devices), t_r ≈ 152 ns (**calculated**). Compare with
   the Fast-mode (400 kHz) and Fast-mode Plus limits in UM10204. Which bus speed is safe?
2. Minimum pull-up at 1.8 V: R_min = (VDD − VOL)/IOL. Use the UM10204 values for
   VDD < 2 V and check that 1.8 kΩ is above it.
3. Estimate the propagation delay of a 150 mm flex trace and compare it with the
   STM32 output rise time at the configured GPIO speed (STM32U575 datasheet). Is
   the 22 Ω source termination needed, and how would you check it on a scope?
4. Why must CFG0 be opposite on J1 and J2 (and on J3 and J4)? What do you see in
   the data if both mics on one line are strapped to the same slot?

---

### Phase 5: Field interface and protection (weeks 6 to 7)

**Goal:** you can defend the J6/J7 design against ESD, surge and long-cable problems.

Concepts:
- **RS-485 (future link to LTE Node v2):** THVD1424 half duplex, DE/RE_N control,
  switchable termination (TERM_TX), 100 k pull-downs so the bus stays quiet at reset,
  fail-safe biasing, slew-rate mode, 1 Mbit/s target, 120 Ω end termination.
- **Protection:** D3 SM712 TVS (asymmetric, for RS-485 common-mode range), L3
  common-mode choke, R30/R31 10 Ω, F1/F2 0.5 A fuses, D2 SMAJ33CA on field VIN,
  U12 TPD4E1U06 ESD array on the UART, D4/D1 on the 3.3 V inputs.
- **Shields:** J6 and J7 shields to GND through 1 MΩ ∥ 4.7 nF, with a DNP 0 Ω
  hard-bond option. Trade-off between ground loops and RF shielding.
- **Non-isolated RS-485 with field power on long cables:** when to add isolation
  ("Add isolation if cable/ground risk is high" is a note on the schematic).
- The other end: LTE Node v04 connectors J8/J9 (KB `SRC-PCB-lte-node-v04 §8`, open issue #11).

Read: `_UART` sheet; KB `SRC-SCH-mems-interface-v02.4-sch §6, §8`; TI *The RS-485 Design
Guide*; THVD1424 and TPS26600 datasheets; Henry Ott, *Electromagnetic Compatibility
Engineering* (cable shields and grounding chapters).

**Exercises**
1. Shield RC: impedance of 4.7 nF at 50 Hz and at 1 MHz (|Z| = 1/(2πfC): about 677 kΩ
   and 34 Ω, **calculated**). Explain what that does for ground loops vs RF currents, and
   what the 1 MΩ is for.
2. Draw the current path of a surge on J7 D+ to ground. Which parts take the energy,
   in which order, and what does the CMC do?
3. When must TERM_TX be on, and what happens to signal levels if two nodes on the bus terminate?

---

### Phase 6: Sensors in hardware (week 8)

**Goal:** the IMU, magnetometer and T/RH sensor give useful data because of where and how they're placed.

Concepts:
- **Magnetometer (MMC5603NJ):** distance from inductors (L1, L2), high-current traces
  and steel; SET/RESET; the firmware only trusts a heading when |B| is 20–80 µT.
  Heading is only usable on a non-magnetic mount, ≥ 0.3–0.5 m from steel (`fw/README.md`).
- **IMU (LSM6DSR):** on I2C (not SPI) on v02, so no high-rate vibration streaming;
  INT1/INT2 routed to PC6/PC7; the KiCad symbol is `LSM6DS3` but the fitted part is
  `LSM6DSRTR` (`FIRMWARE_DEVELOPER_SUMMARY.md`).
- **T/RH (HDC2080):** measures enclosure air, so it reads warm in sun; self-heating
  from nearby parts; DRDY not routed. Its temperature sets the speed of sound for DOA.
- The 0.5 mm-pitch LGA of U13 causes the 11 DRC clearance "errors": know why they're
  acceptable (`SRC-PCB-mems-interface-v02 §4`).

Read: `fw/src/sensors/ARCHITECTURE.md`, `MAGNETOMETER_CALIBRATION.md`;
`fw/reports/imu-mag-gnss-bearing-report.md`; MMC5603NJ, LSM6DSR and HDC2080 datasheets.

**Exercises**
1. Field from a straight trace: B = µ0·I/(2π·r). 100 mA at 5 mm gives 4 µT
   (**calculated**), against an earth field of roughly 50 µT. What does a 1 A buck
   inductor current do at 10 mm? Check U5's distance to L1/L2 on the PCB.
2. Why is hard-iron calibration done with the device fully assembled, and what does a
   steel mounting bracket do to it?

---

### Phase 7: PCB layout, DFM and DFT (weeks 8 to 9)

**Goal:** you can review and improve the v02 layout and prepare clean v03 outputs.

Concepts:
- Stackup: F.Cu signals / In1 GND / In2 +1V8 / B.Cu; no controlled impedance needed
  (`SRC-PCB-mems-interface-v02 §2`).
- Placement: mic connectors at the four edge midpoints at r ≈ 61 mm (array geometry is
  set by the board), MCU near centre, power and RS-485 front end grouped, magnetometer away from the bucks.
- Buck layout: hot loop, switch node area, feedback routing, input caps.
- Rules: net classes, custom `.kicad_dru` rules. The DRU names classes
  (`Power_3V3`, `Power_1V8`, `CABLE_VIN`, `RS485`, `SW_Node`) that the project never
  defines, so those rules match nothing (open issue #14).
- Hygiene: stale BOM/PDF (#13), stale schematic notes (BOOT0 says R21, should be R18;
  the mic-rail note names the wrong parts), library paths, the `~` vs empty datasheet
  field parity warnings.
- Manufacturing: JLCPCB set, 122 placements, J1–J4 Molex FFC without an LCSC code
  (manual stock). Test: TP1–TP5, TP24/25 power loops, TP6–TP23 bottom pads for a bed-of-nails fixture.

Read: KB `SRC-PCB-mems-interface-v02 §2–5, §10–11` (with layer renders);
`SRC-PCB-mems-interface-v02-jlcpcb-2026-05-28`; TI "Five steps to a great PCB layout for a
step-down converter"; the `pcb-design-review` skill checklist in vimms-engineering.

**Exercises**
1. Do a placement and routing review of v02 with the `pcb-design-review` checklist and
   write the findings as a v03 list.
2. Create the missing net classes in a copy of the project, bind the DRU rules, rerun DRC
   and record what's new.
3. Sketch a production test: which test pads and which firmware `bringup` commands would
   a bed-of-nails fixture use?

---

### Phase 8: Acoustic and mechanical integration (weeks 9 to 10)

**Goal:** the sound reaching the mic is the sound outside the box, at −20 °C and in rain.

Concepts:
- The mics hang below the PCB and face down through ports in a 3D-printed PETG
  bottom plate (`SRC-CAD-phono360-boxware-assembly-v17 §3`).
- Port acoustics: a long, narrow port plus a front cavity forms a resonance that
  boosts some frequencies and cuts others. AN4427's rule is "short and wide, and identical".
- Measured on the v17 model: port 13.5 mm long, ≈ 4 mm wide, 1.07 mm ungasketed gap
  to the mic (open issue #19). sensiBel's recommendation for path and gasket is in the
  confidential note.
- Gaskets and membranes: integrated-gasket membranes, insertion loss in magnitude
  **and phase**, IP rating, water and insect traps, drainage, icing.
- For DOA, all four paths must be identical, and calibration has to be done with the final membrane and foam fitted.

Read: AN4427 (in `Phono360/docs/`); KB `SRC-CAD-phono360-boxware-assembly-v17`,
`SRC-AN-an4427-mems-mic-gasket`; `Phono360/bw/readme.md`; the confidential sensiBel note.

**Exercises**
1. Quarter-wave resonance of a tube closed at the mic end: f ≈ c/(4·L_eff),
   L_eff = 13.5 mm + 0.6 × 2.05 mm ≈ 14.7 mm → ≈ 5.8 kHz (**calculated** in the KB). Which
   1/3-octave bands does it affect, and what does it do to A-weighted levels?
2. Propose a v18 port and gasket stack that meets AN4427's guidance, and list what you'd
   measure to prove it (frequency response vs a reference mic, phase match between ports).
3. List what changes at −20 °C: PETG stiffness and gasket compression, condensation on the
   membrane, MLCC capacitance, eFuse and buck start-up at low temperature.

---

### Phase 9: Firmware for hardware engineers (weeks 10 to 11)

**Goal:** you can build, flash and use the firmware to test your hardware, and change pins yourself.

Concepts:
- Zephyr build with sysbuild (MCUboot + app): `fw/build_sysbuild.ps1`,
  `fw/flash_sysbuild.ps1 -JLinkSerial <serial>` (J-Link through Tag-Connect).
- Where the hardware is described: the board definition `fw/boards/st/stm32u575vg_vimms/`
  (`.dts`, `_defconfig`) and the app overlay `fw/boards/stm32u575vg_vimms.overlay`
  (pins, I2C, UART, OCTOSPI, flash partitions, `txs_en` GPIO).
- Kconfig switches for hardware features: `CONFIG_PHONO_RS485`, `CONFIG_PHONO_EXTFLASH`,
  `CONFIG_PHONO_IMU_MAG_I2C`, `CONFIG_PHONO_SBM100B_I2C` (set differently in two files: open issue #4),
  `CONFIG_PHONO_SAI_CLK_HSE`, `CONFIG_PHONO_BRINGUP_SHELL`.
- Logs over Segger RTT; the `bringup` shell over RTT (`bringup info`, `power`, `clock hse`,
  `i2c scan`, `whoami`, `uart en/tx`, `sai start/stats`, `rs485 …`, `qspi id/test`).
- Audio capture in one paragraph: SAI1_A (N, S) is master, SAI1_B (W, E) is a synchronous
  slave; each streams through circular GPDMA into a 2 × 256-word buffer. A/B slip and
  overruns are counted and shown by `bringup sai stats`.

Read: VIMMS docs [Getting started](http://127.0.0.1:8000/phono-360/getting-started.html) and
[Embedded and communication](http://127.0.0.1:8000/phono-360/fundamentals/embedded-and-comms.html);
`fw/README.md` sections "Building" and "VIMMS v02 first-firmware bring-up"; Nordic
DevAcademy *nRF Connect SDK Fundamentals* (the Zephyr parts carry over). Your
[nRF blinky study](../firmware/index.md) covers the devicetree basics.

**Exercises**
1. Build the image with `CONFIG_PHONO_BRINGUP_SHELL=y` and `CONFIG_SHELL=y`. Find in the
   build output's `.config` which value of `CONFIG_PHONO_SBM100B_I2C` won.
2. Pretend v03 moves TXS_EN from PD4 to another pin. Change the overlay, rebuild, and
   list every other file you'd have to check.
3. Half-buffer time: 256 words per half, 2 × 32-bit slots per frame at 48 kHz →
   128 frames → 2.67 ms (**calculated**); the code comment says 1.33 ms (open issue #17).
   How would you measure it with a GPIO toggle and a scope?

---

### Phase 10: Bring-up and validation (weeks 11 to 12)

**Goal:** you can take a bare v02 board to four working mics and record the evidence.

Steps, in order (`ELECTRICAL_PREFLIGHT_CHECK.md`, then `FIRMWARE_DEVELOPER_SUMMARY.md`
"First Firmware Bring-Up Checklist"):

1. Visual inspection and unpowered short checks.
2. Current-limited power from the UART side (TP4), then from field VIN (TP3), never both.
   Abort above +1V8 1.90 V or +3V3 3.45 V, or any mic pin above 2.0 V.
3. Connector voltages on J1–J4, J6, J7 **before** fitting flexes or cables.
4. SWD connect, MCU identity, reset, HSE start-up.
5. I2C scan (expect 0x30, 0x41, 0x6A), WHO_AM_I reads; measure SCL/SDA rise time.
6. UART level shifter, link to the LTE Node or a USB-UART adapter.
7. SAI clocks on the scope: BCLK 3.072 MHz, WS 48 kHz, before mics stream.
8. Mics: capture, channel mapping with a near-field source on each mic in turn, noise floor in a quiet room.
9. RS-485 on a short cable with termination off, then on; then long cable with field power.
10. QSPI flash JEDEC ID (C2 28 16) and erase/write/read test.

Read: both checklists above; the `hardware-design` skill (bring-up section) in vimms-engineering.

**Exercises**
1. Turn the two checklists into one bring-up record template (step, expected, measured,
   instrument, pass/fail, photo) and keep it in `docs/phono-360/` here.
2. Find the checklist mismatch: step 1 asks you to verify `VDD1V8_MIC_LN`, which is DNP on v02.

---

### Phase 11: The signal chain and DOA: what they need from hardware (weeks 12 to 13)

**Goal:** you know which hardware errors the firmware can calibrate out and which it can't.

Concepts at "use" depth:
- Levels: A/C/Z weighting as biquad filters, Fast/Slow, Leq over 5 s, 1/3-octave
  bands from a 1024-point FFT (Δf = 48000/1024 = 46.875 Hz).
- Direction finding: the time delay between mic pairs, spatial aliasing
  (f_max = c/2d → 1406 Hz for the 122 mm pairs, 1988 Hz for the 86.3 mm pairs), SRP-PHAT
  over 72 angles, phase calibration, speed of sound from the HDC2080 temperature.

What the DSP needs from your hardware:

| Hardware property | Why it matters | Who handles it |
|---|---|---|
| Exact sample rate (HSE → PLL2) | Weighting and band edges scale with it | Hardware + clock config; not calibrated |
| Mic sensitivity match | Level error per mic; energy weighting in DOA; mic-health baseline | Per-mic lab/field calibration |
| Mic phase match (LF corner, port acoustics) | Bearing error, worst at low frequency | DOA phase calibration (v5), only for the fitted enclosure |
| Mic positions (r = 61 mm, 90° apart) | Steering model assumes this geometry | Set by PCB + enclosure; not calibrated |
| Mic noise floor (PSRR, rail noise) | Under-range limit, low-level DOA | Hardware |
| Identical acoustic paths | Phase and level match across channels | Enclosure design |
| Correct channel mapping (CFG0 straps) | Wrong mic = mirrored or rotated bearings | Hardware; verify at bring-up |

Read: VIMMS Fundamentals [Spectrum and filters](http://127.0.0.1:8000/phono-360/fundamentals/spectrum-and-filters.html),
[Finding the direction](http://127.0.0.1:8000/phono-360/fundamentals/direction-finding.html),
[Calibration and accuracy](http://127.0.0.1:8000/phono-360/fundamentals/calibration-and-accuracy.html);
`fw/reports/doa-slm-review-summary.md` and `temperature-impact-doa-slm-report.md`.

**Exercises**
1. A mic sits 0.5 mm off its nominal radius. What's the delay error (Δτ = 0.5 mm / 343 m/s ≈ 1.5 µs,
   **calculated**), and how does it compare with the phase-mismatch error from Phase 1?
2. Run the host test suites (`west twister -T fw/tests/dsp_conformance -p native_sim`, and
   `doa_simulation`) in WSL so you can rerun them after changing assumptions.

---

### Phase 12: EMC, environment and compliance (weeks 13 to 14)

**Goal:** you can plan a pre-compliance campaign for the mic board and know what freezes before testing.

Concepts:
- Norway is in the EEA: CE marking. The mic board has no radio; the LTE Node carries
  the radio (RED). The mic board is part of the apparatus for the EMC Directive
  (2014/30/EU). The Low Voltage Directive starts at 75 V DC, above the 12/24 V supply.
  Which harmonised EMC standards apply (residential vs industrial EN 61000-6-x) is `TBD`.
- Immunity tests to plan for: ESD (IEC 61000-4-2) on connectors and enclosure, EFT
  (IEC 61000-4-4) and surge (IEC 61000-4-5) on the field cable. Emissions from the two
  bucks and the 3 MHz BCLK on flex cables.
- Pre-scan: near-field probes, LISN on the field supply, the shield-bond options.
- Firmware under test: freeze and record the commit, because clock source and DMA timing
  changed recently (`open-issues` "Compliance and privacy").
- Environment: −20 °C minimum operating target (VIMMS website claim), condensation,
  IP code (IEC 60529) for the enclosure and membranes.
- Measurement standards: IEC 61672-1/-2/-3 (sound level meters). "Class 1" in CI only
  tests the algorithm; the instrument needs pattern evaluation, which depends on your
  mic, port and membrane choices.

Read: the `compliance-and-testing` skill in vimms-engineering; KB `SRC-STD-iec-61672-1-2013`,
`SRC-STD-iec-61672-2-2013-amd1-2017`, `SRC-STD-iec-61672-3-2013`; Henry Ott (as above).

**Exercises**
1. Write an EMC pre-scan plan for v02: setups, cables, probes, which DNP options you'd try
   (shield hard bond, C45), and pass criteria.
2. List the hardware changes that would force a re-test after a certification test
   (crystal, buck, mic part, port geometry, membrane).

---

### Phase 13: Contribute: v03 (from week 10, ongoing)

Start contributing early. Candidate v03 items, from the KB notes and open issues:

1. Fix the stale schematic notes (BOOT0 R21 → R18; mic-rail note FB2/C8/C9 → FB1/C4/C6) and the preflight FB2 step.
2. Delete or regenerate the stale folder BOM.csv and root PDF (#13).
3. Define net classes so the DRU rules apply (#14).
4. Normalise the library links and the `LSM6DS3` symbol vs `LSM6DSRTR` part.
5. Calculate the TPS26600 trip points and ingest the TI datasheets into the KB.
6. Decide the low-noise mic rail after measuring the v02 mic noise floor.
7. Route HDC2080 and MMC5603NJ DRDY if the firmware wants them; LSM6 on SPI if vibration data is needed.
8. RS-485 isolation decision for field cables.
9. Enclosure: shorter port, gasket or integrated-gasket membrane, drainage (#19).
10. Confirm which LTE Node connector (J8 or J9) and cable the bench units use (#11).

Every v03 change that affects clocks, power, mics or the acoustic path is a
certification-impact item: note it as such in the change list.

---

## 4. Suggested reading order

### Hardware

| # | Item | Why now |
|---|---|---|
| 1 | VIMMS docs [Hardware](http://127.0.0.1:8000/phono-360/hardware.html) | The map |
| 2 | Root schematic sheet + TODO notes | Scope and known to-dos |
| 3 | `_Power` sheet + KB `§7` | Everything depends on it |
| 4 | `_MCU_v2` sheet | Supplies, reset, crystal, debug |
| 5 | `_MIC` sheet | I2S, I2C, straps, connectors |
| 6 | `_UART` sheet | UART, RS-485, protection, shields |
| 7 | `.kicad_pcb` + `.kicad_dru` with KB `§2–5` | Layout and rules |
| 8 | `ELECTRICAL_PREFLIGHT_CHECK.md`, `FIRMWARE_DEVELOPER_SUMMARY.md` | Bring-up |
| 9 | `Phono360/bw/` + KB `SRC-CAD-phono360-boxware-assembly-v17` | Enclosure and ports |

### Firmware (only these)

| # | File | Why |
|---|---|---|
| 1 | `fw/src/main.c` | Boot order: TXS_EN first, then everything else |
| 2 | `fw/boards/stm32u575vg_vimms.overlay`, `boards/st/stm32u575vg_vimms/*.dts` | Your pins in firmware form |
| 3 | `fw/prj.conf`, `fw/boards/stm32u575vg_vimms.conf` | Which hardware features are built in |
| 4 | `fw/src/bringup_shell.c` | Your bring-up tool |
| 5 | `fw/src/audio/sai_hal.c` (header comment, init, error callback) | How the mics are captured |
| 6 | `fw/src/rs485_drv.c`, `extflash.c`, `sensors/imu_mag_i2c.c` | Drivers for your peripherals |

---

## 5. Recommended external resources

| Topic | Resource |
|---|---|
| EMC and grounding | Henry W. Ott, *Electromagnetic Compatibility Engineering* |
| Signal integrity | Howard Johnson, *High-Speed Digital Design*; Eric Bogatin, *Signal and Power Integrity, Simplified* |
| I2C | NXP UM10204, *I2C-bus specification and user manual* |
| RS-485 | TI, *The RS-485 Design Guide* |
| Crystals | ST AN2867, oscillator design guide for STM32 |
| Buck layout | TI, "Five steps to a great PCB layout for a step-down converter" |
| STM32U5 hardware | ST's getting-started hardware application note for STM32U5; RM0456 (in `Phono360/docs/`) |
| MEMS mic integration | ST AN4427 (in `Phono360/docs/`); sensiBel documents (confidential, SharePoint) |
| Zephyr basics | Nordic DevAcademy nRF Connect SDK Fundamentals; docs.zephyrproject.org devicetree guide |
| DSP, when needed | Steven W. Smith, *The Scientist and Engineer's Guide to DSP* (free, dspguide.com) |
| Sound level meters | IEC 61672-1/-2/-3 (KB notes) |

---

## 6. Glossary

| Term | Meaning |
|---|---|
| AOP | Acoustic overload point: SPL where mic distortion reaches a set limit |
| BCLK / WS | I2S bit clock / word select (frame clock = sample rate) |
| CFG0 | Strap that picks the mic's I2S slot (left or right) |
| CMC | Common-mode choke |
| DNP | Do not place (footprint on the board, part not fitted) |
| DOA | Direction of arrival |
| DRU | KiCad custom design-rules file (`.kicad_dru`) |
| EIN | Equivalent input noise of a mic (its self noise as an SPL) |
| eFuse | Integrated protection switch: current limit, UVLO, OVP, soft start |
| HSE / LSE | STM32 high-speed / low-speed external oscillator |
| Leq | Equivalent continuous sound level over a period (5 s here) |
| phonocom | Binary UART protocol between the STM32 and the nRF9161 |
| PSRR | Power-supply rejection ratio |
| SAI | STM32 serial audio interface (I2S/TDM capable) |
| TVS | Transient voltage suppressor |
| UVLO / OVP | Under-voltage lockout / over-voltage protection |

---

## Progress checklist

- [ ] Phase 0: project opens; ERC/DRC results match the KB; block diagram redrawn
- [ ] Phase 1: full scale vs AOP explained; phase-mismatch bearing error calculated
- [ ] Phase 2: eFuse trip points and buck output calculated from datasheets; power budget written
- [ ] Phase 3: crystal load and gain margin checked; sample-clock path explained
- [ ] Phase 4: I2C rise time and pull-up checked; I2S termination judged
- [ ] Phase 5: shield RC and surge path explained; termination rules clear
- [ ] Phase 6: magnetometer interference estimated from the real layout
- [ ] Phase 7: v02 layout review written; net classes bound in a test copy
- [ ] Phase 8: port resonance understood; v18 port/gasket proposal sketched
- [ ] Phase 9: firmware built and flashed; overlay pin change done; `.config` checked
- [ ] Phase 10: bring-up record template made; first v02 board brought up
- [ ] Phase 11: hardware-vs-calibration table understood; host tests run
- [ ] Phase 12: EMC pre-scan plan written
- [ ] Phase 13: first v03 change merged
