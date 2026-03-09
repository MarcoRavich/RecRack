# RecRack Production Implementation Guide
*Senior Embedded Systems & Pro-Audio Hardware Engineer*

This document provides a comprehensive, production‑ready implementation guide for the **RecRack** – an 8‑channel hybrid unit that combines a passive microphone splitter, an active high‑Z DI box, and a standalone multichannel ISO recorder. All design decisions are derived from the **Technical Foundation** and the four development phases outlined in the project specification.

---

## Phase 1: Hardware Architecture & Board Partitioning

The RecRack is divided into four interconnected PCBs, each optimised for a specific function. Inter‑board connections use high‑density pin headers with keyed shrouds to prevent mis‑mating. All analog audio signals are routed via shielded cables or differential pairs on the backplane.

### 1.1 Board A – Analog Front‑End
**Function:**  
Hosts the eight Neutrik NCJ6FI‑S combo connectors and eight TRS link jacks. Implements the **mechanical autosensing** circuit that switches the signal path based on plug insertion.

**Key Features:**
- Each channel uses the internal switch contacts of the NCJ6FI‑S:
  - **Normally‑Closed (NC)** contacts carry the direct microphone pass‑through (XLR pins 2/3) to the rear Direct Out.
  - **Normally‑Open (NO)** contacts are activated when a TRS plug is inserted, connecting the Tip to the high‑Z buffer input (`HIZ_IN`).
- The passive microphone path is a direct copper trace from the combo XLR contacts to the rear panel (Board B) via a dedicated inter‑board connector – **no active components**.
- TRS Link jacks are wired in parallel with the combo’s TRS contacts to allow daisy‑chaining of instruments.

**Inter‑Board Connectors:**
- **J_A_TO_B:** 20‑pin (0.1″) carrying 8 balanced microphone signals (direct) and 8 unbalanced high‑Z signals.
- **J_A_TO_C:** 16‑pin (0.1″) carrying the 8 high‑Z signals (post‑buffer) to the ADC on Board C.

**Pinout Table – J_A_TO_B (Board A → Board B)**  
| Pin | Signal               | Description                      |
|-----|----------------------|----------------------------------|
| 1   | MIC_CH1+             | Direct Mic Hot (Pin 2)           |
| 2   | MIC_CH1-             | Direct Mic Cold (Pin 3)          |
| 3   | MIC_CH2+             | Direct Mic Hot (Pin 2)           |
| 4   | MIC_CH2-             | Direct Mic Cold (Pin 3)          |
| …   | (continue for CH3‑CH8)|                                  |
| 17  | HIZ_CH1              | Unbuffered High‑Z (from TRS Tip) |
| 18  | HIZ_CH2              | Unbuffered High‑Z                |
| …   | (continue for CH3‑CH8)|                                  |
| 19  | GND                  | Analog ground                    |
| 20  | GND                  | Analog ground                    |

**Pinout Table – J_A_TO_C (Board A → Board C)**  
| Pin | Signal               | Description                      |
|-----|----------------------|----------------------------------|
| 1   | HIZ_BUF_CH1          | Buffered High‑Z output           |
| 2   | HIZ_BUF_CH2          | Buffered High‑Z output           |
| …   | (continue for CH3‑CH8)|                                  |
| 9   | +15V_A               | Analog supply from Board D       |
| 10  | -15V_A               | Analog supply from Board D       |
| 11  | GND                  | Analog ground                    |
| 12‑16| (reserved)          |                                  |

### 1.2 Board B – Line Driver & Rear XLRs
**Function:**  
Provides the rear panel 16 XLR‑M outputs (8 Direct Out, 8 Aux/ISO). The direct microphone outputs are purely passive (hard‑wired from Board A). The Aux outputs are driven by **THAT1646** balanced line drivers for the active (instrument) paths.

