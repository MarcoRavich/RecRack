Below is a concrete board-level partitioning for RecRack (8ch DI + splitter + recorder) and a textual “modified MLS800” enclosure drawing you can translate into CAD.

1. Board-level partitioning (overview)

Proposed boards inside a 19" 1U enclosure:

* Board A: Analog Front-End + TRS Link (8 channels, front)
* Board B: Line-Driver + Rear XLR Board (8 ch × 2 outs = 16 XLR, rear)
* Board C: Digital Core + ADC + SD (center)
* Board D: Power Supply (rear, near IEC)

Enclosure: reuse the MLS800 1U rack enclosure shell (side, top, bottom, rack ears, brackets) and replace front and rear panels only.([blemasle.github.io][1])

Mechanical reference:

* Height: 1U = 44.45 mm
* Width (ears): 19" = 482.6 mm([C&T Solution Inc. | 智愛科技股份有限公司][2])
* Depth: choose around 220–250 mm (similar to typical audio 1U units; you can adjust in CAD).

2. Board A – Analog Front-End + TRS Link

Function:

* Hosts 8 combo XLR/TRS input connectors on the front panel edge.
* Hosts 8 TRS link jacks on the front panel edge.
* Implements per-channel:

  * Input protection, pad, mic/line/Hi-Z selection
  * Phantom power switching and filtering
  * Low-noise preamp
  * HPF
  * Split of preamp output towards:

    * ADC (Board C, differential)
    * Line-driver board (Board B, single-ended or balanced)
    * TRS link driver (local)

Approximate PCB and placement:

* Width: about 380–430 mm (to cover most of the front behind the panel).
* Depth: 40–60 mm.
* Mounted directly behind front panel using MLS800-style brackets and self-clinching fasteners.([GitHub][3])

Main connectors on Board A:

1. J_A_PWR (power input from Board D, 10-pin, 2×5, 2.54 mm)

* 1: +15V_A
* 2: +15V_A
* 3: −15V_A
* 4: −15V_A
* 5: +48V_PH
* 6: AGND
* 7: AGND
* 8: +5V_DIG_A (for relays, LEDs)
* 9: DGND
* 10: Shield / Chassis (optional, via RC/NTC)

2. J_A_TO_C (analog to ADC, to Board C, 34-pin, 2×17, 2.54 mm)

Pinout pattern: 8 differential channels, each with a local analog ground reference:

* 1: CH1_AOUT+
* 2: CH1_AOUT−
* 3: AGND
* 4: CH2_AOUT+
* 5: CH2_AOUT−
* 6: AGND
* 7: CH3_AOUT+
* 8: CH3_AOUT−
* 9: AGND
* 10: CH4_AOUT+
* 11: CH4_AOUT−
* 12: AGND
* 13: CH5_AOUT+
* 14: CH5_AOUT−
* 15: AGND
* 16: CH6_AOUT+
* 17: CH6_AOUT−
* 18: AGND
* 19: CH7_AOUT+
* 20: CH7_AOUT−
* 21: AGND
* 22: CH8_AOUT+
* 23: CH8_AOUT−
* 24: AGND
* 25: Reserved (e.g. REF+)
* 26: Reserved (e.g. REF−)
* 27: Shield (to chassis)
* 28: Shield (to chassis)
* 29: NC
* 30: NC
* 31: NC
* 32: NC
* 33: NC
* 34: NC

3. J_A_TO_B (preamp out to line-driver board, 20-pin, 2×10)

Option: send 8 single-ended line-level signals plus ground; the line-driver board will convert to balanced.

* 1: CH1_LIN
* 2: CH2_LIN
* 3: CH3_LIN
* 4: CH4_LIN
* 5: CH5_LIN
* 6: CH6_LIN
* 7: CH7_LIN
* 8: CH8_LIN
* 9: AGND
* 10: AGND
* 11–20: optional (e.g. mute control, sense lines)

4. J_A_CTRL (control bus to Board C, 10-pin, 2×5)

