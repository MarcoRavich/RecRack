Good suggestion to look at that project. The Multichannel Audio DSP Field Mixer Recorder (Hackaday) has many aspects that make it relevant — and partially reusable — for your “RecRack” 1U multichannel DI/splitter/recorder design. ([hackaday.io][1])

Here’s what you can draw from it, and what to treat with caution — compared against your requirements.

---

## What from that project is useful for RecRack

* The project implements 8-channel balanced analog I/O, with pre-amps, phantom power, and routing to ADC/DAC. ([hackaday.io][2])
* It uses a microcontroller core (STM32H7) for audio I/O and control, which matches a plausible route for your recorder + routing + control logic. ([hackaday.io][3])
* The design is modular: analog front-end cards (preamp cards), driver/line-out cards, and a main digital board (ADC/DAC, MCU, bus). This modularity fits well with a rack-friendly, maintainable architecture. ([hackaday.io][4])
* It supports SD card recording of multiple channels (“8 channel wav poly recording” was implemented). ([hackaday.io][5])
* The project handles power supply, phantom, preamp switching, balanced I/O routing — all elements you need in your DI/splitter + recorder. ([hackaday.io][6])

Thus, this project could serve as a quite close reference or starting point — especially for the analog front-end module design, I/O card layout, modular backplane, and digital recording pipeline (MCU + codecs + SD).

---

## What does **not** fully satisfy your RecRack requirements / what to adjust

* The Hackaday project appears to treat the unit as a *full mixer + recorder + interface* rather than a *transparent DI/splitter with recording*. That means routing, mixing, DSP, and possibly analog summing — which may impose noise path, latency, or coloration. The “interposition-transparent” behavior (i.e. true pass-through + simultaneous recording/splitting without altering the analog path) requires careful analog design; the existing analog I/O cards may need modification. ([hackaday.io][7])
* The driver notes issues: balanced line-driver clipping, layout challenges, tight spacing, power-rail noise and ground-plane compromises. The author acknowledges “living dangerously” with “naked I/O pins from ADC and DAC” and no filtering between analog and digital sections. ([hackaday.io][7])
* The firmware as described seems oriented to 16-bit or 24-bit audio (“16-bit slots”, “subscription to 24-bit mode” is experimental), not necessarily stable 32-bit floating-point recording. ([hackaday.io][5])
* The project is designed as a “field mixer / recorder” — emphasis on portability and mixing — not a high-density rack-split/recorder with 8 inputs + 16 outputs as DI+splitter. So rear-panel dual XLR outputs per input (Main + Aux) are not in its documented topology; you would need to add that splitting stage.
* The mechanical design is backpack / small box oriented, not rack 1U 19″. The internal layout (PCBs, connectors, backplane) would need rework to meet 1U depth/width constraints. ([hackaday.io][8])

---

## Conclusion: This project is a strong **reference** and **partial building block**, but not a complete match

You can reuse substantial parts: analog preamp + balanced I/O card designs; modular backplane and card-based architecture; MCU + codec + SD recording firmware foundations; SD-based 8-channel recording approach.

You should treat this as a **reference design**, not a turnkey solution: for RecRack’s goals (transparent DI + splitter + 32-bit float recording + 1U rack form factor + 2 XLR outs per input + TRS link outputs) you must redesign and extend:

* analog splitting architecture (additional balanced outputs and TRS-thru per input),
* mechanical layout (rack-friendly chassis),
* ADC choice / data path for 32-bit floating-point (ensuring dynamic range, headroom, ADC-to-SD pipeline),
* and clean separation of analog pass-through vs digital path to guarantee “transparent”.

---

If you agree, I can produce a **mapping table** between the Hackaday project components and your RecRack design: for each module (preamp card, I/O card, MCU/codec board, SD record logic, power supply) specify *reuseable*, *needs modification*, or *new design required*.

