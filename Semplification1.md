# RecRack Implementation Guide Revision: External Power Supply Architecture

This significantly reduces internal complexity, cost, and improves flexibility.

---

## Revised Power Architecture Overview

The ETEK MULTI-DI unit demonstrates a elegant approach:
- **Primary Power:** External 12-30V DC adapter (5VA stabilized)
- **Secondary Power:** 48V Phantom power from mixer via XLR cables
- **Internal Regulation:** Simple, efficient conversion to required rail voltages

This eliminates the need for an internal AC-DC converter, IEC inlet, and associated safety certifications, while maintaining full functionality.

---

## Phase 1: Hardware Architecture - Revised Board Partitioning

The four-board architecture remains, but **Board D (Power Supply)** is replaced with a simplified **Power Input & Regulation Board**.

### 1.5 Revised Board D – Power Input & Regulation
**Function:** 
- Accepts wide-range DC input (12-30V) from external adapter OR 48V phantom power from any channel's XLR input
- Generates all required internal voltages efficiently
- Provides automatic source switching and protection

**Key Features:**
- **Wide-Input Buck-Boost Converter:** Generates +5V rail from 9V-52V input (TI LM5175 or similar)
- **+3.3V LDO:** From +5V rail for digital logic
- **Optional ±15V:** If retaining original op-amp architecture, use isolated DC-DC converters (Traco TMR series) powered from +5V
- **Phantom Power Harvesting:** Diode OR-ing from any of the 8 microphone channels' pin 2/3 (with current limiting)
- **Protection:** Reverse polarity protection, overvoltage clamp (52V), input filtering

**Inter-Board Connectors:**
- **J_D_TO_ALL:** 10-pin providing +5V, +3.3V, ±15V (if used), and GND
- **J_PHANTOM_IN:** 16-pin from Board A (channel XLR pin 2/3 taps) for phantom power harvesting

**Pinout Table – J_D_TO_ALL (Power Board → All Others)**  
| Pin | Signal  | Description                      | Current Capability |
|-----|---------|----------------------------------|-------------------|
| 1   | +5V_A   | Analog supply (clean)            | 500 mA            |
| 2   | +5V_D   | Digital supply                   | 1 A               |
| 3   | +3V3_D  | Regulated digital                | 500 mA            |
| 4   | +15V_A  | (Optional) Analog positive       | 200 mA            |
| 5   | -15V_A  | (Optional) Analog negative       | 200 mA            |
| 6-10 | GND    | Multiple grounds                 | -                 |

**Pinout Table – J_PHANTOM_IN (Board A → Board D)**  
| Pin | Signal       | Description                      |
|-----|--------------|----------------------------------|
| 1   | PHANTOM_CH1+ | From XLR pin 2 (via 6.8kΩ resistor) |
| 2   | PHANTOM_CH1- | From XLR pin 3 (via 6.8kΩ resistor) |
| 3-16| (continue for CH2-CH8) | |

---

## Phase 2: Analog Circuit Design - Phantom Power Harvesting

The ETEK unit cleverly uses phantom power from the mixer as an alternative power source. We'll implement a similar scheme.

### 2.5 Phantom Power Extraction Circuit

**Design Requirements:**
- Phantom power (48V nominal) appears on XLR pins 2 and 3 (positive) relative to pin 1 (ground)
- Each microphone channel can provide up to 10 mA (per IEC 61938 standard)
- Must not interfere with audio signal integrity

**Circuit Implementation (per channel):**
```
XLR Pin 2 ---[6.8kΩ 1%]---|>|---+---- To Phantom Bus +
XLR Pin 3 ---[6.8kΩ 1%]---|>|---+
                              |
XLR Pin 1 --------------------+---- GND
```

- **6.8kΩ resistors:** Standard phantom power feeding resistors, limit current and isolate audio path
- **Diodes (BAV21):** Schottky or fast switching diodes prevent reverse current and OR multiple channels together
- **Phantom Bus:** All channels' diodes connect to a common bus that feeds the power supply input
- **Capacitor:** 100µF/63V on the bus for energy storage