* 1: +3V3_DIG
* 2: DGND
* 3: I2C_SCL_A
* 4: I2C_SDA_A
* 5: GPIO_CTRL0 (pads/relays bank 1)
* 6: GPIO_CTRL1
* 7: GPIO_CTRL2
* 8: GPIO_CTRL3
* 9: ID_A0 (board ID)
* 10: ID_A1

3. Board B – Line-Driver + Rear XLR Board

Function:

* Hosts 16 XLR female connectors on the rear panel:

  * CHx_MAIN (Out A) and CHx_AUX (Out B) for x = 1..8.
* Implements per-channel dual balanced line drivers (e.g. THAT1646 or equivalent) for Main and Aux outputs.
* Receives 8 single-ended line-level signals (CHx_LIN) from Board A and replicates them into A and B outputs.

PCB and placement:

* Rear-panel-mounted, spanning the XLR row.
* Width: roughly 380–430 mm.
* Depth: 40–60 mm inward from rear panel.

Main connectors:

1. J_B_FROM_A (audio in from Board A, mates with J_A_TO_B, 20-pin, 2×10)

* 1–8: CH1..CH8_LIN
* 9–10: AGND
* 11–20: control/mute/GPO as needed

2. J_B_PWR (power from Board D, 10-pin, 2×5)

* 1: +15V_A
* 2: +15V_A
* 3: −15V_A
* 4: −15V_A
* 5: AGND
* 6: AGND
* 7: +5V_DIG_B (status LEDs)
* 8: DGND
* 9: Shield
* 10: Shield

Optional per-board ground-lift:

* Implement ground-lift switches per group of 4 or 8 outputs by lifting pin-1 reference to chassis via resistor/RC network.

4. Board C – Digital Core + ADC + SD

Function:

* Hosts 8-channel ADC.
* Hosts STM32H7 MCU (or similar).
* Hosts SDXC card slot (front edge).
* Hosts control and metering interface (to front-panel display/encoders or to a small “front UI board” if you separate it).
* Distributes I²C/SPI/GPIO control to analog boards.
* Optionally hosts USB-C and Ethernet.

Approximate PCB and placement:

* Placed centrally, between Board A and Board B.
* Width: 100–140 mm.
* Depth: 120–160 mm.

Main connectors:

1. J_C_FROM_A (analog diffs from Board A, mates with J_A_TO_C, 34-pin, 2×17)

* Pins match the J_A_TO_C mapping.

2. J_C_PWR (power from Board D, 10-pin, 2×5)

* 1: +5V_DIG
* 2: +5V_DIG
* 3: +3V3_DIG (optional local)
* 4: DGND
* 5: DGND
* 6: +3V3_A (for ADC analog if not locally generated)
* 7: AGND
* 8: AGND
* 9: Shield
* 10: Shield

3. J_C_CTRL_A (control to analog FE, mates with J_A_CTRL, 10-pin)

* 1: +3V3_DIG
* 2: DGND
* 3: I2C_SCL_A
* 4: I2C_SDA_A
* 5–10: GPIO / ID lines

4. Optional J_C_CTRL_PANEL (small 10- or 14-pin header to a front “UI daughterboard” mounted onto the panel; similar concept to MLS800’s “Inputboard” mechanical arrangement).([GitHub][3])

5. SD slot: on the front edge of Board C, aligned to a cutout in the front panel; mechanical scheme similar to the MLS800 inputboard connector region, but with your SD opening instead of 7-seg display.([GitHub][3])

6. Board D – Power Supply

Function:

* AC mains input (IEC inlet on rear panel) with fuse and EMI filter.
* Generates:

  * +15 V and −15 V for analog.
  * +48 V phantom.
  * +5 V digital.
  * 3.3 V digital either locally or on Board C.

Placement:

* Rear, near IEC inlet, in a shielded section.

Main connectors:

1. J_D_TO_A (power to Board A) – mates J_A_PWR, 10-pin.

2. J_D_TO_B (power to Board B) – mates J_B_PWR, 10-pin.

3. J_D_TO_C (power to Board C) – mates J_C_PWR, 10-pin.

Internal safety:

