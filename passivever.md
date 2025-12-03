Here is how to apply the attached phantom-power strategy to RecRack and simplify both circuitry and interconnections.

1. Conceptual change: RecRack becomes a passive splitter plus a powered recorder

From the attached strategy, RecRack adopts the same idea as the Behringer MS8000: phantom power is never generated internally; it is simply passed from the external mixer (on Rear Direct Out) back to the microphone at the Front Input.

Consequences:

* Analog path is fully passive:

  * Front XLR input is hardwired to Rear XLR “Direct Out” (Row A).
  * Phantom from the FOH mixer flows through Direct Out → input → microphone.
* Aux outputs and TRS links are transformer-isolated:

  * Transformer secondary feeds Rear XLR “Aux” (Row B) and front TRS link.
  * Phantom is blocked on these isolated outputs.
* No internal 48 V supply:

  * No high-voltage DC/DC, no phantom switch circuits, no phantom indication LEDs.
* The digital recorder (ADC + MCU + SD) is powered separately (e.g. via USB-C 5 V), and only taps the audio signal through an isolated, high-impedance transformer or buffer.

2. Updated high-level RecRack architecture (with passive phantom)

Per channel:

Mic In (Front XLR of combo)
|
| (hardwired)
V
Direct Out (Rear XLR A)  ←→ Mixer (provides +48 V phantom if needed)

From the same front XLR pins (2/3), tap into:
→ Transformer (1:1 or suitable ratio, primary in series with the mic line or bridged with series resistors)
→ Transformer secondary feeds:
- Aux Out (Rear XLR B)
- TRS link (Front, phantom-free, isolated)
- Recording tap → small balanced-to-unbalanced buffer → ADC input

Digital recorder core:

* Transformer secondary tap → differential buffer → ADC → MCU → SDXC
* Power: USB-C 5 V → local 3.3 V for MCU/ADC and 1.2 V core as needed

3. Board-level simplification

Compared to the earlier board partitioning, boards now look like this:

* Board A: Passive I/O front (combos + wiring to Direct Out and transformer primaries)
* Board B: Transformer + Aux + recording taps (rear XLR B + front TRS links + feed to ADC)
* Board C: Digital core (ADC + MCU + SD, powered via USB-C)
* No separate high-voltage/analog PSU board is required

3.1 Board A – Passive front I/O

Function:

* Hosts 8 combo connectors on front (XLR/TRS), but XLR pins are the key for phantom pass-through.
* Carries hardwired connections to 8 Direct Out XLRs (rear Row A).
* Routes the mic lines through (or past) the transformer primaries on Board B, depending on exact topology (series or bridged).

Per-channel wiring (simplified):

* XLR_IN pin 1 → DIRECT_OUT_A pin 1 (shield/ground)
* XLR_IN pin 2 → DIRECT_OUT_A pin 2
* XLR_IN pin 3 → DIRECT_OUT_A pin 3

Transformers:

* Option 1 (series primary, MS8000-style):

  * Mic line passes through transformer primary en route to the Direct Out.
  * Primary winding is designed to tolerate phantom and mic line currents.
* Option 2 (bridged primary):

  * Primary is bridged between pins 2 and 3 via series resistors, leaving the direct copper path intact.
  * This keeps the mic path nearly unaffected and the transformer sees a light load.

In both cases, phantom from the FOH mixer appears only on XLR_IN and DIRECT_OUT_A; transformer secondaries and everything downstream remain phantom-free.

Power and control:

* Board A now needs no local analog power rails.
* Optional: small LED indicators, but these can be powered from Board C via a low-current header.

Connectors to other boards:

* J_A_TO_B: low-voltage, differential audio lines for transformer primary connections (if primaries are on Board B instead of Board A) or simple shield references.
* J_A_FRONT_CTRL (optional): minimal control or LEDs from Board C if you still want some status.

3.2 Board B – Transformer, Aux, TRS link, and recording taps

Function:

* Hosts 8 transformer modules.
* Hosts 8 Aux XLRs (rear Row B) and 8 TRS output jacks (front).
* Presents transformer secondaries as:

  * Balanced feed to Aux XLR (phantom-blocked).
  * Balanced or unbalanced feed to TRS link (e.g. tip = hot, sleeve = cold/ground).
  * Balanced feed to ADC input (on Board C) via a simple buffer.

Per-channel block:

* From primary side (mic line between XLR_IN and DIRECT_OUT_A) → transformer primary.
* Transformer secondary:

  * Secondary hot/cold → AUX_OUT XLR B pins 2/3, pin 1 to shield/ground with appropriate grounding/lift scheme.
  * Secondary hot/cold → TRS link tip/ring (or tip/sleeve, depending on scheme).
  * Secondary hot/cold → small differential buffer/attenuator → ADC_IN differential pair.

Switches:

* The former “+48 V” front-panel buttons can be dropped, or, per your phantom strategy, repurposed as ground-lift switches on the Aux outputs:

  * They switch Aux pin-1 between chassis, audio ground, or lifted via RC network.

Power:

* Board B is essentially passive in the audio path.
* Only tiny DC needed if you want per-channel LEDs for Aux presence or ground-lift state; that can be supplied from Board C.

3.3 Board C – Digital core (ADC + MCU + SD), powered via USB-C

Function:

* Isolated recording engine that “sniffs” all 8 channels via transformer secondary taps.
* Contains:

  * 8-channel ADC (24-bit or 32-bit integer).
  * MCU (e.g. STM32H7).
  * SDXC slot and file system.
  * Optional small display and encoder (or separate front mini-UI board).

Power:

* USB-C 5 V from:

  * Host computer, or
  * USB wall adapter.
* On-board regulators:

  * 5 V → 3.3 V for MCU, ADC digital and logic.
  * 3.3 V → 1.2 V (if required for MCU core).
  * 5 V or 3.3 V small rail for LEDs on boards A/B.

Interconnection with Board B:

* J_C_FROM_B, 20–30-pin header:

  * 8 differential audio pairs from transformer secondaries (post-buffer or directly, if buffer is on Board C).
  * AGND and shield reference.
* J_C_PANEL/UI:

  * Front-panel SD and control.

Because all analog paths (mic to Direct Out, Aux, TRS) are passive, the recording still works even if Board C is off; the only effect is “no recording, no LEDs.”

4. Connector and power simplifications

Compared to the previous design:

* Removed:

  * Internal mains PSU, AC inlet, 48 V DC/DC, ±15 V rails.
  * Per-channel phantom control circuits.
  * High-voltage safety concerns inside the unit.
* Added:

  * USB-C connector on the rear (or front) for digital power only.
* Simplified headers:

  * No high-voltage lines between boards.
  * Only low-level audio and low-voltage supply for indicators.

5. Summary of user-facing implications

* Phantom behavior:

  * If the FOH mixer turns on phantom at Direct Out A, the microphones on the front inputs get phantom.
  * Aux outputs and TRS links are transformer-isolated and never supply phantom, preventing accidental double phantom or ground loops on auxiliary lines.
* Reliability:

  * The analog splitter is fully passive and works even if the recorder is off or disconnected.
* Cost/complexity:

  * No internal HV supply, fewer active parts, simpler PCB layouts, easier EMC.
  * Digital recorder is a single, relatively small board, powered and updated via USB-C.
