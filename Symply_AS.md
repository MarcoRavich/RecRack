# Input autosensing for combo XLR/TRS (per-channel)

Goal
- One front-panel combo connector per channel.
- Default is Mic (XLR path to the mic split / transformer).
- Inserting a 1/4" plug forces Inst/Line (high-Z input), and must isolate the mic split.

This file reorganizes the original Autosense notes and adds pin tables + wiring state tables.
It also adds a connector pin mapping for the Neutrik NCJ6FI-S style combo jack, based on the attached wiring guide PDF.

--------------------------------------------------------------------

## 1. Connector terminals and naming

1.1 NCJ6FI-S terminal meaning (XLR/TRS)

Notes
- XLR uses pins 1/2/3.
- TRS uses Tip/Ring/Sleeve (T/R/S).
- Some NCJ6FI-S units also expose a chassis ground terminal "G" (separate from audio ground).

Terminal map (what each lug means)

| Connector side | Terminal | Meaning (audio) |
|---|---:|---|
| XLR | 1 | Shield / ground |
| XLR | 2 | Hot / positive |
| XLR | 3 | Cold / negative |
| 1/4" | T | Tip (positive / left) |
| 1/4" | R | Ring (negative / right) |
| 1/4" | S | Sleeve (ground) |
| Chassis | G | Connector shell / chassis ground (if present) |

Recommended net names for schematics / netlists

| Net name | Connects to | Purpose |
|---|---|---|
| CMB_XLR1 | XLR pin 1 | Audio shield / ground reference |
| CMB_XLR2 | XLR pin 2 | Mic/balanced hot from XLR |
| CMB_XLR3 | XLR pin 3 | Mic/balanced cold from XLR |
| CMB_TRS_T | TRS Tip | Inst/line hot from 1/4" |
| CMB_TRS_R | TRS Ring | Balanced line cold (if used) |
| CMB_TRS_S | TRS Sleeve | Ground for 1/4" |
| CMB_CHASSIS_G | Terminal G | Chassis bond point (if used) |

1.2 Simple combined wiring (baseline reference)

If you want the connector to behave as a generic balanced input (no autosense/isolation), the usual correspondence is:
- XLR 1 <-> TRS Sleeve (S)
- XLR 2 <-> TRS Tip (T)
- XLR 3 <-> TRS Ring (R)

This is useful as a reference when checking polarity and continuity.

--------------------------------------------------------------------

## 2. Autosense behaviour (what must happen)

2.1 State table

| Condition | Mic split (MIC_SPLIT_P/N) | High-Z input (HIZ_IN) | Notes |
|---|---|---|---|
| No 1/4" plug inserted | Connected to XLR pins 2/3 | Disconnected | Purely passive mic path |
| 1/4" plug inserted | Disconnected (isolated) | Connected to 1/4" Tip (and optionally Ring) | No injection into mic split |

2.2 Required switching element

Autosense needs a mechanical changeover that is actuated by 1/4" plug insertion.
Implementation choices (pick one):
A) A combo jack variant that exposes switched / normalled contacts operated by 1/4" insertion.
B) An external DPDT relay or analog switch controlled by a simple plug-detect contact.

The wiring below is expressed as two independent changeovers:
- one for the hot leg
- one for the cold leg (optional for unbalanced Inst, but useful for balanced line inputs)

--------------------------------------------------------------------

## 3. Wiring scheme for mechanical autosense

3.1 Nodes used

| Node | Description |
|---|---|
| MIC_HOT_COM | Internal hot node after the changeover contact |
| MIC_COLD_COM | Internal cold node after the changeover contact |
| MIC_SPLIT_P | Mic split / transformer primary hot |
| MIC_SPLIT_N | Mic split / transformer primary cold |
| HIZ_IN | High impedance input hot (Inst/Line path) |
| TRS_SENSE | Optional: node used only to detect 1/4" insertion (or to carry balanced cold) |

3.2 ASCII wiring sketch (conceptual)

Legend
- COM/NC/NO are the three terminals of a changeover contact.
- NC is closed when no 1/4" plug is inserted.
- NO is closed when a 1/4" plug is inserted.

Hot leg changeover:
  COM  -> MIC_HOT_COM
  NC   -> MIC_SPLIT_P
  NO   -> HIZ_IN

Cold leg changeover:
  COM  -> MIC_COLD_COM
  NC   -> MIC_SPLIT_N
  NO   -> TRS_SENSE   (or to HIZ_IN_COLD if you support balanced line on 1/4")

Signal sources into the COM side:
- In Mic mode, MIC_HOT_COM/MIC_COLD_COM are driven by XLR pins 2/3.
- In Inst/Line mode, MIC_HOT_COM is driven by TRS Tip (via the connector’s 1/4" contact set).

3.3 “Wiring table” version (netlist-friendly)

| Element | From | To | Active when |
|---|---|---|---|
| W_XH1 | CMB_XLR2 | MIC_HOT_COM | always (physical lug) |
| W_XC1 | CMB_XLR3 | MIC_COLD_COM | always (physical lug) |
| SW_HOT_NC | MIC_HOT_COM | MIC_SPLIT_P | 1/4" not inserted |
| SW_COLD_NC | MIC_COLD_COM | MIC_SPLIT_N | 1/4" not inserted |
| SW_HOT_NO | MIC_HOT_COM | HIZ_IN | 1/4" inserted |
| SW_COLD_NO | MIC_COLD_COM | TRS_SENSE | 1/4" inserted |

Grounding reference (minimum)
- CMB_XLR1 and CMB_TRS_S should reference the same audio ground node for signal return, unless you intentionally isolate shield.

Chassis bonding (if present)
- CMB_CHASSIS_G is normally bonded to chassis/earth at the panel, not to audio 0V directly (project-dependent).

--------------------------------------------------------------------

## 4. Optional logic-level mode sensing (if you need a digital flag)

Purpose examples
- inhibit phantom power when 1/4" is inserted
- enable/disable an active line driver or balancing stage
- drive per-channel LEDs

4.1 Minimal circuit (pull-up + contact to ground)

| Net | Parts | Behaviour |
|---|---|---|
| MODE_INST | R_MODE from Vlogic to MODE_INST, plus a switch contact from MODE_INST to GND | When 1/4" is inserted the contact closes and MODE_INST changes state |

Example values
- R_MODE: 100 kOhm (adjust to taste)

Polarity
- If the contact shorts to ground when 1/4" is inserted, MODE_INST reads low when inserted.
- If you need active-high, invert in logic or swap pull-up/pull-down.

--------------------------------------------------------------------

## 5. Checklist (quick verification)

Mechanical / connectivity
- Verify the actual combo jack part number provides the needed switched contacts (or plan an external relay).
- Confirm continuity for XLR pins 1/2/3 and TRS T/R/S by meter before wiring a batch.

Electrical safety
- Ensure no DC path from phantom power circuitry into the 1/4" contacts in Inst/Line mode.
- Ensure the 1/4" path cannot back-drive the mic split transformer in Inst/Line mode (true isolation).

Polarity
- Keep a consistent convention:
  XLR 2 = hot, XLR 3 = cold
  TRS Tip = hot, TRS Ring = cold

--------------------------------------------------------------------

## Sources
- [Autosense.md](https://github.com/MarcoRavich/RecRack/blob/main/Autosense.md)
- [How to Wire the Neutrik NCJ6FI-S Combo Jack Guide (XLR_TRS)](https://www.elcircuits.com/neutrik-ncj6fi-s-combo-jack-xlr-trs-wiring/)
