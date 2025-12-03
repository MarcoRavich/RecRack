Short answer: at the moment your RecRack repository itself does not yet contain schematics/PCBs/firmware to reuse, only the GPL-3.0 license and the README with a curated list of external projects.([GitHub][1])

However, several of the external resources you list are quite reusable for RecRack, especially on the digital/USB/FPGA side and for the web-control part. Below is a synthesis focused on what you can concretely reuse and how it fits your RecRack goals (transparent DI/splitter + 32-bit float USB multichannel + web UI).

Licensing note: RecRack is GPL-3.0. MIT and MPL-2.0 projects listed below are compatible and can be integrated as long as you keep their notices and comply with their terms.([GitHub][2])

1. Very relevant for USB multichannel I/O (digital core)

These are the most interesting if you want RecRack to appear as a USB 2.0 multichannel interface (Zoom-R16-style) and/or use an FPGA as audio hub.

* AudioXtreamer([GitHub][2])
  What it is:
  • USB 2.0 32-in/32-out audio/MIDI interface based on Cypress FX2LP + Spartan-6 FPGA, with complete chain: ASIO driver, USB driver, FX2LP firmware, VHDL, schematics and PCB.
  Why it is reusable:
  • You get a proven FPGA + FX2LP USB2 implementation for high-channel-count isochronous audio.
  • VHDL blocks handling PCM over I²S/serial into/out of the FPGA are directly relevant to RecRack, where you would replace its existing ADC/DAC frontends with your own 8-channel ADC and the DI/splitter front-ends.
  • Schematics and PCB show a realistic layout and power/clocking strategy for a USB2-audio FPGA board.
  • MIT license, fully compatible with GPL-3 when you incorporate or adapt code and schematics.([GitHub][2])
  Practical use in RecRack:
  • Reuse the USB2 audio pipeline (FPGA gateware + FX2LP firmware) and adapt the I/O width to 8 in / maybe 8 out.
  • Add a lightweight control bridge (USB vendor/control EP → FPGA registers) usable from your web UI backend or a small control daemon on the host.

* ADAT USB Audio Interface([GitHub][3])
  What it is:
  • FPGA-based USB 2.0 high-speed audio interface with multiple ADAT I/O; full open hardware (gateware, firmware, hardware rev0).
  Why it is reusable:
  • Shows how to implement a class-compliant USB audio device (2–32 channels) with an FPGA core and tight low-latency constraints.([GitHub][3])
  • Has a clear block diagram and a modern toolchain (Python build scripts + Quartus).
  • Provides hardware examples for clocking, handling multiple serial audio streams (ADAT) and exposing them over USB.
  Practical use in RecRack:
  • If you want RecRack to optionally expose ADAT outputs (or use external ADAT converters), you can reuse substantial parts of the ADAT encoding/decoding logic and the USB core structure.
  • Even if you stay only with I²S/TDM ADCs, the USB/FPGA integration pattern is directly applicable.

* Digital-Audio (FPGA Digital Audio Controller)([GitHub][4])
  What it is:
  • A collection of Verilog/VHDL modules for an Altera/Intel FPGA “digital audio controller”: audio codec interface, I²C configuration, clock generation, FIFOs, serializer/deserializer for audio streams.([GitHub][4])
  Why it is reusable:
  • Gives you reference code for I²S codecs, clock generation and buffering, which are all needed between your ADC and the USB/recording path.
  • Licensed under MPL-2.0, which is compatible with GPL-3 for inclusion in a larger GPL-licensed work if MPL terms are preserved.([Wikipedia][5])
  Practical use in RecRack:
  • You can lift specific modules such as audio_in_deserializer/audio_out_serializer, I²C configuration for codecs and clocking logic as building blocks in your RecRack FPGA design.

* custom-audio-interface([GitHub][6])
  What it is:
  • “Custom multi-port audio interface for recording” with firmware/hardware directories; mostly VHDL for a multi-port interface.
  Why it is reusable:
  • Additional VHDL reference for multi-channel audio handling and buffering.
  • MIT-licensed, so safe to reuse in GPL-3 RecRack.
  Practical use in RecRack:
  • Good as a “second opinion” on how to structure an FPGA audio design (clock domains, FIFOs, mapping of channels).
  • Not as complete as AudioXtreamer/ADAT USB, but helpful for specific modules.

2. Relevant for system architecture, modular hardware and power

These help more on the hardware architecture and power/backplane side.

* insane-audio-foo([GitHub][7])
  What it is:
  • “Portable Modular Digital Audio Mixer / Interface / Recorder” with backplane and power sub-projects (and presumably module boards).([GitHub][7])
  Why it is reusable:
  • Shows how to design a modular backplane for multiple audio cards (good if you ever split RecRack into front-end/ADC/FPGA boards).
  • Provides a concrete example of an audio-oriented power board (multiple rails, low noise) suitable for digital + analog mixed systems.
  Practical use in RecRack:
  • Copy/modify the power-supply topology for ± analog rails, 3.3 V digital, etc., as a starting point for your own PSU board.
  • Use the backplane connector and mechanical ideas if you move to a modular 1U design (separate analog front-end cards and main digital card).