**Key Features:**
- Direct Out XLRs (Row A) are connected directly to the corresponding MIC signals from J_A_TO_B via short traces.
- Aux Out XLRs (Row B) receive signals from the active buffers on Board A, after optional isolation transformers (Lundahl LL1538) for the ISO path.
- DC‑blocking capacitors (100 µF electrolytic + 0.1 µF ceramic) are placed at the input of each THAT1646 to protect against phantom power from downstream mixers.
- Output muting relays (e.g., Omron G6K) are controlled by the MCU to eliminate turn‑on thumps.

**Inter‑Board Connectors:**
- **J_B_TO_C:** 10‑pin (0.1″) carrying control signals (mute, gain) and status from Board C.

**Pinout Table – J_B_TO_C (Board B → Board C)**  
| Pin | Signal       | Description                      |
|-----|--------------|----------------------------------|
| 1   | MUTE_CH1     | TTL high = mute Aux output CH1   |
| 2   | MUTE_CH2     | …                                |
| …   | (continue)   |                                  |
| 8   | MUTE_CH8     |                                  |
| 9   | +3V3_D       | Digital supply from Board D      |
| 10  | GND          | Digital ground                   |

### 1.3 Board C – Digital Core
**Function:**  
Contains the STM32H743 MCU, an 8‑channel ADC (Cirrus Logic CS5381), and the SDXC card interface. Also hosts the user interface (OLED, rotary encoder) and communicates with the PGA2500 digitally controlled preamps (if active gain is required).

**Key Features:**
- CS5381 configured for TDM8 output at 48 kHz or 96 kHz, 24‑bit.
- STM32H7 receives TDM data via I2S (SAI peripheral) and writes to an SDXC card using FATFS.
- PGA2500 preamps (one per channel) are placed between the high‑Z buffer and the ADC, controlled via SPI.
- OLED (128×64) driven via I2C, rotary encoder with push‑button for menu navigation.

**Inter‑Board Connectors:**
- **J_C_TO_D:** 6‑pin power connector from Board D.

**Pinout Table – J_C_TO_D (Board C → Board D)**  
| Pin | Signal  | Description                      |
|-----|---------|----------------------------------|
| 1   | +15V_A  | Analog supply                    |
| 2   | -15V_A  | Analog supply                    |
| 3   | GND_A   | Analog ground                    |
| 4   | +5V_D   | Digital supply for USB & logic   |
| 5   | +3V3_D  | Regulated digital supply         |
| 6   | GND_D   | Digital ground                   |

### 1.4 Board D – Power Supply
**Function:**  
Generates all required voltages from an external +24 V DC adapter or from USB‑C (when connected to a host). Includes a low‑noise bipolar supply for the analog rails.

**Key Features:**
- **±15 V:** Using a DC‑DC converter (Traco TMR 3‑2413) followed by low‑dropout linear regulators (LT3045 for +15 V, LT3094 for –15 V) for ultra‑low noise.
- **+5 V:** From the same DC‑DC or USB‑C (via power‑path controller).
- **+3.3 V:** Generated from +5 V using a low‑noise LDO (TPS7A47).
- USB‑C PD negotiates 5 V @ 3 A; a boost converter can supply the +24 V needed for the DC‑DC if only USB power is available (optional feature).
- Monitoring: Voltage and current sense for each rail, accessible via I2C to the MCU.

**Inter‑Board Connectors:**
- **J_D_TO_A:** 12‑pin carrying ±15 V and GND to Board A.
- **J_D_TO_C:** Already described.
- **J_D_TO_B:** (optional) if Board B requires separate analog supply.

---

## Phase 2: Analog Circuit Design

### 2.1 Universal Channel – Autosensing Logic
Each channel is built around the Neutrik NCJ6FI‑S combo jack. The internal switch has two sets of contacts:
- **Switched XLR contacts (pins 2 & 3):** Normally closed when nothing is inserted. These are wired directly to the Direct Out XLR (passive path).
- **TRS switch (Tip):** Normally open, closes when a TRS plug is inserted, connecting the Tip to the `HIZ_IN` node.

