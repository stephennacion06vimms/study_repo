# INA226 & MCU Connection Diagram (Maximizing Features)

To fully utilize all the features of the INA226—specifically to avoid polling the I2C bus and to use hardware interrupts for **Conversion Ready** or **Over-Limit** alarms—you must connect the `Alert` pin to a GPIO interrupt pin on your microcontroller.

Below is a schematic diagram showing the complete wiring for high-side current sensing with hardware interrupt support.

```mermaid
flowchart LR
    %% Define Nodes
    subgraph MCU["Microcontroller (e.g., ESP32)"]
        direction TB
        M_3V3[3.3V / 5V Out]
        M_GND[GND]
        M_SDA[SDA GPIO]
        M_SCL[SCL GPIO]
        M_INT[Interrupt GPIO]
    end

    subgraph INA226["INA226 Module"]
        direction TB
        I_VS[VS - Power]
        I_GND[GND]
        I_SDA[SDA]
        I_SCL[SCL]
        I_ALERT[Alert]
        I_A0[A0]
        I_A1[A1]
        I_VBUS[VBUS]
        I_IN_PLUS[IN+]
        I_IN_MINUS[IN-]
    end

    subgraph PowerSystem["High-Voltage Power System"]
        direction TB
        P_SRC["Power Source (0-36V)"]
        LOAD["Load (Motor, LED, etc.)"]
        P_GND["Common Ground"]
    end
    
    %% Pull-up Resistors (Invisible nodes just for routing logic)
    PU1[10kΩ Pull-up]
    PU2[10kΩ Pull-up]
    PU3[10kΩ Pull-up]

    %% MCU to INA226 Core Connections
    M_3V3 -->|Power for Sensor| I_VS
    M_GND -->|Common Logic Ground| I_GND
    
    %% I2C Bus (with pull-ups to 3.3V)
    M_3V3 -.-> PU1 -.-> I_SDA
    M_3V3 -.-> PU2 -.-> I_SCL
    M_SDA <==>|I2C Data| I_SDA
    M_SCL ==>|I2C Clock| I_SCL

    %% Maximizing Features: The Alert Pin
    M_3V3 -.-> PU3 -.-> I_ALERT
    I_ALERT -->|Active Low Interrupt Signal| M_INT
    
    %% Addressing (Default 0x40)
    I_GND -->|Set Address| I_A0
    I_GND -->|Set Address| I_A1

    %% High-Voltage Sensing Connections (High-Side Configuration)
    P_SRC -->|Voltage to Measure| I_VBUS
    P_SRC -->|Current In| I_IN_PLUS
    
    %% Shunt Resistor (Internal to Module usually)
    I_IN_PLUS -.->|Shunt Resistor| I_IN_MINUS
    
    I_IN_MINUS -->|Current Out| LOAD
    LOAD --> P_GND
    P_GND --- M_GND
    
    classDef highlight fill:#f9f,stroke:#333,stroke-width:2px;
    class I_ALERT,M_INT highlight;
```

### Key Considerations for Maximizing Features:

1. **The Alert Pin connection (Highlighted in Pink):** 
   This is the critical difference between a basic setup and an advanced setup. By connecting the `Alert` pin to a digital input on your MCU that supports interrupts, you can configure the INA226 `Mask/Enable Register (06h)` to trigger this pin when:
   * A conversion cycle is fully finished (saves I2C bandwidth, no polling needed).
   * Current goes above/below a critical limit (hardware protection).
   * Voltage goes over/under limit.
   * Power goes over limit.
   * *Note: The Alert pin is Open-Drain, meaning it requires a pull-up resistor to the MCU's logic voltage (3.3V). Many breakout boards include this automatically.*

2. **A0 and A1 Addressing:**
   By wiring these to GND, VS, SDA, or SCL, you can set up to 16 different I2C addresses. This allows you to have up to 16 INA226 sensors on the exact same two I2C wires, all maximizing the bus. 

3. **High-Side Sensing:**
   Connecting the sensor on the positive wire (between the Power Source and the Load) is generally preferred because it keeps the Load firmly connected to the system Ground. The INA226 is specifically designed to handle common-mode voltages up to 36V on its `IN+`/`IN-` and `VBUS` pins independently of its logic supply (`VS`).