**Channel Quantity Consideration:**
- With 8 channels, maximum available phantom power = 8 × 10 mA = 80 mA at ~48V
- After conversion efficiency (85%), available power ≈ 3.2W continuous
- This is sufficient for the RecRack's digital core and active DI buffers (especially with modern low-power components)

### 2.6 Automatic Power Source Selection

Implement a priority scheme:
1. **External Adapter (if present):** Higher voltage range (12-30V) takes precedence via diode OR-ing with lower forward voltage
2. **Phantom Power:** Automatically supplies when adapter is absent
3. **No power:** Unit continues to function as passive microphone splitter (fail-safe)

**Circuit:**
```
External Adapter (+) ---[Schottky Diode]---+---- To Buck-Boost Converter Input
                                           |
Phantom Bus (+) --------[Schottky Diode]---+
                                           |
                                      [100µF/63V]
                                           |
GND ---------------------------------------+
```

- Use low-forward-voltage Schottky diodes (0.3V drop) to minimize losses
- The buck-boost converter must accept the higher of the two voltages automatically

---

## Phase 3: Revised Power Supply Specifications

### 3.1 Wide-Input Buck-Boost Converter

**Requirements:**
- Input Voltage: 9V - 52V DC (covers 12V adapter to 48V phantom)
- Output: +5V @ 2A continuous (10W)
- Efficiency: >85% across input range
- Low noise for analog sections

**Recommended Controller:**
- **TI LM5175** or **LT8390** - 4-switch buck-boost controllers with spread spectrum for reduced EMI
- **Alternative:** Pre-built module like **CUI P78E-1000** (12-72V in, 5V out) for faster development

**Output Filtering:**
- Primary +5V output split into:
  - **+5V_D:** Direct to digital section (with ferrite bead isolation)
  - **+5V_A:** Through additional LC filter (10µH + 100µF) for analog

### 3.2 Rail Generation Options

**Option A: Modern Low-Voltage Architecture (Recommended)**
- Use +5V_A directly for OPA2156-based buffers
- Generate +3V3_D from +5V_D via LDO (TLV70033 or similar)
- No negative rail needed
- *Simplest, lowest cost, highest efficiency*

**Option B: Traditional ±15V Architecture (if retaining original op-amps)**
- Add isolated DC-DC converters powered from +5V_D
- **Traco TMA 0515D** or **Murata NMA0515SC**: +5V in, ±15V out @ 200 mA
- Add LC filtering and linear post-regulation (optional)

### 3.3 Phantom Power Current Limiting

To comply with IEC 61938 and protect mixer phantom supplies:
- Each channel's 6.8kΩ resistors inherently limit current to ~7 mA per channel at 48V
- Total system draw from phantom must not exceed 50 mA continuous to avoid overloading any single mixer channel
- Implement soft-start on the buck-boost converter to avoid inrush current

---

## Phase 4: Mechanical & Enclosure Updates

### 4.1 Front Panel Changes
- No changes - same layout as original

### 4.2 Rear Panel Changes
- **Remove IEC inlet** and internal power switch
- **Add DC Power Jack:** 2.1mm center-positive locking jack (Neutrik NF2D-B or similar)
- **Keep USB-C port** (now for firmware updates only, not primary power)
- **Optional:** Add "Phantom Active" LED indicator

### 4.3 External Power Supply Specification

**Recommended Adapter:**
- Output: 24V DC, 1A (24W) - provides ample headroom
- Connector: 2.1mm center-positive locking type
- Regulation: Stabilized (switching) type
- Safety: Certified to relevant standards (UL/CE)

**Alternative Voltages:** Unit accepts 12-30V, so any commonly available adapter works

### 4.4 Internal Assembly Updates
- Board D now smaller (approximately 50×100 mm)
- Mounted near rear panel adjacent to DC jack
- Phantom power harvesting wires routed from Board A via shielded ribbon cable