[1]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder?utm_source=chatgpt.com "Multichannel Audio DSP Field Mixer Recorder - Hackaday.io"
[2]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/details?utm_source=chatgpt.com "Multichannel Audio DSP Field Mixer Recorder - Hackaday.io"
[3]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/179746-new-board-powered-up-and-stm32h7-says-hello?utm_source=chatgpt.com "new board powered up and stm32H7 says hello :) - Hackaday.io"
[4]: https://hackaday.io/project/7041/logs?utm_source=chatgpt.com "Multichannel Audio DSP Field Mixer Recorder - Hackaday.io"
[5]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/148404-8-channel-wav-poly-recording?utm_source=chatgpt.com "8 channel wav poly recording | Details | Hackaday.io"
[6]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/215056-my-1st-manufactured-pcb-cards?utm_source=chatgpt.com "my 1st manufactured PCB cards ! | Details | Hackaday.io"
[7]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/43663-new-dsp-mixer-board/discussion-63241?utm_source=chatgpt.com "New DSP mixer Board | Details | Hackaday.io"
[8]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/238436-new-motherboard?utm_source=chatgpt.com "New motherboard | Details | Hackaday.io"


Below is a clear mapping table showing, for each subsystem of the Hackaday “Multichannel Audio DSP Field Mixer Recorder”, how it aligns with the needs of your 1U RecRack DI+splitter+recorder.
All information is derived from the Hackaday project logs, build notes, and module descriptions. Sources are listed at the end.

---

Mapping table: Hackaday Field Mixer vs. RecRack

Subsystem: Analog preamp cards (balanced mic/line inputs, phantom power, input protection)
Hackaday implementation: Yes. Multiple logs show dedicated preamp cards with balanced inputs, gain stages, phantom power and analog conditioning. Cards are modular and socketed.
RecRack relevance: Highly reusable as a starting point. You need 8 high-headroom, transparent channels. The Hackaday cards are close in concept but tuned for “field mixer coloration” and compact layout.
Actions needed: Review topology, remove coloration/voicing EQ, audit noise/hum, increase headroom margin for DI use, redesign mechanical fit for 1U front panel.
Category: Reusable with modifications
Reason: Good building block but requires electrical and mechanical adaptation.

Subsystem: “Analog output cards” / balanced line driver stages
Hackaday implementation: There are documented issues: clipping, filtering weaknesses, “naked DAC pins”, some board reworks.
RecRack relevance: Only partially reusable. RecRack needs two completely clean independent balanced XLR outputs per channel (Main + Aux), and a TRS buffered link-through.
Actions needed: Redesign driver stage with robust balanced line drivers (e.g. THAT1646) and proper filtering. Add pass-through topology for TRS link.
Category: Needs redesign
Reason: Requirements for RecRack are stricter; the Hackaday design has known limitations.

Subsystem: Modular card/backplane architecture
Hackaday implementation: Yes. The project uses a motherboard + plug-in cards for preamps, ADC/DAC, and I/O, with a defined bus for power and signals.
RecRack relevance: Very useful conceptually. Encourages a clean separation of analog and digital domains.
Actions needed: Change connector placement/orientation, mechanical spacing and shielding for 1U rack.
Category: Reusable conceptually
Reason: Architecture is solid but mechanical form factors are incompatible.

Subsystem: ADC/DAC subsystem (codec board)
Hackaday implementation: Uses codec chips with I²S/TDM interfaces connected to STM32H7. Intended for both input and output audio paths.
RecRack relevance: Reusable only if you adopt the same codec family, but your needs are “input-only + 32-bit float recording + transparent split”.
Actions needed: Replace or modify for 8-channel high-dynamic-range ADC only (e.g. AK5578). Remove DAC side unless RecRack includes headphone monitoring.
Category: Partially reusable
Reason: Useful structure but wrong converter type for RecRack.

Subsystem: Digital core (STM32H7 MCU with SAI/TDM audio interface)
Hackaday implementation: Confirmed; the designer reports STM32H7 “says hello”, boots, handles multi-channel PCM and SD recording operations.
RecRack relevance: Strongly reusable. This is a good MCU family for handling 8ch 32-bit float recording + SDXC + UI.
Actions needed: Extend firmware for 32-bit float WAV/BWF, implement stable SDXC exFAT, add control interface for phantom/gain.
Category: Reusable with firmware extension
Reason: MCU platform is well suited; code must be adapted.

Subsystem: SD-card multichannel recording engine
Hackaday implementation: Fully implemented 8-channel WAV polyphonic recording.
RecRack relevance: Directly reusable as a reference; very similar functionality.
Actions needed: Rewrite to support 32-bit float, larger buffer strategies, higher sustained throughput, robust header finalization.
Category: Strongly reusable
Reason: Closely matches RecRack requirements.

