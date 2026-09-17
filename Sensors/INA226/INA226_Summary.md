# INA226 Sensor Summary

## Overview
The INA226 is a 36V, 16-Bit, ultra-precise I2C/SMBus-compatible current, voltage, and power monitor with an alert pin. It can measure both the voltage drop across a shunt resistor (shunt voltage) and the bus supply voltage. It uses a programmable calibration value, conversion times, and averaging, along with an internal multiplier, to provide direct readouts of current (Amperes) and power (Watts).

## Key Features
* **Voltage Range:** Senses bus voltages from 0V to 36V (independent of supply voltage).
* **Power Supply:** Operates from a single 2.7V to 5.5V supply.
* **Sensing Type:** High-side or low-side sensing.
* **High Accuracy:** 0.1% maximum gain error, 10μV maximum offset.
* **Interface:** I2C- or SMBUS-compatible with up to 16 programmable addresses.
* **Package:** 10-pin DGS (VSSOP).

## Pin Configuration
| Pin | Name | Type | Description |
|---|---|---|---|
| 1 | A1 | Digital Input | Address pin. |
| 2 | A0 | Digital Input | Address pin. Connect A0 and A1 to GND, SCL, SDA, or VS to set the I2C address (up to 16 combinations). |
| 3 | Alert | Digital Output | Multi-functional alert, open-drain output. |
| 4 | SDA | Digital I/O | Serial bus data line. |
| 5 | SCL | Digital Input | Serial bus clock line. |
| 6 | VS | Analog | Power supply (2.7V to 5.5V). |
| 7 | GND | Analog | Ground. |
| 8 | VBUS | Analog Input | Bus voltage input (0V to 36V). |
| 9 | IN- | Analog Input | Connect to the load side of the shunt resistor. |
| 10 | IN+ | Analog Input | Connect to the supply side of the shunt resistor. |

## Core Functionality
1. **Shunt Voltage Measurement:** Measures the differential voltage across a shunt resistor via the `IN+` and `IN-` pins.
2. **Bus Voltage Measurement:** Measures the bus supply voltage via the `VBUS` pin with respect to ground.
3. **Current & Power Calculation:** Calculates current using the measured shunt voltage and a programmed `Calibration Register`. Power is calculated using the derived current and the measured bus voltage.
4. **Operating Modes:** Can be set to continuous measurement, triggered (single-shot), or power-down mode to save power.
5. **Averaging & Conversion Time:** Programmable averaging (up to 1024 samples) and conversion times (140μs to 8.244ms) help filter noise and optimize the update rate.

## Calibration and Programming
To get valid current and power readings, you **must** program the `Calibration Register (05h)`.
1. **Calculate Current_LSB:**
   `Current_LSB = Maximum Expected Current / 32768` (2^15)
   *(It is common to select a round number slightly above this calculated value to simplify calculations).*
2. **Calculate Calibration Register Value:**
   `CAL = 0.00512 / (Current_LSB * R_SHUNT)`
   *(Write this value to register 05h)*
3. **Power_LSB:**
   `Power_LSB = 25 * Current_LSB`

## Alert Pin Features
The `Alert` pin is an open-drain output that can be configured to assert for the following conditions:
* Shunt Voltage Over-Limit / Under-Limit
* Bus Voltage Over-Limit / Under-Limit
* Power Over-Limit
* Conversion Ready (signals when a measurement sequence is completed)

## Important Registers
* **00h (Configuration):** Sets averaging mode, conversion times, and operating mode (continuous/triggered/power-down).
* **01h (Shunt Voltage):** Contains the measured differential shunt voltage.
* **02h (Bus Voltage):** Contains the measured bus voltage.
* **03h (Power):** Contains the calculated power (Watts) based on Power_LSB.
* **04h (Current):** Contains the calculated current (Amps) based on Current_LSB.
* **05h (Calibration):** Programmed to set the scaling for Current and Power calculations.
* **06h (Mask/Enable):** Selects which alert function is active.
* **07h (Alert Limit):** The threshold value used to trigger the alert pin.
