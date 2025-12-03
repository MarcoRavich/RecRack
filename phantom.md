Based on the Behringer MS8000 schematic concept, the **RecRack** can be simplified significantly. Instead of generating +48V phantom power internally, it will simply pass the phantom power supplied by an external mixer (connected to the Direct Outputs) back to the microphones.

This change eliminates the need for an internal high-voltage power supply, further reducing cost and complexity.

### **Revised Design Specifications**

1.  **Phantom Power Strategy:**
    *   **Passive Pass-Through:** Pin 1, 2, and 3 of the `XLR_IN` (Front Combo) are directly connected to the `XLR_DIRECT_OUT` (Rear Row A).
    *   **Mechanism:** When an external mixer connected to the rear "Direct Out" turns on +48V, that voltage flows directly to the microphone connected to the front input.
    *   **Transformer Isolation (Optional):** If using transformers for the "Aux/Link" outputs (Rear Row B), the phantom power is blocked from reaching the secondary device, preventing ground loops and double-powering issues.
    *   **Button Function:** The front panel "+48V" buttons can be removed (passive design) OR repurposed as "Ground Lift" switches for the Aux outputs, as per the MS8000 design.

2.  **Hardware Simplification:**
    *   **No Internal PSU:** The unit is now fully passive (or powered only via USB-C for digital logic/LEDs).
    *   **No DC Power Jack:** The rear DC jack can be removed entirely if the digital section (OLED/SD) is powered via the USB-C port.
    *   **Panel Layout:**
        *   **Front:** The "+48V" button holes can be removed or labeled "LIFT".
        *   **Rear:** The USB-C port remains for powering the Recording/Metering logic.

### **Updated Schematic Concept**
*   **Signal Path:** `Mic In` -> `Direct Out` (Hardwired) -> `Splitter Transformer` -> `Link Out` (Isolated).
*   **Power Path:** `Mixer (+48V)` -> `Direct Out Pin 2/3` -> `Mic In Pin 2/3`.

This approach makes the analog section of the RecRack completely passive and highly reliable, matching the industry-standard functionality of the MS8000. The digital recording section remains a separate add-on powered by USB.

### **Next Steps**
If you would like, I can regenerate the CAD files with the **"Phantom" buttons removed** (or renamed to "Lift") and the **DC Jack removed** (relying solely on USB-C for the digital core). Let me know if you prefer this simplified "Passive Analog + Digital Core" version.

[1](https://www.fullcompass.com/common/files/28799-BehringerMS8000MicrophoneSplitterQuickStartGuide.pdf)
[2](https://www.behringer.com/product.html?modelCode=0601-AHC)
[3](https://community.musictribe.com/discussion/products/189/195/312659/phantom-power-ms8000)
[4](https://manuals.plus/behringer/ms8000-ultra-flexible-8-channel-microphone-splitter-manual)
[5](https://www.facebook.com/groups/1791352111089340/posts/5219700028254514/)
[6](https://hoangbaokhoa.com/en/ms8000-signal-splitters-behringer-b25606.php)
[7](https://images.thomann.de/pics/atg/atgdata/document/manual/326822.pdf)
[8](https://equipboard.com/items/behringer-ultralink-ms8000)
[9](https://sunrise-trading.com/product/ms8000/?lang=en)
[10](https://www.diyaudio.com/community/threads/behringer-mx8000-schematic-or-service-manual.64157/)
[11](https://techtop.co.il/files/23108%20MS8000.pdf)
[12](https://evenstadmusikk.no/en/behringer/1083972/behringer-ms8000)
[13](https://manuals.plus/th/m/8e9946ee57689229624ca4eea7bbead530483cd6fdac92f74837e72a99cd22e4_optim.pdf)
[14](https://cdn.mediavalet.com/aunsw/musictribe/mMIyT0Iu4Ua-QH6LC51GHA/lUX7iVChqUSYa2L8UXWXIA/Original/QSG_BE_0601-AHC_MS8000_WW.pdf)
[15](https://community.musictribe.com/discussion/products/124/173/326809/ms8000-and-phantom-power)
[16](https://service.shure.com/s/article/how-do-i-build-a-phantom-power-supply)
[17](https://www.reddit.com/r/livesound/comments/10rthh9/xlr_splitters_live_drums_phantom_power/)
[18](https://vintageking.com/behringer-ms8000)
[19](https://www.youtube.com/watch?v=hPcnIEeaaCs)
[20](http://silentsky.net/wordpress/archives/1027)