Subsystem: DSP/mixer engine
Hackaday implementation: Focus on DSP mixing/routing for field recording, implemented in MCU/firmware.
RecRack relevance: Mostly irrelevant. RecRack must remain “transparent” (no coloration, no DSP in the analog pass-through).
Actions needed: Remove all mixer paths except metering taps.
Category: Not reusable
Reason: Wrong functional objective.

Subsystem: Power supply subsystem (phantom + analog ± rails + digital rails)
Hackaday implementation: Multiple logs show custom PSU cards and backplane distribution.
RecRack relevance: Very useful as a reference. You need ± analog rails, +48 V phantom, +3.3 V digital, +5 V logic.
Actions needed: Adapt to 1U chassis, improve decoupling, add ESD/EMI filtering appropriate for rack environment.
Category: Reusable with modifications
Reason: Good base but requires 1U mechanical and EMC adaptation.

Subsystem: Mechanical enclosure (portable field unit)
Hackaday implementation: Box for portable use, not rackmount.
RecRack relevance: Not reusable.
Actions needed: Create 19” 1U mechanical layout from scratch.
Category: Not reusable
Reason: Completely different physical format.

Subsystem: Control UI (physical controls, mixer UI)
Hackaday implementation: Front panel controls for gain, mix and monitoring.
RecRack relevance: Only partially useful. RecRack needs simpler front-panel controls (Gain, Phantom, HPF) and a web interface.
Actions needed: Redesign controls; implement rear/remote control integration.
Category: Partially reusable
Reason: Some UI concepts are useful but physical layout not appropriate.

Subsystem: Firmware infrastructure (logging, peripheral drivers, SD I/O, control tasks)
Hackaday implementation: Mature firmware with SD write handling, SAI drivers, control loops.
RecRack relevance: Useful blueprint for firmware structure.
Actions needed: Fork only architecture patterns, not DSP logic.
Category: Reusable with adaptation
Reason: Basic embedded patterns are valid.

---

Summary view

Reusable with modifications:
• Preamp cards
• Digital core (STM32H7)
• SD recording pipeline
• Power subsystem
• Control firmware skeleton

Partially reusable (good reference but requires redesign):
• Codec/ADC board
• Output stages
• Physical UI and control layout
• FPGA/DSP mixer elements (if present)

Not reusable:
• Mechanical enclosure
• Mixer/DSP signal flow (contrary to RecRack transparency requirement)

---

Sources

• Hackaday project overview and detailed logs:
[https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder?utm_source=chatgpt.com](https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder?utm_source=chatgpt.com)
• STM32H7 bring-up log:
[https://hackaday.io/project/7041/log/179746-new-board-powered-up-and-stm32h7-says-hello?utm_source=chatgpt.com](https://hackaday.io/project/7041/log/179746-new-board-powered-up-and-stm32h7-says-hello?utm_source=chatgpt.com)
• 8-channel WAV recording log:
[https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/148404-8-channel-wav-poly-recording?utm_source=chatgpt.com](https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/148404-8-channel-wav-poly-recording?utm_source=chatgpt.com)
• New motherboard, modular boards, analog issues:
[https://hackaday.io/project/7041/log/238436-new-motherboard?utm_source=chatgpt.com](https://hackaday.io/project/7041/log/238436-new-motherboard?utm_source=chatgpt.com)
[https://hackaday.io/project/7041/log/43663-new-dsp-mixer-board/discussion-63241?utm_source=chatgpt.com](https://hackaday.io/project/7041/log/43663-new-dsp-mixer-board/discussion-63241?utm_source=chatgpt.com)
[https://hackaday.io/project/7041/log/215056-my-1st-manufactured-pcb-cards?utm_source=chatgpt.com](https://hackaday.io/project/7041/log/215056-my-1st-manufactured-pcb-cards?utm_source=chatgpt.com)

If useful, the next step can be: a block-level “RecRack architecture blueprint” that integrates reusable modules and identifies what must be freshly designed.

RecRack architecture blueprint (block level) and MLS800 enclosure reuse assessment.

1. Top-level RecRack architecture

Textual block diagram:

[Front panel]
8 × combo XLR/TRS inputs
8 × TRS link outputs
Per-channel controls (gain, pad, phantom, HPF, status LEDs)
System controls (screen, encoder, transport, SD slot)

↓ (per channel)

[Analog front-end / DI blocks]
Input protection, pad, mic/line/Hi-Z selection
Phantom 48 V supply and switching
Low-noise preamp (gain up to +60 dB)
Metering tap

↓ split in parallel into:

A) [ADC input] → [ADC/TDM bus] → [Digital core (MCU)] → [SDXC storage]
B) [Balanced line driver Main] → rear XLR Out A
C) [Balanced line driver Aux] → rear XLR Out B
D) [Link buffer] → front TRS link

