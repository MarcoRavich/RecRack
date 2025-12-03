### **Internal Component Layout (Top View)**

The enclosure is partitioned into four main functional zones to minimize noise and optimize cable routing.

![RecRack Layout]()

#### **1. Board A: Analog Front-End (Front-Left)**
*   **Position:** Mounted directly behind the front panel, spanning from the left edge to approx. 400mm.
*   **Function:** Holds the 8x Combo XLR/TRS inputs and 8x TRS Link jacks.
*   **Mounting:** Uses the component shafts/flanges and self-clinching standoffs on the front panel.
*   **Dimensions:** ~390mm (W) x 60mm (D).
*   **Notes:** Keeps sensitive low-level analog signals (Mic Pre) as far as possible from the PSU.

#### **2. Board B: Output & Line Drivers (Rear-Left)**
*   **Position:** Mounted to the rear panel, spanning the 16x XLR outputs.
*   **Function:** Line drivers and balanced output connectors.
*   **Mounting:** Secured via XLR connector screws/rivets to the rear panel.
*   **Dimensions:** ~360mm (W) x 50mm (D).
*   **Notes:** Directly converts internal signals to balanced outputs at the exit point.

#### **3. Board C: Digital Core & Control (Center-Right)**
*   **Position:** Located in the "open" space on the right side (X ≈ 300–435mm), extending from the front control area towards the middle.
*   **Function:** Hosts the ADC, MCU, SD Card slot, and Front UI (OLED/Encoder).
*   **Mounting:** Standoffs on the bottom chassis plate.
*   **Dimensions:** ~120mm (W) x 110mm (D).
*   **Alignment:** The front edge must align with the SD slot and OLED cutout on the right side of the front panel.

#### **4. Board D: Power Supply (Rear-Right)**
*   **Position:** Rear-Right corner, immediately next to the IEC inlet.
*   **Function:** AC/DC conversion (+15V, -15V, +48V, +5V).
*   **Mounting:** Standoffs on bottom plate or L-bracket to side wall.
*   **Dimensions:** ~50mm (W) x 60mm (D).
*   **Safety:** This area should be shielded or spaced (>10mm creepage) from the audio boards (Board B and C).

### **Cabling & Signal Flow**
*   **Analog In:** Short ribbon/wire bundles from **Board A** → **Board C** (ADC Inputs).
*   **Analog Out:** Ribbon cable from **Board A** (Direct Outs) or **Board C** (DAC) → **Board B** (Line Drivers).
*   **Power:** Star distribution from **Board D** to all three boards, keeping dirty digital power (Board C) separate from clean analog power (Boards A/B).
