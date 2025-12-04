# RecRack Circuit Analysis & Optimization
## Complete Reorganized Documentation

---

## OVERVIEW

RecRack is a **hybrid active/passive professional audio interface** with a single front XLR-Combo input that automatically detects the signal type and delivers:

- **Link output**: Always a passive 1:1 mirror of the input (microphone, balanced line, or unbalanced)
- **XLR1 (Main)**: Direct phantom-capable output for microphones; active balanced output for instruments
- **XLR2 (Aux)**: Transformer-isolated output for microphones; active balanced duplicate for instruments

The architecture automatically switches between two fully distinct signal paths based on whether the combo receives an XLR microphone input or a TRS instrument/line input.

---

## SCOPE & DESIGN INTENT

### What RecRack Solves

1. **Single input accepts any source**: Microphone (balanced XLR), balanced line, or unbalanced instrument (TRS)
2. **Always-available passive Link**: Provides a safety backup copy independent of mode
3. **Phantom-safe microphone handling**: Direct copper path preserves 48 V capability without active electronics
4. **High-fidelity instrument balancing**: Active circuitry with high input impedance for instruments
5. **Galvanic isolation option**: Transformer-isolated secondary output for microphones to break hum loops

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONT PANEL                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Combo Input        Link Output                         │ │
│  │ (XLR + TRS)        (TRS - Passive Mirror)              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                         │
                    [Auto-Detect]
                    /          \
                   /            \
                  /              \
        Mic Mode                Instrument Mode
        (XLR used)              (TRS used)
            │                        │
        [PASSIVE]               [ACTIVE]
            │                        │
    ┌───────┼───────┐       ┌───────┼───────┐
    │       │       │       │       │       │
  XLR1   XLR2   LINK      XLR1   XLR2   LINK
  DIRECT  ISO   MIRROR    BAL    BAL   MIRROR
