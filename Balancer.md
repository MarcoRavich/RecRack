The Etek MultiDI is an active DI/splitter with “electronically balanced” I/O, i.e. op-amp line drivers and receivers that can handle both balanced and unbalanced sources. Specs explicitly state “Electronically Input Balanced/Unbalanced” and “Electronically Balanced Output”.([reverb.com][1])

Given the phantom-pass-through strategy you attached (passive mic path, no internal 48 V), here is what I am planning for the “unbalanced → balanced” feature in RecRack.

1. Keep the phantom-carrying XLR path entirely passive

This is unchanged:

* Front XLR and Rear “Direct Out A” are hardwired, so the console can feed phantom to the mic through RecRack without any active electronics in series (MS8000 style).
* No op-amps or active circuitry ever sit in the mic/phantom path.

So: op-amps will not be used in series with that main split.

2. Unbalanced sources are handled on the TRS side by an active balancing stage

For instruments / line-level gear (what MultiDI is so good at), RecRack will use op-amps, but on a separate path that does not carry phantom.

Plan per channel:

* Front TRS portion of the combo (or a separate TRS jack) is the unbalanced input for instruments/line.

* That TRS input feeds a high-impedance buffer and a classic dual-opamp “SE to balanced” stage:

  * Op-amp A: non-inverting buffer, output = +signal
  * Op-amp B: inverting buffer, output = −signal

  This is the standard dual-opamp unbalanced-to-balanced topology: one op-amp in unity gain, the second in unity-gain inverter.([element14 Community][2])

* Those two op-amp outputs then drive:

  * A fully electronically balanced Aux XLR output (or the balanced feed to the rear “B” output), and
  * The balanced input of the ADC for the recorder.

Key points:

* This stage is only used when you plug unbalanced gear into the TRS side.
* It runs from the low-voltage supply (e.g. 5 V from USB-C with local 3.3 V), completely isolated from the phantom path.
* For mic use, the TRS path can be ignored or switched out.

3. Main stage split remains passive; active stage feeds Aux/recorder only

To stay consistent with the phantom concept and keep reliability high:

* Main XLR “Direct Out A” path:

  * Always passive (no active balancing).
  * Used for mics and any source where phantom from FOH may be present.

* Active op-amp balanced outputs:

  * Only on the Aux leg and recorder tap, where no phantom is expected or needed.
  * For unbalanced sources you can choose to feed FOH from the Aux output (electronically balanced, MultiDI-style), instead of the passive mic split.

So functionally:

* Mic source + phantom from FOH?
  Use the passive XLR A path. Recorder/monitor gets its isolated signal via transformer or a high-impedance tap (no op-amps in the phantom path).

* Unbalanced instrument/synth?
  Use TRS in → op-amp SE→balanced stage → balanced Aux XLR to FOH and ADC. No phantom involved; here RecRack behaves like MultiDI: electronically balanced input/output, switchable impedance and pad can be done around that op-amp stage.([reverb.com][1])

4. Why not op-amps everywhere like MultiDI?

MultiDI is a fully active box:

* It has an internal low-voltage PSU and can be powered from phantom or external DC.([reverb.com][1])
* All 16 channels are driven by op-amps that see the mic/instrument directly, and phantom is handled inside the active circuitry.

RecRack, with the attached strategy:

* Intentionally avoids any active element in the phantom path (to keep it “fail-safe” and to avoid designing 48 V-rated active front-ends for all 8 channels).
* Uses op-amps only where phantom will never appear: TRS unbalanced inputs, Aux outputs, and ADC inputs.

This preserves the reliability and simplicity benefits of the passive splitter design, while still giving you an “Etek-like” electronically balanced path for unbalanced sources.

5. Summary

* Yes, op-amps will be used for balancing unbalanced signals, but only on the non-phantom side:

  * TRS unbalanced → dual-opamp SE→balanced → Aux XLR and ADC.
* The main XLR split stays fully passive and phantom-transparent.
* This mirrors the MultiDI’s “electronically balanced” behaviour for instruments and line-level sources, without compromising the passive phantom-through concept you want for RecRack.

[1]: https://reverb.com/item/2252589-etek-multi-di-16-channel?utm_source=chatgpt.com "Etek Multi DI (16 Channel) | Reverb"
[2]: https://community.element14.com/technologies/test-and-measurement/b/blog/posts/opamp-basics-unbalanced-to-balanced-signal-with-dual-opamp?utm_source=chatgpt.com "OpAmp basics: unbalanced to balanced signal with dual OpAmp"
