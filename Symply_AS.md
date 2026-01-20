# Input autosensing for combo XLR/TRS (per-channel) using Neutrik NCJ9 / NCJ10

Goal
- One front-panel combo connector per channel.
- Default is Mic (XLR path to the mic split / transformer).
- Inserting a 1/4" plug forces Inst/Line (high-Z input), and must isolate the mic split.

Scope
- This note targets Neutrik Combo I connectors with normalling contacts:
  - NCJ9FI-* (3 switching contacts on the 1/4" jack)
  - NCJ10FI-* (same as NCJ9, plus an additional switching ground contact on the XLR side)
- If you use a non-switching combo (example: NCJ6FI-*), you will need an external plug-detect and an external audio changeover.

--------------------------------------------------------------------

## 1. Connector terminals and naming

### 1.1 NCJ9FI-* / NCJ10FI-* terminal meaning (XLR/TRS + normals)

Notes
- XLR uses pins 1/2/3.
- 1/4" uses Tip/Ring/Sleeve (T/R/S).
- NCJ9/NCJ10 expose additional normalling terminals for the jack: TN, RN, SN.
  - When no 1/4" plug is inserted: TN is connected to T, RN to R, SN to S.
  - When a 1/4" plug is inserted: those normal circuits open.
- XLR and TRS signal contacts are not internally tied together; any linking is something you do in your wiring.
- NCJ10 adds a switching ground contact on the XLR side (terminals G/GN) which is controlled by XLR insertion (optional for this autosense).

Terminal map (what each lug means)

| Connector side | Terminal | Meaning (audio / function) |
|---|---:|---|
| XLR | 1 | Shield / audio ground reference |
| XLR | 2 | Hot / positive |
| XLR | 3 | Cold / negative |
| 1/4" jack | T | Tip contact (mates to plug Tip when inserted) |
| 1/4" jack | R | Ring contact (mates to plug Ring when inserted) |
| 1/4" jack | S | Sleeve contact (mates to plug Sleeve when inserted) |
| 1/4" jack | TN | Tip normal (connected to T only when no plug is inserted) |
| 1/4" jack | RN | Ring normal (connected to R only when no plug is inserted) |
| 1/4" jack | SN | Sleeve normal (connected to S only when no plug is inserted) |
| XLR ground switch (NCJ10 only) | G | Switched ground contact |
| XLR ground switch (NCJ10 only) | GN | Normal side of the switched ground contact |

Recommended net names for schematics / netlists

| Net name | Connects to | Purpose |
|---|---|---|
| CMB_XLR1 | XLR pin 1 | Audio shield / ground reference |
| CMB_XLR2 | XLR pin 2 | Mic/balanced hot from XLR |
| CMB_XLR3 | XLR pin 3 | Mic/balanced cold from XLR |
| CMB_TRS_T | Jack T | 1/4" Tip (hot) |
| CMB_TRS_R | Jack R | 1/4" Ring (cold, if used) |
| CMB_TRS_S | Jack S | 1/4" Sleeve (return/ground) |
| CMB_TRS_TN | Jack TN | Tip normal (NC to T) |
| CMB_TRS_RN | Jack RN | Ring normal (NC to R) |
| CMB_TRS_SN | Jack SN | Sleeve normal (NC to S) |
| CMB_XLR_G | G (NCJ10 only) | XLR ground switch (switched side) |
| CMB_XLR_GN | GN (NCJ10 only) | XLR ground switch (normal side) |

### 1.2 Simple combined wiring (baseline reference)

If you want the connector to behave as a generic balanced input (no autosense/isolation), you can wire externally:
- XLR 1 -> TRS Sleeve (S)
- XLR 2 -> TRS Tip (T)
- XLR 3 -> TRS Ring (R)

Doing this removes the possibility of clean autosense/isolation, and is usually not compatible with phantom power + instrument inputs.

--------------------------------------------------------------------

## 2. Autosense behaviour (what must happen)

### 2.1 State table

| Condition | Mic split (MIC_SPLIT_P/N) | High-Z input (HIZ_IN_P/N) | Notes |
|---|---|---|---|
| No 1/4" plug inserted | Connected to XLR pins 2/3 | Disconnected | Purely passive mic path |
| 1/4" plug inserted | Disconnected (isolated) | Connected to 1/4" Tip (and optionally Ring) | No injection into mic split |

### 2.2 Practical implementation choice

NCJ9/NCJ10 provide reliable plug-actuated contacts (TN/RN/SN). You can use them in two ways:

A) True isolation (recommended when you have a dedicated mic split transformer)
- Use TN/RN to create a single selected input pair (XLR when no plug, TRS when plug).
- Use SN as a clean plug-detect contact (MODE_INST).
- Use an external DPDT relay or 2-channel analog switch to route the selected input pair either to MIC_SPLIT or to HIZ.