Shared infrastructure:

* Power supply: 100–240 V AC → low-noise DC rails (analog ±, +48 V, digital).
* Clocking: master audio clock and PLL → ADC and MCU.
* Control bus: I²C/SPI between MCU and analog boards (gain, pad, phantom, monitoring).
* Optional external interfaces: USB (class-compliant audio/control) and/or Ethernet for web UI.

2. RecRack main blocks and reuse from the Hackaday field mixer

2.1 Enclosure and mechanics

Role in RecRack:

* 19" 1U steel enclosure with front panel for 8 combo + 8 TRS, status indicators and SD slot, and rear panel for 16 XLR outputs, IEC mains inlet and optional USB/Ethernet.
* Internal mounting of PCBs: one or two analog boards, one digital board, one PSU board, cabling harnesses.

Reuse:

* MLS800 enclosure:

  * It is explicitly an open-source hardware 1U rack unit with 8 audio loops, with full CAD (SolidWorks) for a 19" rack enclosure.([blemasle.github.io][1])
  * Built using four bent hot-rolled steel sheets assembled with self-clinching fasteners, with acrylic bezel and printed front panel; files for that construction are in mls800-enclosure (MIT license).([GitHub][2])

How to reuse:

* Directly reuse the overall shell geometry (side panels, bottom/top, mounting brackets, rack ears), keeping the 1U height and depth.
* Replace front and rear panel drawings with new patterns for:

  * 8 Neutrik combo XLR/TRS + 8 TRS jacks instead of stacked NSJ8HC loop jacks and 7-seg display.([blemasle.github.io][3])
  * 16 XLR female on rear instead of the MLS800 loop I/O layout.
* Reuse the mechanical approach of:

  * Self-clinching fasteners for smooth exterior and robust assembly.
  * Acrylic bezel for the display / control area (can be adapted to OLED/TFT instead of 4-digit 7-seg).([blemasle.github.io][3])

License:

* The MLS800 enclosure CAD is under MIT license, which is compatible with a GPL-3 overall project: you can modify and redistribute the CAD as long as you preserve the MIT copyright and license notice.([GitHub][2])

2.2 Analog front-end (per channel)

Block:

Input combo → ESD/EMI protection → pad / input selector → preamp → HPF → metering tap → split to ADC and line drivers.

Functions:

* Accept mic/line/Hi-Z on XLR/TRS.
* Provide +48 V phantom on XLR with proper filtering/limiting.
* Offer clean gain range with low noise and high headroom.
* Provide high-impedance tap for metering and for the TRS link.

Reuse:

* Hackaday field mixer preamp concept:

  * The project uses dedicated mic preamp ICs (e.g. PGA2500 digitally controlled mic preamps) and low-noise bipolar supplies (+/-5 V) for 8 channels of balanced audio I/O.([hackaday.io][4])
  * The project has working 48 V phantom power generation.([hackaday.io][5])

Application to RecRack:

* Reuse the general topology: balanced mic preamp + digitally controlled gain (PGA2500 or similar), phantom power rails, bipolar analog rails, and input protection networks.
* Rework for:

  * Rack environment (better EMC, more controlled ground referencing to handle long stage lines).
  * “Interposition-transparent” behavior: ensure the through path to Main/Aux outputs does not depend on the DSP/mixer engine and that any coloration/EQ is disabled.
  * Gain control: decide whether to keep digital gain (SPI/I²C from MCU) or use local analog potentiometers; your earlier goals suggest hardware gain knobs plus optional digital recall.

2.3 Analog splitter and outputs

Block:

Preamplifier output (or line-level buffered tap) →

* Balanced line driver 1 → XLR Out A (Main)
* Balanced line driver 2 → XLR Out B (Aux)
* Unity-gain buffer → TRS Link (unbalanced or pseudo-balanced, depending on design choice).

