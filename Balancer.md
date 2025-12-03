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

Below is a redesign of the per-channel circuits so that the same “RecRack” channel can sit:

* between pedalboard (or keys/synths/any unbalanced source) and two mixers, and
* between microphones and two mixers,

with these constraints:

1. Both mixers receive only balanced signals.
2. Both mixers may have phantom power; the unit must handle this safely.

This design combines industry-standard mic split practice (Radial ProMS2, ART SplitCom Pro, Behringer MS8000) with DI practice (passive transformer DI for unbalanced sources).([Radial Engineering][1])

I will describe one “universal channel” that you can replicate 8 times.

1. Universal channel: connectors and roles

Per channel:

* Front:

  * XLR female (mic input)
  * 1/4" TRS/TS jack (unbalanced instrument/line input)
  * 1/4" Thru jack (goes to guitar/bass amp or local combo input)
  * Mode switch: MIC / DI (at least internal; can be front-panel if you want)

* Rear:

  * XLR Out 1 = Main (direct leg)

    * For mic: passes phantom from Mixer 1 to the mic
    * For DI: balanced DI output to Mixer 1, phantom blocked
  * XLR Out 2 = Iso (isolated leg)

    * Always transformer-isolated, phantom from Mixer 2 blocked

This follows the same pattern as Radial ProMS2 / ART SplitCom Pro: one “direct” output with phantom return to the mic and one “isolated” output for the second console.([Radial Engineering][1])

2. Mic mode circuit

Objective: one microphone feeds two mixers; only Mixer 1 provides phantom to the mic. Mixers both see balanced microphone-level signals.

2.1 Signal path

* Mic in (front XLR):

  * Pin 1 → chassis/audio ground
  * Pin 2 → Main Out XLR1 pin 2 (direct copper)
  * Pin 3 → Main Out XLR1 pin 3 (direct copper)

* Iso path:

  * Mic pins 2–3 also feed the primary of a 1:1 mic transformer via a simple series build-out (for example 150–220 ohm per leg) to control loading.
  * Transformer secondary:

    * Secondary hot → Iso Out XLR2 pin 2
    * Secondary cold → Iso Out XLR2 pin 3
    * XLR2 pin 1 → chassis via link/RC network, with optional ground-lift switch.

Functionally this is the same topology as a passive mic splitter with one direct and one isolated output.([Radial Engineering][1])

2.2 Phantom behaviour in mic mode

* Mixer 1 phantom:

  * 48 V is applied via the mixer’s 6.8 k resistors between pins 2, 3 and pin 1 of XLR1.([Sound AU][2])
  * Phantom travels through the direct wiring to mic pins 2, 3 (return via pin 1).
  * The transformer primary sees equal DC volts on both ends (common mode), so no current flows through the winding; it only sees AC. This is standard practice for phantom-compatible mic transformers.

* Mixer 2 phantom:

  * 48 V is applied on Iso Out XLR2 pins 2, 3 relative to pin 1.
  * Because of the transformer, there is no DC path from secondary to primary; phantom from Mixer 2 does not reach the mic nor Mixer 1, it is confined to the transformer secondary and any local bleed network on that side.
  * You can add high-value resistors (e.g. 47 k) from pins 2 and 3 of XLR2 to pin 1 to provide a defined DC load and bleed path for phantom, but they are optional.

Operationally, this matches Radial ProMS2 / ART SplitCom Pro: phantom should be enabled on Main only; Iso is phantom-blocked by the transformer.([Radial Engineering][1])

2.3 Optional TRS and Thru in mic mode

In mic mode you typically ignore the TRS input and Thru. If you really want to offer a “monitor tap”:

* Take a high-value, balanced resistive tap from pins 2/3 (for example a 100 k / 100 k pad plus series capacitor) into a small buffer, then to a TRS jack.
* Capacitor(s) must be rated 63 V or more and sized so that phantom DC is blocked entirely from the TRS jack.
* This is optional; simplest is “TRS and Thru disabled in mic mode”.

3. DI mode for unbalanced sources (pedalboard, bass, keys, synths)

Objective: end-of-chain DI that:

* sits between pedalboard output and amplifier input, and
* sends two balanced, phantom-safe feeds to two mixers.

3.1 Signal path

In DI mode, the front XLR is unused; the TRS jack becomes the main input.

* Unbalanced input:

  * TRS/TS jack tip = signal
  * Sleeve = local audio ground

* Pad and impedance:

  * Use a standard passive DI pad network (for example 20 dB or 40 dB switchable) as per classic DI designs (resistive L-pad or T-pad) to adapt pedalboard/line levels to the transformer input.([Sound AU][3])
  * Input impedance on the jack can be on the order of 200 k–1 M for guitar/bass, or 22–47 k for line-level sources, with a switch to choose (MultiDI style).([reverb.com][4])

* Transformer:

  * The pad feeds the primary of the same mic-rated 1:1 transformer used above (or a dedicated DI transformer with the right level handling).
  * Secondary drives both mixers.