B) Source selection only (only if your front-end can accept either XLR or TRS directly)
- Use TN/RN as the “mic source” side and T/R as the “plug source” side to feed a common input pair.
- This does not automatically disconnect a dedicated mic split transformer if the transformer is hard-wired to the common input.

The rest of this document assumes A), and provides B) as an optional reference.

--------------------------------------------------------------------

## 3. Wiring scheme for true isolation (external audio changeover + plug detect)

### 3.1 Nodes used

| Node | Description |
|---|---|
| MIC_SPLIT_P | Mic split / transformer primary hot |
| MIC_SPLIT_N | Mic split / transformer primary cold |
| HIZ_IN_P | High impedance input hot (Inst/Line path) |
| HIZ_IN_N | High impedance input cold (balanced line, optional) |
| MODE_INST | Digital flag: 1 when 1/4" plug is inserted |

### 3.2 Plug detect using SN (no audio interference)

Wire this:
- CMB_TRS_S goes to your audio ground (or chassis-dependent scheme).
- MODE_INST has a pull-up to Vlogic.
- MODE_INST is connected to CMB_TRS_SN.

Because SN is connected to S only when no plug is inserted, MODE_INST will be:
- 0 (low) with no plug (SN shorted to S, which is at ground)
- 1 (high) with plug inserted (SN opens, pull-up wins)

Suggested values
- R_MODE: 100 kOhm to Vlogic
- Optional: C_MODE 1 nF to ground close to the MCU input (debounce / EMI)

### 3.3 Source selection inside the connector (TN/RN -> T/R)

Create a common input pair that automatically becomes:
- XLR when no 1/4" plug is inserted
- TRS when a 1/4" plug is inserted

Wire this:
- IN_P: connect to CMB_TRS_T
- IN_N: connect to CMB_TRS_R
- CMB_TRS_TN: connect to CMB_XLR2
- CMB_TRS_RN: connect to CMB_XLR3

Result
- No 1/4" plug: IN_P/IN_N are fed from XLR2/XLR3 via TN/RN.
- Plug inserted: IN_P/IN_N are fed from the 1/4" plug via T/R; TN/RN open and XLR is isolated from the jack path.

Notes
- For TS instrument plugs, the Ring contact is typically tied to Sleeve by the plug, so IN_N will be at ground.

### 3.4 Destination changeover (DPDT relay or 2-channel analog switch)

Use a fail-safe changeover driven by MODE_INST:
- Default (unpowered): IN -> mic split transformer
- Energized (MODE_INST asserted): IN -> Hi-Z input

Hot leg
- COM: IN_P
- NC: MIC_SPLIT_P
- NO: HIZ_IN_P

Cold leg
- COM: IN_N
- NC: MIC_SPLIT_N
- NO: HIZ_IN_N

Notes
- If you only support unbalanced instruments, you can omit the cold-leg switching and tie HIZ_IN_N to ground at the Hi-Z stage.

--------------------------------------------------------------------

## 4. Optional: source selection only (no mic-split isolation)

If you do not need mic-split isolation, you can omit the relay/analog switch and use only section 3.3 (TN/RN -> T/R) to feed a common input pair.

--------------------------------------------------------------------

## 5. Checklist (quick verification)

Mechanical / connectivity
- Confirm the actual part number is a “normalling / switching” variant (NCJ9* or NCJ10*).
- Confirm by meter:
  - No plug: TN-T closed, RN-R closed, SN-S closed.
  - Plug inserted: those pairs open.

Electrical safety
- Ensure phantom power cannot reach the 1/4" path in Inst/Line mode.
- Ensure the 1/4" path cannot back-drive the mic split transformer in Inst/Line mode (true isolation depends on section 3.4).

Polarity
- Keep a consistent convention:
  - XLR 2 = hot, XLR 3 = cold
  - TRS Tip = hot, TRS Ring = cold

--------------------------------------------------------------------

## Sources
- [Autosense.md](https://github.com/MarcoRavich/RecRack/blob/main/Autosense.md)
- [Neutrik Combo FAQ (switching contacts, switching ground)](https://www.neutrik.com/en/neutrik/faq/combo)
- [Neutrik Combo Circuits (terminals: T/TN, R/RN, S/SN, G/GN)](https://www.neutrik.com/media/19415/download/BDA%20607%20V2%20-%20Combo%20I%20Circuits.pdf?v=1)