**Implementation:**
- XLR pin 1 (shield) is always connected to chassis ground via a 10 Ω / 10 nF network to break ground loops while maintaining RF shielding.
- When a TRS plug is inserted, the NC contacts for XLR pins 2/3 are physically opened by the jack mechanism, **disconnecting the microphone from the Direct Out**. This ensures that a microphone cannot be accidentally split to both the mixer and the DI path.
- The TRS Tip signal is routed through a 1 kΩ series resistor (for ESD protection) to the high‑Z buffer.

### 2.2 High‑Z Buffer & Active Balancing (DI Mode)
The instrument input requires a 1 MΩ impedance and must drive the Aux output (balanced) and the ADC.

**Circuit Stages:**
1. **Unity‑gain buffer** using an OPA1656 (low noise, FET input). Input protection: back‑to‑back diodes (BAV99) to ±15 V rails.
2. **Balanced line driver** based on a dual op‑amp (OPA1612) configured as a differential output stage. The non‑inverting output drives the Aux hot, the inverting output drives the Aux cold. Gain = 0 dB.
3. **Output coupling:** 100 µF bipolar capacitors (or two 220 µF electrolytics back‑to‑back) block DC before the THAT1646. The THAT1646 provides the final balanced output with robust short‑circuit protection.

### 2.3 Isolation Strategy for ISO/Aux Outputs (Mic Mode)
For the microphone path, the ISO/Aux outputs are fed through **Lundahl LL1538** 1:1 transformers. This provides:
- Galvanic isolation to eliminate ground loops between the stage mixer and the recorder.
- Phantom power blocking – the transformer secondary is floating, so any phantom applied at the mixer input cannot reach the microphone.

The primary of the transformer is connected to the passive microphone signal (from Board A) via a switch (analog switch or relay) that selects between the direct mic signal (Mic mode) and the buffered instrument signal (DI mode). The switch is controlled by the autosense signal: when a TRS plug is inserted, the relay connects the DI buffer to the transformer; otherwise, the mic signal is connected.

**Relay selection:** Use a latching relay (Panasonic TQ2SA) to minimise power consumption and avoid audible clicks during switching.

### 2.4 DC‑Blocking at Active Outputs
All active outputs (both the balanced line driver and the transformer secondaries) are AC‑coupled using high‑quality electrolytic capacitors (e.g., Nichicon Muse). For the line driver outputs, the THAT1646 includes internal protection, but external series capacitors (220 µF) are added to guarantee no DC is present on the XLR pins.

---

## Phase 3: Embedded Firmware & Digital Integration

### 3.1 Audio Pipeline
The STM32H743 (Cortex‑M7 at 480 MHz) handles all audio processing and recording tasks.

- **TDM Input:** The CS5381 outputs 8 channels of 24‑bit audio in TDM format (slot 0‑7) at 48/96 kHz. The STM32 SAI peripheral is configured as master, receiving the data via DMA.
- **DMA Double Buffering:** Two ping‑pong buffers (each holding 1 ms of audio) are used to stream data to the SD card without glitches.
- **File System:** FatFS on an SDXC card (SPI or SDIO 4‑bit). Recording is saved as 24‑bit interleaved WAV files (or optionally multichannel Broadcast WAV).

### 3.2 Gain Control (PGA2500)
For channels that require adjustable gain (optional – the base design uses fixed 0 dB for DI, but the architecture allows insertion of PGA2500), the MCU communicates via SPI.
- Each PGA2500 is configured in a daisy‑chain (CS per device) or individually addressed using separate chip selects.
- Gain values are stored in flash and restored on power‑up.
- The UI allows per‑channel gain adjustment from 0 dB to +60 dB in 0.5 dB steps.

### 3.3 Metering & UI
- **Peak Detection:** The firmware calculates the peak level of each channel over a 50 ms window. These values are used to drive a 8‑segment LED bar graph (optional) or the OLED meter display.
- **OLED Menu:** A simple hierarchical menu shows:
  - Main screen: 8 channel meters, recording status, remaining time.
  - Settings: Sample rate (48/96 kHz), gain trim, output mute, etc.
- **Rotary Encoder:** Used to navigate menus and adjust values. A push‑button confirms selections.

