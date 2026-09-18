# Laser Diodes Summary

This document explains the crucial parameters found in the datasheets of the laser diodes within this folder. 

## Understanding Crucial Laser Diode Parameters

When reviewing laser diode datasheets, several key electrical and optical parameters dictate how the laser will perform and how it must be driven:

1. **Wavelength (λp or Dominant Wavelength)**: Measured in nanometers (nm), this determines the color of the laser beam. For example, ~405nm is violet, ~450nm is blue, and ~630-660nm is red.
2. **Optical Output Power (Po)**: Measured in milliwatts (mW) or Watts (W). This is the optical power emitted by the laser. Higher power means a brighter, more capable (and more dangerous) beam. Some lasers specify Continuous Wave (CW) and Pulse power limits.
3. **Threshold Current (Ith)**: The minimum electrical current required for the diode to begin "lasing" (producing a laser beam rather than just acting like a regular LED).
4. **Operating Current (Iop or If)**: The typical forward current required to drive the laser to its rated optical output power. 
5. **Operating Voltage (Vop or Vf)**: The typical forward voltage drop across the laser diode when operating at its rated output.
6. **Beam Divergence (θ// and θ⊥)**: The angle at which the laser beam spreads out. Because laser diode beams are elliptical, divergence is specified for both the parallel (θ//) and perpendicular (θ⊥) axes.
7. **Package Type**: The physical casing of the laser, often measured in diameter (e.g., Φ5.6mm or Φ9.0mm TO-CAN packages).

---

## Datasheet Summaries

### 1. Sharp GH04C01C2G (Multi-mode UV/Blue Laser Diode)
*   **Wavelength**: 450nm (Blue)
*   **Optical Output Power**: 1000mW (1W) CW / Max 1100mW at 25°C
*   **Threshold Current**: 100mA (typical)
*   **Operating Current**: 680mA (typical at 1000mW output)
*   **Operating Voltage**: 4.3V (typical)
*   **Beam Divergence**: 10° (parallel) / 45° (perpendicular)
*   **Package**: Φ5.6mm TO-CAN

### 2. Nichia NDB7775-07
*   **Wavelength**: 440nm - 455nm (Blue)
*   **Optical Output Power**: 1.6W (typical), minimum 1.4W. Can reach up to 1.8W depending on the rank.
*   **Threshold Current**: 80mA (min) to 220mA (max)
*   **Absolute Max Forward Current**: 1.7A
*   **Operating Voltage**: 3.7V to 5.5V
*   **Beam Divergence**: 14° (parallel) / 44° (perpendicular) typical

### 3. Nichia NDB7875
*   **Wavelength**: 435nm - 455nm (Blue)
*   **Optical Output Power**: 1.6W (typical), minimum 1.1W.
*   **Threshold Current**: 80mA (min) to 220mA (max)
*   **Absolute Max Forward Current**: 1.7A
*   **Operating Voltage**: 3.7V to 5.5V
*   **Beam Divergence**: 14° (parallel) / 44° (perpendicular) typical
*   **Package**: φ9.0 mm Floating Mounted

### 4. Sony SLD3232VF
*   **Wavelength**: 405nm (Violet)
*   **Optical Output Power**: 50mW
*   **Threshold Current**: 55mA (typical), 60mA (max)
*   **Operating Current**: 55mA (typical), 65mA (max)
*   **Operating Voltage**: 5.3V (typical), 5.5V (max)
*   **Beam Divergence**: 9° (parallel) / 19° (perpendicular) typical
*   **Package**: Φ5.6mm with built-in Photo Diode

### 5. Sharp GH0637AA2G
*   **Wavelength**: 638nm (Red)
*   **Optical Output Power**: 700mW (CW at -10°C to 30°C) / 500mW (CW at 30°C to 40°C)
*   **Threshold Current**: 110mA (typical), 155mA (max)
*   **Operating Current**: 810mA (typical), 930mA (max)
*   **Operating Voltage**: 2.46V (typical), 3.0V (max)
*   **Beam Divergence**: 16° (parallel) / 35° (perpendicular) typical
*   **Package**: Φ5.6mm

### 6. Sharp GH06P25A2C
*   **Wavelength**: 660nm (Red)
*   **Optical Output Power**: 100mW (CW) / 250mW (Pulse)
*   **Threshold Current**: 55mA (typical), 90mA (max)
*   **Operating Current**: 135mA (typical), 250mA (max)
*   **Operating Voltage**: 2.5V (typical), 3.5V (max)
*   **Beam Divergence**: 7-13° (parallel) / 12-19° (perpendicular) range
*   **Package**: Φ5.6mm