* Thru jack:

  * Pedalboard tip also goes, via a simple series resistor (for isolation, e.g. 100–1 k ohm), to the Thru jack tip.
  * The sleeve is common between input and Thru.
  * This gives the usual “instrument in / amp thru” behaviour.

3.2 Outputs in DI mode

* Main Out XLR1:

  * Transformer secondary hot → pin 2
  * Transformer secondary cold → pin 3
  * Pin 1 → audio/chassis ground (optionally via ground-lift switch)

* Iso Out XLR2:

  * Simplest, cheap version: pins 2/3 of XLR2 parallel pins 2/3 of XLR1; pin 1 tied similarly (this is not isolated, but still phantom-safe for the instrument; it may not solve ground loops between the two mixers).
  * Better version (mic-split quality): secondary feeds XLR1 directly; a second small 1:1 iso transformer takes its input from that balanced line and feeds XLR2. This gives galvanic isolation between the two mixers, analogous to the mic mode.

Either way, because the unbalanced instrument always sees the transformer primary, phantom from either mixer is never passed back to the instrument; this is how passive DI boxes protect guitar/bass/keys from phantom.([Sound AU][3])

3.3 Phantom behaviour in DI mode

With transformer between source and mixers:

* Phantom from Mixer 1:

  * Appears on XLR1 pins 2/3 relative to pin 1, but has no DC path to the primary; it is blocked.
  * You can load it with high-value resistors and transient suppression on the secondary side.

* Phantom from Mixer 2:

  * Same; blocked by transformer or second transformer if you implement isolated XLR2.

Thus:

* Phantom from either mixer never reaches:

  * the TRS input,
  * the Thru jack,
  * the pedalboard or amplifier.

That matches the general rule that DI boxes “prevent phantom power from being transmitted to audio equipment they are connected to”.([Geek Musician][5])

4. Where to use op-amps (optional)

The above can be implemented fully passive with transformers, which matches your “simplify/cheapify” goal and gives the strongest phantom safety.

If you want an electronically balanced DI path for unbalanced sources (MultiDI style)([reverb.com][4]):

* Insert a dual op-amp stage between TRS input and Main XLR1 (in DI mode only):

  * Stage 1: non-inverting buffer (gain 1 or >1) → XLR pin 2.
  * Stage 2: inverting buffer (gain −1) → XLR pin 3.

* Phantom blocking:

  * DC-block XLR pins 2/3 into op-amp outputs with capacitors rated >63 V.
  * Add clamp diodes and resistors so phantom never reaches the op-amp supply rails or TRS input.
  * Use the transformer only for the Iso Out XLR2 (ISO mixer) and to give you galvanic isolation between the two consoles.

This is closer to Etek MultiDI’s “electronically balanced/unbalanced” approach for DI applications, but still keeps phantom away from sources by capacitor and transformer blocking.([Sound AU][6])

For microphones, I still recommend the purely passive mic-split topology with one direct and one transformer-isolated leg; using op-amps in series with the mic + phantom path complicates safety and reliability.

5. Summary

Per channel:

* Mic mode:

  * Use front XLR.
  * Main Out XLR1: direct, phantom-pass to mic.
  * Iso Out XLR2: transformer-isolated, phantom from Mixer 2 blocked.
  * Mixers both see balanced mic-level; only Mixer 1 should have phantom enabled.

* DI mode:

  * Use front TRS input, Thru to amp.
  * Transformer primary on TRS side; secondary drives one or two balanced XLRs.
  * Phantom from either mixer is confined to the XLR side and never reaches the instrument side.
  * Optionally add op-amp SE→balanced stage on Main Out for “electronically balanced” DI behaviour; transformer still protects sources and isolates second mixer.

This way, the same hardware channel, with a mode switch, can sit:

* between pedalboard and amp, feeding two phantom-capable balanced mixers safely, and
* between microphones and two mixers, ensuring one clean phantom path and one isolated split, in line with standard mic splitter practice.

[1]: https://www.radialeng.com/product/proms2?utm_source=chatgpt.com "ProMS2 - Radial Engineering"
[2]: https://sound-au.com/articles/balanced-io.htm?utm_source=chatgpt.com "Balanced I/O - sound-au.com"
[3]: https://sound-au.com/project35.htm?utm_source=chatgpt.com "ESP - Direct Injection Box for Recording and PA Systems"
[4]: https://reverb.com/item/2252589-etek-multi-di-16-channel?utm_source=chatgpt.com "Etek Multi DI (16 Channel) | Reverb"
[5]: https://geekmusician.com/di-box-and-phantom-power-questions/?utm_source=chatgpt.com "DI Box & Phantom Power: All You Need to Know (+ Useful Tips)"
[6]: https://sound-au.com/articles/balanced-4.htm?utm_source=chatgpt.com "Balanced Inputs (Part IV) - sound-au.com"