Requirements:

* Guaranteed pass-through to stage even if digital core is off or crashed (fail-safe analog path).
* Optionally ground-lift switches for each output bank (to reduce ground loops).
* High CMRR, low distortion, ability to drive long lines.

Reuse:

* Hackaday field mixer has 8 preamp cards and multiple balanced line driver cards with eight preamps plus four line driver cards; however, the author notes clipping and layout issues, such as “naked IO pins from ADC and DAC” and insufficient RC filtering between analog drivers and converters.([hackaday.io][6])

Application to RecRack:

* Use its separation of preamp and line-driver cards as a pattern, but redesign the line drivers using robust balanced line-driver ICs (e.g. THAT1646-type) with proper RC filtering.
* Implement a fully analog, always-on path from input to Main/Aux outputs and TRS link, with the ADC tapping off that path; the digital system should never be in the critical signal path from stage to console.

2.4 ADC and clocking subsystem

Block:

8 analog differential outputs from preamps → 8-channel ADC → serial TDM/I²S bus to MCU.

Requirements:

* 8 channels, 24-bit or 32-bit integer converters with high dynamic range to support 32-bit float recording.
* Sample rates: 48 kHz baseline; optionally 96 kHz.
* Shared master clock distribution with low jitter.

Reuse:

* Hackaday project used Cirrus Logic CS5386 (8-channel ADC) and corresponding DACs in early revisions.([hackaday.io][4])
* For RecRack you may prefer more modern parts (e.g. AK5578) but the bus structure (TDM8 into MCU or FPGA) is similar to what Hackaday uses.

Application:

* Implement a dedicated ADC board with:

  * 8 differential inputs from analog front-end.
  * TDM/I²S output to MCU (STM32H7 SAI, for example).
  * Clock in from a master oscillator + PLL, optionally with word-clock I/O for external sync.
* Reuse Hackaday board’s arrangement of ADC+I²S data routing as a reference, but with updated layout and full analog filtering.

2.5 Digital core (MCU) and firmware

Block:

ADC TDM/I²S → MCU (audio interface + DMA) → RAM buffers → SDXC controller → file system → SD card.

Core tasks:

* Capture 8-channel streams from ADC, convert to 32-bit float.
* Manage ring buffers for audio data.
* Write multi-channel WAV/BWF 32-bit float to SDXC (FAT32/exFAT).
* Handle user interface, metering, and control bus (gain, phantom, routing).
* Optionally handle USB audio streaming and Ethernet/web API.

Reuse:

* Hackaday field mixer’s newer “digiboard” uses an STM32H7 with USB-C, Gigabit Ethernet and twin SD cards, plus AES3 and AVB audio; design goals include multichannel field recording and app-controlled mixing.([hackaday.io][7])
* The project also demonstrates working 8-channel WAV “poly recording” to SD.([hackaday.io][8])

Application to RecRack:

* Adopt the STM32H7 (or similar high-performance MCU) as the central digital core.
* Reuse the architecture pattern from Hackaday: SAI/TDM audio in, SD card management routines, multi-threaded (or RTOS-based) firmware.
* Extend or rewrite the application layer to:

  * Support 32-bit float WAV/BWF multichannel files.
  * Provide reliable session handling, markers, and recovery from power loss.
  * Expose a control API (over USB serial, HTTP or OSC) for your web interface.

2.6 Storage subsystem (SDXC)

Block:

MCU SDMMC interface → SDXC card slot on front panel.

Requirements:

* Support SDHC and SDXC, up to at least 256 GB or 512 GB.
* Sustained write bandwidth > 3–4 MB/s (8 ch × 32-bit float @ 96 kHz).
* Robust file system (FAT32 + exFAT) and journaling/flush strategy.

Reuse:

* Hackaday field mixer logs show successful 8-channel WAV recording and SD write logic; while details are not fully documented, the existence of working “poly recording” is a strong hint that their firmware and buffering strategies are a good reference.([hackaday.io][8])

Application:

* Model the buffering scheme (double-buffer or ring-buffer with DMA) on the Hackaday design, but with stricter bounds on worst-case SD write latency and explicit handling of write errors.
* Use modern exFAT support for large SDXC cards.

2.7 Control, UI and network