```

---

## SIMPLIFIED BLOCK DIAGRAM EXPLANATION

### Block 1: Link Mirror Network (Always Active)
- **Function**: Provide a constant 1:1 passive copy of whatever signal appears at the combo input
- **Input**: Combo XLR (pins 2/3) OR Combo TRS (tip)
- **Output**: Link TRS (tip/ring)
- **Protection**: 47 Ω series resistors, 100 nF RF filters, DC blocking
- **Key Feature**: Never affected by active circuitry or mode selection; always available

### Block 2: Automatic Mode Detection
- **Function**: Switch between microphone and instrument signal paths
- **Mechanism**: Combo connector internal switch activated by TRS insertion
- **When XLR only inserted**: Microphone mode active (passive path)
- **When TRS inserted**: Instrument mode active (active path)
- **Key Feature**: No external control required; automatic based on connector usage

### Block 3: Microphone Path (Fully Passive)
- **Direct Output (XLR1)**:
  - Straight copper connection from combo to XLR1
  - Preserves full 48 V phantom power capability
  - No active electronics in signal path
- **Isolated Output (XLR2)**:
  - 1:1 isolation transformer from same mic signal
  - Secondary output independent from primary
  - Transformer secondary can disconnect from phantom
  - Useful for breaking ground loops

### Block 4: Instrument/Line Path (Active Balancing)
- **Input Stage**: 1 MΩ high-impedance network
- **Balancing Stage**: Dual op-amp (buffer + inverter) or dedicated line-driver IC
  - Buffer stage: Non-inverting unity-gain buffer for hot leg
  - Inverter stage: Inverting unity-gain amplifier for cold leg
  - Output: Balanced pair with low distortion and high CMRR
- **Output Routing**: Both XLR1 and XLR2 driven identically (duplicate balanced signals)
- **Build-out Resistors**: 47 Ω on each output leg for impedance matching

### Block 5: Grounding & Protection
- **Audio Ground Lift**: 10 Ω resistor from audio ground to chassis
- **RF Shunt**: 100 nF capacitor across lift for HF filtering
- **Phantom Protection**: Clamp diodes to prevent 48 V spikes reaching active circuits
- **ESD Protection**: Bidirectional diodes on all input/output nodes
- **Star-Point Grounding**: Single reference point to minimize hum loops

---

## CONSOLIDATED WIRING CHART

| Connector Location | Pin | Signal | Mic Mode Signal | Inst/Line Mode Signal |
|---|---|---|---|---|
| **Front Combo (XLR)** | 1 | Shield/Ground | Direct mic ground | Direct instrument ground |
| | 2 | Hot (+) | Direct to XLR1 pin 2 | To high-Z input |
| | 3 | Cold (−) | Direct to XLR1 pin 3 | Not used (XLR) |
| **Front Combo (TRS)** | Tip | Unbalanced | Not used | To high-Z input |
| | Sleeve | Ground | Not used | Ground reference |
| **Front Link (TRS)** | Tip | 1:1 Copy | Copy of XLR pin 2 (via 47Ω) | Copy of TRS tip (via 47Ω) |
| | Ring | 1:1 Copy | Copy of XLR pin 3 (via 47Ω) | Tied to Sleeve or NC |
| | Sleeve | Ground | Ground reference | Ground reference |
| **Rear XLR1** | 1 | Shield | Audio ground ref | Audio ground ref |
| | 2 | Output Hot | Direct mic hot (passive) | Active balanced hot |
| | 3 | Output Cold | Direct mic cold (passive) | Active balanced cold |
| **Rear XLR2** | 1 | Shield | Audio ground ref | Audio ground ref |
| | 2 | Output Hot | Transformer secondary hot | Active balanced hot |
| | 3 | Output Cold | Transformer secondary cold | Active balanced cold |

**Key Points**:
- XLR1 direct path is phantom-safe; phantom from console reaches microphone
- XLR2 transformer isolation breaks phantom loops if needed
- Link is never affected by either mode or phantom voltage
- In instrument mode, both rear XLRs receive identical active balanced outputs

---

## OPTIMIZED COMPONENT LIST (BY FUNCTIONAL BLOCK)

### Connectors & I/O
- Front XLR/TRS Combo (1×): Accepts microphone or instrument input
- Front TRS Link (1×): Passive 1:1 mirror output
- Rear XLR1 (1×): Main balanced output
- Rear XLR2 (1×): Aux balanced output
- Twisted-pair copper wiring (3 runs): Mic direct path (shield, hot, cold)

### Link Mirror Network
- 47 Ω series resistors (3×): Protect against phantom spikes on Link nodes
- 100 nF RF filter capacitors (2×): Reduce EMI on Link tip/ring

### Microphone Passive Path
- 1:1 isolation transformer (1×): Wideband audio, galvanic isolation
- 47–220 Ω series resistors (2×): Primary side impedance matching
- 1–10 kΩ load/bleed resistors (2×): Secondary side discharge path
- 100–470 pF shaping capacitors (2×): RF filtering

### Instrument Input Network
- 1 MΩ input impedance resistor (1×): Sets high-Z input
- Optional pad resistors (2×): −10 dB (10 kΩ) and −20 dB (2.2 kΩ) attenuation
- Optional pad selector switch (1×): 3-position for gain control

### Active Balancing Stage
- **Option A (Discrete)**:
  - Dual op-amp IC (1×): Low-noise, unity-gain stable
  - 10 kΩ feedback resistors (4×): 0.1% matching for high CMRR
  
- **Option B (Integrated)**:
  - Balanced line-driver IC (1×): Single-chip alternative
  - Fewer external components, built-in protection

### Output Routing
- 47 Ω build-out resistors (4×): Output impedance matching (XLR1 & XLR2)

### Power Supply
- Positive/Negative voltage regulators (2×): ±12 V or ±15 V
- 47 µF pre-regulator bulk capacitor (1×): Energy storage
- 100 nF pre-regulator HF capacitor (1×): High-frequency filtering
- 100 nF local decoupling (per rail, per IC): At each active device
- 10 µF bulk decoupling (per rail, per IC): Low-frequency filtering

### Protection
- Phantom clamp diodes (4×): ±15 V rails, prevent 48 V transients
- ESD diodes (4–8×): Bidirectional TVS arrays on inputs and outputs
- Optional clamp diodes on grounding lift

### Grounding
- 10 Ω audio-to-chassis lift resistor (1×): Hum loop break
- 100 nF RF shunt capacitor (1×): HF filtering across lift

### Mode Selection (Optional)
- Switch or relay (1×): Select between mic/instrument
- Pull-up resistors (2×): Optional logic level sensing
- Indicator LED (1×): Visual mode indication (optional)

---

## SIMPLIFIED NETLIST (FUNCTIONAL VIEW)

### Core Signal Paths

**Microphone Mode Signal Flow**:
```
Combo XLR pin 2/3 → [Direct copper] → XLR1 pin 2/3 (phantom-safe, direct)
                 ↓
                [1:1 Transformer] → XLR2 pin 2/3 (isolated, secondary only)
                 ↓
            [Link Mirror Network] → Link TRS (passive copy)