* Separate chassis ground from signal grounds; connect at a single star point near PSU with RC/NTC network.

6. Modified MLS800 enclosure – textual drawing

Base structure:

* Reuse MLS800 enclosure shell: rackunit assembly (MLS800.SLDASM) defines the general 1U steel frame and mounting brackets.([GitHub][3])
* Replace front and rear panels with new DXF layouts but keep:

  * Overall width 482.6 mm, 1U height, EIA hole spacing.
  * Side rails, bottom and top plates, and front-panel bezel mechanical interfaces.([GitHub][3])

Front panel layout (proposed)

Assume:

* 1U height (44.45 mm).
* Left/right panel margins: 10 mm.
* Grouping into 8 channel strips plus a control area on the right.

Horizontal layout (X from left edge):

* Channels 1–4: centered around X = 40, 90, 140, 190 mm
* Channels 5–8: centered around X = 240, 290, 340, 390 mm
* Control area: X ≈ 430–470 mm

Vertical layout (Y from bottom edge):

* Row 1 (combo XLR/TRS): center at Y ≈ 20 mm
* Row 2 (TRS link jack): center at Y ≈ 35 mm (above each combo)
* LEDs and small buttons: between combo and TRS or offset to the side as needed.

Openings:

* 8 circular “D” cutouts sized for Neutrik combo connectors along Row 1.
* 8 TRS jack holes along Row 2 (or combined “D” cutouts if you use combo assemblies).
* SD slot rectangular cutout near the control area, aligned with Board C SD connector.
* Cutouts for a small display (e.g. 1.3" OLED) and an encoder with push button, plus Record/Stop buttons and status LEDs.

Mounting:

* Use the existing “Inputboard” mounting strategy from MLS800: board standoffs and self-clinching fasteners that fix the board to the panel, keeping the exterior flush.([GitHub][3])

Rear panel layout (proposed)

Horizontal:

* 16 XLR outputs arranged as 2 rows of 8 connectors:

  * Row A (Main outs): CH1–CH8 centered roughly at X = 35, 80, 125, 170, 215, 260, 305, 350 mm.
  * Row B (Aux outs): same X coordinates, below.

Vertical:

* Upper row centers at Y ≈ 30 mm.
* Lower row centers at Y ≈ 12 mm.

Other rear cutouts:

* IEC inlet + fuse holder on the far left or far right.
* Optional USB-C cutout near Board C’s edge.
* Optional RJ45 for Ethernet.
* Venting slots near PSU area, similar to existing patterns in many 1U enclosures.

Mounting:

* The XLR board (Board B) is bolted directly to the rear panel, using the XLR connector flanges as main mechanical anchoring, similar to how many loop switchers and patch panels mount their connectors.
* PSU board is either L-shaped with its own bracket or mounted to the bottom plate, with the IEC and power switch wired with short leads.

7. How this ties back to MLS800

* You keep:

  * Basic 1U rack chassis concept, including rack ears, side walls, top/bottom and the general assembly approach.([GitHub][3])
  * Front-panel bezel concept (if you wish) to hold an acrylic window over the display/control area.

* You replace:

  * Front panel geometry: new cutouts for 8 combos, 8 TRS, SD, small display and controls instead of 7-seg and illuminated switches.
  * Rear panel geometry: new cutouts for 16 XLR outs, IEC, optional USB/Ethernet instead of the MLS800 audio loop jacks and MIDI.([GitHub][3])

This gives you a concrete starting point for CAD work: you can import MLS800.SLDASM into SolidWorks or similar, clone the front and rear panels, then redraw only those two parts following the connector positions and board partitioning listed above.

[1]: https://blemasle.github.io/mls800/ "MLS800"
[2]: https://www.candtsolution.com/news_events-detail/server-rack-sizes-1u-2u-3u-4u-explained/?utm_source=chatgpt.com "Rack Size Explained: 1U, 2U, 3U and 4U - candtsolution.com"
[3]: https://github.com/blemasle/mls800-enclosure "GitHub - blemasle/mls800-enclosure: 8 MIDI controlled loops switcher enclosure"