Block:

* Hardware UI: small display, encoder, transport buttons, per-channel LEDs.
* Web UI: simple mixer/control page served over Ethernet or via USB gadget (if you embed a small Linux module).
* Control bus to analog boards: I²C/SPI for digital preamps, GPIO for relays (phantom, pad, ground-lift).

Reuse:

* Hackaday field mixer is “app controlled” with Bluetooth and later Ethernet/AVB and smartphone apps for visual mixer settings and metering.([hackaday.io][8])
* MLS800 enclosure design shows how to integrate a front panel with displays, switches and LEDs into a 1U rack front (though the exact elements differ).([blemasle.github.io][3])

Application:

* For RecRack, reuse the architectural idea of remote control of gains and phantom power over a network/app, but with a stronger constraint: the web UI must not be in the critical path for audio; it should only drive control registers.
* Mechanically, reuse the idea of a separated “input board” with display and switches mounted to the front panel, connected to the main MCU board via a short harness or mezzanine, similar to the MLS800 daughterboard approach.([blemasle.github.io][3])

2.8 Power and ground

Block:

IEC inlet → EMI filter → SMPS → secondary regulators (analog ± rails, digital rails, phantom 48 V) → distributed to boards via backplane harness.

Requirements:

* Clean ±5…±15 V rails for preamps and line drivers.
* Stable 48 V phantom with adequate isolation and filtering.
* 3.3 V and 1.2 V rails (and possibly 5 V) for MCU and digital logic.
* Rigorous ground and shielding scheme for rack installation (star ground, separation analog/digital, chassis ground handling).

Reuse:

* Hackaday field mixer logs show design and bring-up of ±5 V low-noise supplies and 48 V phantom supply.([hackaday.io][4])

Application:

* Use similar regulator and phantom-generation topologies, but adapt mechanical layout to 1U and ensure predictable thermal behavior in a rack.
* Combine with MLS800 enclosure practices: steel enclosure, self-clinching fasteners and front/rear panels tied to chassis ground for shielding.([blemasle.github.io][3])

3. Summary: how everything fits together

RecRack blueprint, integrating reused pieces:

* Mechanics: start from MLS800 1U rack enclosure CAD; keep external shell, brackets and the basic construction, but redesign front/rear panels for your I/O pattern and control layout.([GitHub][2])
* Analog: take the Hackaday field mixer’s preamp, phantom and bipolar supply concepts as references, but build a new analog front-end tuned for transparent DI/splitter use and dual XLR + TRS-link outputs per channel.([hackaday.io][4])
* Digital: base your main board on STM32H7 (as in the Hackaday digiboard) with an 8-channel ADC on a dedicated TDM bus, SDXC on SDMMC, and control interfaces.([hackaday.io][7])
* Firmware: reuse the pattern of 8-channel WAV recording from Hackaday, but implement 32-bit float WAV/BWF, robust SD handling and a clean control API for web/remote management.([hackaday.io][8])

If you want, next step can be a concrete board-level partitioning (e.g. “Board A: analog 4ch ×2, Board B: ADC+MCU, Board C: PSU”) with connector pinouts and how they fit into a modified MLS800 enclosure drawing.

[1]: https://blemasle.github.io/mls800/ "MLS800"
[2]: https://github.com/blemasle/mls800-enclosure "GitHub - blemasle/mls800-enclosure: 8 MIDI controlled loops switcher enclosure"
[3]: https://blemasle.github.io/mls800/hardware/ "Hardware - MLS800"
[4]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/25165-pga2500-digitally-controlled-pre-amps?utm_source=chatgpt.com "PGA2500 digitally controlled pre amps | Details | Hackaday.io"
[5]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/26211-48v-phantom-power-working?utm_source=chatgpt.com "48v Phantom power Working :) | Details | Hackaday.io"
[6]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/log/43663-new-dsp-mixer-board/discussion-63241?utm_source=chatgpt.com "New DSP mixer Board | Details | Hackaday.io"
[7]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder/details?utm_source=chatgpt.com "Multichannel Audio DSP Field Mixer Recorder - Hackaday.io"
[8]: https://hackaday.io/project/7041-multichannel-audio-dsp-field-mixer-recorder?utm_source=chatgpt.com "Multichannel Audio DSP Field Mixer Recorder - Hackaday.io"