```

**Instrument/Line Mode Signal Flow**:
```
Combo TRS tip → [1 MΩ input impedance] → [Active balancing op-amp/IC]
            ↓                                       ↓
        [Link Mirror Network]          [Build-out resistors (47Ω)]
            ↓                          /                          \
        Link TRS              XLR1 pin 2/3                   XLR2 pin 2/3
        (passive copy)        (balanced active)             (balanced active)
```

### Key Node Connections

| Node Name | Purpose | Typical Value | Mode |
|---|---|---|---|
| CMB_XLR1, CMB_XLR2, CMB_XLR3 | Front combo input pins | XLR connector | Both |
| CMB_TRS_T, CMB_TRS_S | Front combo TRS pins | TRS connector | Both (but only active in instrument mode) |
| LINK_T, LINK_R, LINK_S | Link output pins | TRS connector | Both (always active) |
| GND_AUDIO | Audio ground reference star-point | Local ground | Both |
| GND_CHASSIS | Chassis shield ground | Chassis tie | Both (single point connection) |
| VPLUS, VMINUS | Power supply rails | ±12 V or ±15 V | Instrument mode only |
| BAL_P, BAL_N | Balanced driver outputs | Signal nodes | Instrument mode only |
| XFM_IN_P, XFM_IN_N | Transformer primary | Signal nodes | Mic mode only |
| XFM_OUT_P, XFM_OUT_N | Transformer secondary | Signal nodes | Mic mode only |

---

## DESIGN PRINCIPLES & BEST PRACTICES

### 1. Passive Link Always Active
- The Link mirror network operates continuously, independent of mode selection
- Small series resistors (47 Ω) provide current limiting without significant impedance impact
- 100 nF capacitors to ground offer RF filtering and phantom transient suppression
- Result: Users always have a 1:1 copy available as a backup or for alternate mixing

### 2. Phantom Power Handling
- **Mic mode (Direct path)**: 48 V phantom passes directly to the microphone through copper
- **Mic mode (Isolated path)**: Transformer secondary completely isolates phantom voltage
- **Instrument mode**: Phantom on output XLRs is blocked from reaching input circuitry via:
  - Series resistors on input network
  - DC-blocking capacitors
  - Clamp diodes to limit transient overshoot

### 3. Mode Detection is Automatic
- Combo connector includes internal changeover switches
- When TRS is inserted, internal contacts switch the signal routing
- No external relay, microcontroller, or manual switching required
- Mechanical integrity ensures fail-safe behavior

### 4. Active Balancing for Unbalanced Sources
- Dual op-amp or line-driver IC generates true balanced output from single-ended input
- High input impedance (1 MΩ) prevents loading of instrument pickups
- Unity-gain buffer ensures no signal loss or impedance mismatch
- Inverter stage creates 180° phase-inverted cold leg
- Result: High-quality balanced signals suitable for long-distance XLR runs

### 5. Single Star-Point Grounding
- All audio ground nodes converge at a single reference point (GND_AUDIO)
- Ground lift resistor (10 Ω) connects to chassis at one location only
- RF shunt (100 nF) across lift for HF filtering
- Prevents multiple ground paths that cause hum loops

### 6. Protection Layers
- Phantom clamp diodes: Prevent op-amp rail destruction from 48 V spikes
- ESD diodes: Protect against static discharge on input/output connectors
- DC-blocking capacitors: Prevent DC offsets from reaching active stages
- Build-out resistors: Protect outputs from short-circuit conditions

---

## SIGNAL INTEGRITY CONSIDERATIONS

### Microphone Path Advantages
- **Transparency**: Direct copper = zero added noise, zero added distortion
- **Phantom capability**: Full 48 V available to powered microphones
- **Simplicity**: No active components = no power supply needed for mic path
- **Reliability**: Fewer components = fewer failure points

### Instrument Path Advantages
- **High impedance**: 1 MΩ input prevents loading of guitar/bass pickups
- **Active balancing**: Creates true balanced signals from unbalanced sources
- **Adjustable gain**: Optional pad network for hot instruments
- **Low impedance output**: 47 Ω build-out supports long cable runs without signal loss

### Link Mirror Advantages
- **Always available**: Works in any mode, any signal type
- **Safety backup**: If main outputs fail, Link provides alternate output
- **Monitoring**: Can feed headphone amp or aux mixer independently
- **Passive**: No power required, no active electronics to fail

---

## COMPONENT COUNT SUMMARY

**Per Channel, Typical Build**:
- **Total Unique Component Types**: 20–25
- **Total Component Count**: 60–80 individual components

**Breakdown**:
- Connectors: 4
- Resistors: ~20–25
- Capacitors: ~15–20
- Diodes: ~8–12
- ICs: 1–2 (op-amp or line-driver + optional regulators)
- Transformer: 1
- Miscellaneous (pads, switches, wiring): ~5–10

---

## IMPLEMENTATION RECOMMENDATIONS

### PCB Layout Priorities
1. **Separate analog and digital grounds** if microcontroller is present
2. **Star-point grounding** at a single location for audio ground
3. **Short PCB traces** from op-amp to XLR output connectors
4. **Twisted-pair routing** for balanced signals and mic input
5. **Ground plane** for low-impedance return paths

### Component Selection Tips
- **Op-amp**: Choose low-noise, high slew rate, audio-grade (e.g., NE5532, OPA2134)
- **Transformer**: Select 1:1 impedance-matched for mic levels, low distortion, high CMRR
- **Resistors**: Use 1% metal-film for accuracy; 0.1% matching for feedback networks
- **Capacitors**: Use film or bipolar electrolytic for audio coupling; ceramic for HF filtering
- **Protection diodes**: Use fast recovery or ultra-fast TVS arrays rated for 48 V

### Testing Checklist
- Phantom power pass-through on direct mic path (XLR1)
- Phantom isolation on secondary path (XLR2)
- Link output shows 1:1 copy in both modes
- Active balanced output CMRR > 60 dB
- Frequency response flat 20 Hz–20 kHz (both paths)
- THD+N < 0.05% at nominal levels
- Crosstalk between channels > 80 dB

---

## CONCLUSION

RecRack represents a **flexible, fail-safe, high-fidelity audio interface** that elegantly bridges passive microphone handling with active instrument balancing through automatic mode detection. The design prioritizes:

- **Simplicity**: Automatic detection, no user setup required
- **Reliability**: Phantom safety, ESD protection, galvanic isolation option
- **Fidelity**: Transparent passive mic path, active balancing for instruments
- **Flexibility**: Three independent outputs (Link + two rear XLRs) with different characteristics

This architecture is ideal for professional field recording, live sound, and studio applications where a single input must handle multiple signal types while maintaining audio integrity and safety.