### 3.4 “Last State” Memory
The MCU stores the current configuration (gain settings, output mute states, sample rate) in the internal flash (last 2 sectors). On power‑up, the configuration is restored. If no valid configuration is found, factory defaults are loaded.

---

## Phase 4: Mechanical & Enclosure Design

The RecRack is housed in a modified 1U 19″ rack chassis (based on the MLS800 enclosure series). The front and rear panels are custom CNC‑machined aluminium.

### 4.1 Front Panel Layout
- **8 x circular “D” cutouts** for Neutrik NCJ6FI‑S combo jacks, spaced 1.5″ apart (standard 19″ spacing).
- **8 x 6.35 mm holes** for TRS Link jacks, positioned directly below each combo jack.
- **Central area:** 128×64 OLED display (cutout 35×18 mm), SD card slot, and rotary encoder with knob.
- **LED indicators** (optional) for power, record, and clip per channel.

### 4.2 Rear Panel Layout
- **Two rows of 8 XLR‑M** cutouts (Direct Out top row, Aux Out bottom row).
- **IEC inlet** with integrated fuse holder and power switch.
- **USB‑C port** for power (and possibly data) – mounted near the IEC inlet.
- **Ground lift switch** (optional) to disconnect audio ground from chassis.

### 4.3 Internal Assembly
- The four PCBs are mounted on a steel sub‑chassis.
- Board A is directly behind the front panel, with the combo jacks soldered to it.
- Board B is mounted at the rear, with the XLR connectors soldered directly.
- Board C (digital core) is stacked above Board D (power supply) on standoffs.
- Inter‑board cables (flat ribbon) are kept as short as possible, especially for analog audio.
- Thermal management: The power supply board may require a small heatsink for the DC‑DC converter; ventilation slots are provided in the top cover.

---

## Safety & Fail‑Safe Analysis

**1. Passive Microphone Path**
- The direct microphone outputs are completely passive and independent of any power supply. Even if Boards C and D fail or are unpowered, the microphones remain connected to the stage mixer. This is ensured by the hard‑wired traces from the combo jack NC contacts to the Direct Out XLRs.

**2. Phantom Power Transparency**
- Because the microphone path contains no series capacitors or transformers (in Direct Out mode), phantom power from the mixer passes directly back to the microphone. This is essential for condenser microphones.
- In the ISO/Aux path (transformer‑coupled), the transformer blocks phantom power, protecting the recorder inputs.

**3. DC Blocking at Active Outputs**
- All active outputs (Aux) are AC‑coupled with large electrolytic capacitors. In the unlikely event of an op‑amp failure, the capacitors prevent DC from reaching the connected equipment.

**4. Overvoltage Protection**
- The high‑Z inputs are protected with series resistors and clamping diodes to the ±15 V rails.
- The line driver outputs (THAT1646) are inherently short‑circuit protected and can withstand ±26 V phantom power without damage.

**5. Power Supply Sequencing**
- The linear regulators on Board D have proper sequencing to ensure the ±15 V rails come up simultaneously. The MCU monitors the power rails and holds the output mute relays open until all voltages are stable (prevents turn‑on thumps).

---

## Conclusion

This implementation guide provides a complete, production‑ready blueprint for the RecRack. Every design choice aligns with the project’s core philosophy of transparency, reliability, and fail‑safe operation. By partitioning the system into four dedicated boards, we achieve clean signal routing, easy testing, and straightforward assembly. The use of high‑quality components (Lundahl transformers, THAT line drivers, CS5381 ADC) guarantees professional audio performance suitable for both live and studio environments.

All inter‑board connectors and pinouts are clearly defined, enabling parallel development of the individual PCBs. The firmware architecture leverages the power of the STM32H7 to handle high‑sample‑rate multichannel recording while maintaining a responsive user interface.

*This document serves as the master specification for engineering teams and contract manufacturers. Any deviations from this guide must be reviewed against the original design philosophy to preserve the RecRack’s unique hybrid capabilities.*
