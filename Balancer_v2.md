# RecRack: Hybrid Active/Passive Interface Design

## 1. Design Goals
RecRack is a multi-channel professional interface designed to accept any input type through a single front XLR-combo connector and deliver:

- a strict, passive, 1:1 Link copy of the input signal, regardless of whether it is balanced or unbalanced;
- always two balanced rear XLR outputs (Direct and Aux), using either fully passive topology (microphone signals) or active balancing (instrument/line signals);
- correct phantom-power handling and galvanic isolation where required.

The architecture guarantees fail-safe microphone operation while enabling high-fidelity active balancing for unbalanced sources.

## 2. Channel Architecture

Front:
- 1 x XLR-Combo input (XLR for microphones, TRS for instrument/line).
- 1 x TRS Link output: always a 1:1 passive mirror of the Combo input.

Rear:

- XLR 1: always balanced output
  – microphone mode: direct, passive, phantom-safe
  – instrument/line mode: active balanced
- XLR 2: always balanced output
  – microphone mode: transformer-isolated
  – instrument/line mode: active balanced (duplicate of XLR 1)

## 3. Link Output: Universal Passive 1:1 Mirror

The Link TRS provides a direct, protected, passive copy of the exact signal on the Combo input:

Case A – Microphone (balanced):
Link TRS outputs balanced through appropriate series protection.

Case B – Balanced line:
Link TRS outputs the same balanced line signal.

Case C – Unbalanced instrument/line:
Link TRS outputs the same unbalanced signal.

The Link is never affected by active circuitry or mode selection.

## 4. Microphone Mode (fully passive with isolation)
### 4.1 Signal Flow

Input:
Front XLR section of the Combo connector.

Link:
Direct passive mirror of the balanced mic signal.

Rear XLR 1 (Direct):
Straight copper pass-through from the input pins, preserving full phantom capability.

Rear XLR 2 (Iso):
Driven from the secondary of a 1:1 isolation transformer whose primary is tapped from the same mic input. Phantom from the Aux mixer remains isolated.

### 4.2 Phantom Power

- Phantom from the main console on XLR 1 reaches the microphone through the direct copper path.
- Phantom on XLR 2 is confined to the transformer secondary.
- The Link output is protected with DC blockers and current-limit elements so attached devices are not exposed to 48 V.

## 5. Instrument/Line Mode (active balancing)

### 5.1 Signal Flow

Input:
Front TRS section of the Combo connector.

Link:
Direct, passive, 1:1 unbalanced mirror of the Combo input.

Balancing stage:
Signal enters a high-impedance input network feeding either:
- dual-op-amp topology (buffer + inverter), or
- dedicated balanced line-driver IC.

The stage generates two matched balanced outputs.

Rear XLR 1 (Main):
Receives active balanced output.

Rear XLR 2 (Aux):
Receives a second active balanced output (electrically identical).

### 5.2 Phantom Power
- Phantom appearing on either XLR output is blocked from reaching the instrument input or internal low-voltage electronics.
- Protection includes series resistors, DC blockers, diode clamps and ESD networks.

## 6. Unified Operating Table

Input type → Link → XLR1 → XLR2

Microphone, balanced
→ Link: balanced passive
→ XLR1: balanced passive direct with full phantom
→ XLR2: balanced transformer-isolated

Balanced line
→ Link: balanced passive copy
→ XLR1: balanced passive or active (depending on system choice; recommended passive microphone topology only when on XLR pins)
→ XLR2: balanced transformer-isolated or active

Unbalanced instrument/line
→ Link: unbalanced passive copy
→ XLR1: balanced active
→ XLR2: balanced active

Note: For simplicity and consistency, the recommended implementation is:
- Microphone input → passive/transformer topology (XLR1 direct, XLR2 iso)
- TRS instrument/line input → active driver feeding both XLR1 and XLR2

## 7. Topology Summary

### 7.1 Passive Microphone Handling
- Direct copper path to XLR1
- Transformer-isolated feed to XLR2
- Link is a tapped mirror of the input

### 7.2 Active Instrument/Line Balancing
- High-impedance input
- Dual-op-amp or line-driver IC
- Identical balanced outputs to XLR1 and XLR2
- Passive Link unaffected

### 7.3 System Protection
- Separation between low-voltage domain and phantom domain
- DC-blocking and current-limiting networks on Link and driver inputs
- Short audio paths and robust grounding strategy