---

## Phase 5: Firmware Integration

### 5.1 Power Monitoring
- Add voltage divider on phantom bus to MCU ADC
- Display power source and voltage on OLED:
  - "EXT: 24V" when using adapter
  - "PHANTOM: 48V (3 ch)" showing how many channels are supplying phantom
  - "BATTERY?" if voltage < 15V (user might be using a battery)

### 5.2 Power Management
- Implement low-power mode when phantom-only and channels are idle
- Reduce OLED brightness
- Disable unused peripherals

### 5.3 Phantom Status Indication
- Per-channel LEDs (optional) indicate phantom presence
- Warning if total phantom draw exceeds safe limits

---

## Component Selection - Revised BOM

| Component | Original | Revised (External Power) | Cost Impact |
|-----------|----------|-------------------------|-------------|
| Power Input | IEC + internal supply | DC jack + protection | -$15 |
| AC-DC Converter | Internal module | External adapter (customer supplied) | -$25 |
| ±15V Generation | Linear regulators | Optional isolated modules | -$10 (if omitted) |
| Phantom Harvesting | Not present | 16× 6.8kΩ + 16× diodes | +$3 |
| Buck-Boost Controller | Not present | LM5175 + passives | +$8 |
| **Net BOM Savings** | | | **~$39** |

---

## Safety & Fail-Safe Analysis (Revised)

**1. Passive Microphone Path - UNAFFECTED**
- Still completely passive and independent of power

**2. Phantom Power Transparency - IMPROVED**
- Unit now actively uses phantom power, but the microphone path remains transparent
- Harvesting circuit has 6.8kΩ isolation resistors that do not affect audio quality

**3. Protection Enhancements**
- Input reverse polarity protection on DC jack
- Overvoltage clamp (52V TVS diode) on phantom bus
- Current limiting on all phantom inputs

**4. Fail-Safe Operation**
- If both external adapter and phantom are absent:
  - Passive mic split works perfectly
  - Active DI section is non-functional (no outputs)
  - This matches user expectations - no power, no active features

**5. Compliance with Phantom Power Standards**
- 6.8kΩ resistors per IEC 61938
- Total draw from any single mixer channel <10 mA
- AC coupling maintained on all audio paths

---

## Comparison with ETEK MULTI DI SPLITTER

| Feature | ETEK Unit | RecRack (Revised) |
|---------|-----------|-------------------|
| Channels | 16 | 8 |
| Power Inputs | External 12-30V or Phantom | External 12-30V or Phantom |
| Phantom Harvesting | Yes (global) | Yes (per-channel OR-ed) |
| Internal Rails | Not specified | +5V, +3.3V, optional ±15V |
| Active DI | Yes | Yes (improved buffers) |
| Passive Split | No | Yes - unique feature |
| Recording | No | Yes - SD card ISO recording |
| Display | LEDs only | OLED with metering |

The revised RecRack now matches the ETEK unit's flexible powering scheme while adding the unique passive split and recording capabilities.

---

## Implementation Summary

The outsourced power supply architecture delivers:

1. **Cost Reduction:** ~$40 savings per unit (BOM + assembly)
2. **Simplified Certification:** No internal mains wiring, easier CE/FCC approval
3. **Enhanced Flexibility:** Powers from any 12-30V adapter or mixer phantom
4. **Smaller Footprint:** Reduced internal board space, slimmer chassis possible
5. **Improved Reliability:** Fewer internal components, external adapter can be replaced easily
6. **Maintained Fail-Safe:** Passive microphone path still works without any power

This design retains all the core innovations of the RecRack - the hybrid active/passive topology, mechanical autosensing, and ISO recording - while adopting the proven, flexible power approach of the ETEK MULTI DI SPLITTER.

The next step would be to prototype the phantom harvesting circuit and buck-boost converter to verify stable operation across all input conditions and channel configurations.