* FUI Audio DAC([GitHub][1])
  What it is:
  • USB-input audio DAC design with PCB and schematics (via SourceForge link).
  Why it is reusable:
  • Provides a good reference for clean USB-to-I²S or USB-to-DAC layout, clocking and analog output filtering.
  Practical use in RecRack:
  • RecRack is mostly about inputs, but you may still want a monitoring/headphone DAC; this project can directly inspire the DAC section and its analog filtering.

3. Relevant for control/UI and web-based management

You mention “remotely controllable via standard web-interface” in RecRack’s README.([GitHub][1])
Here the most useful inspirations are:

* NanoMixer([nanomixer.blogspot.com][8])
  What it is:
  • A digital audio mixer project with ADAT I/O and processing on an FPGA, controlled via a web-based interface running on Linux.([GitHub][1])
  Why it is reusable:
  • Shows an end-to-end architecture where an embedded Linux system exposes a web UI that talks to an FPGA audio core.
  • Gives you patterns for how to map mixer parameters into FPGA registers and expose them via HTTP/REST/WebSocket.
  Practical use in RecRack:
  • Use the same concept: small Linux SOM or SBC handling web UI + control, communicating with the FPGA or MCU via SPI/I²C/UART to set gains, phantom power, routing, etc.
  • You do not have to reuse their code directly, but the high-level architecture is a good template.

* FPGA DAW / fpga-daw / Real-Time Audio Processing on Basys-3 / Digital audio workstation / fpga-music-processing([GitHub][1])
  What they are:
  • Various academic/experimental FPGA audio workstations and real-time processing projects.
  Why they are reusable:
  • Provide reusable building blocks for metering, mixing, filters, and general audio signal routing inside the FPGA.
  Practical use in RecRack:
  • You can reuse/simplify their existing HDL to implement internal routing (e.g., to create software switchable splits, metering taps, simple EQ/HPF), even if your main focus is “interposition-transparent”.

4. Resources that are mostly conceptual inspiration

Some resources in your list are less directly reusable but still useful conceptually:

* FPGA Music Sequencer and Synthesizer, Real-Time Audio Processing on Basys-3, Digital audio workstation([GitHub][1])
  • Mainly useful as examples for FPGA timing, audio buffering and control structures, but not directly targeted at multi-channel DI/splitter hardware.

* Our Hackaday.io list([GitHub][1])
  • Good as a broader scouting ground for niche ideas (metering, mechanical design, clever analog tricks), but not directly plug-and-play for RecRack.

5. What is still missing and must be designed by you

Even with all these resources, some parts of RecRack are very specific and will need fresh design work:

* 8-channel transparent DI/splitter analog front-end with:
  • XLR-combo inputs, TRS “link” outs, dual XLR outs per channel, per-channel ground lift and phantom, and the required protection networks.([GitHub][1])
* Mechanical design of a dense 1U 19" panel with 8 combos + 8 TRS links on the front and 16 XLR on the rear.([GitHub][1])
* The exact integration between the analog boards, ADC(s), the chosen FPGA/MCU architecture, and your USB/SD/web-UI strategy.

Summary

* Your RecRack repository itself currently holds specification and a curated list of external projects, but no internal hardware/firmware yet to reuse.([GitHub][1])
* The most reusable external resources for RecRack are:
  • AudioXtreamer and ADAT USB Audio Interface for USB2 + FPGA multichannel audio and reference schematics.([GitHub][2])
  • Digital-Audio and custom-audio-interface for I²S/codec control, clocking and buffering modules.([GitHub][4])
  • insane-audio-foo for power and modular backplane hardware patterns.([GitHub][7])
  • NanoMixer and related FPGA DAW projects for the control/web UI and internal routing/metering patterns.([GitHub][1])

If you tell me which architecture you want to commit to (FPGA+FX2LP, FPGA+USB-PHY, or MCU-only with USB HS), I can map one of these projects into a concrete “RecRack core” subset (which HDL files / schematics to start from and how to interface your 8-channel ADC and controls).

[1]: https://github.com/MarcoRavich/RecRack "GitHub - MarcoRavich/RecRack: Standalone \"interposition-transparent\" multichannel DI/splitter/recorder unit"
[2]: https://github.com/eltortugo/audioxtreamer "GitHub - eltortugo/audioxtreamer: ASIO driver, Usb Driver, FX2LP Firmware, VHDL Fpga, Schematics & PCB Layout for the AudioXtreamer, a USB 2.0 32ch Audio/Midi interface for retrofitting into digital mixers/interfaces."
[3]: https://github.com/hansfbaier/adat-usb2-audio-interface "GitHub - hansfbaier/adat-usb2-audio-interface: FPGA based USB 2.0 high speed audio interface featuring multiple optical ADAT inputs and outputs"
[4]: https://github.com/n-wagner/Digital-Audio "GitHub - n-wagner/Digital-Audio: FPGA Digital Audio Controller"
[5]: https://en.wikipedia.org/wiki/Mozilla_Public_License?utm_source=chatgpt.com "Mozilla Public License"
[6]: https://github.com/Beirdo/custom-audio-interface "GitHub - Beirdo/custom-audio-interface: Custom multi-port audio interface for recording"
[7]: https://github.com/HubertD/insane-audio-foo "GitHub - HubertD/insane-audio-foo: Portable Modular Digital Audio Mixer / Interface / Recorder with High Quality and stuff."
[8]: https://nanomixer.blogspot.com/ "NanoMixer Digital Mixer Project"
