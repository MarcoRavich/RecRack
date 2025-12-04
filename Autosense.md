# Input connection type autosensing

1. [Concept and priorities](https://github.com/MarcoRavich/RecRack/new/main#1-concept-and-priorities)
2. [Updated block-level idea](https://github.com/MarcoRavich/RecRack/new/main#2-updated-block-level-behaviour)
3. [Concrete way to implement it in the per-channel netlist (mechanical only)](https://github.com/MarcoRavich/RecRack/new/main#3-netlist-level-implementation-mechanical-auto-switch)
4. Optional logic-level sensing

## 1) Concept and priorities

Basic rules:

* Only one connector is physically active at a time (standard combo jack constraint).
* Default mode is Mic (XLR path).
* Inserting a TRS plug forces Inst/Line mode for that channel.
* XLR path must remain purely passive in Mic mode.
* TRS path must not inject anything into the mic split / transformer network.

Mechanically this is done with:

* A combo connector with internal “normalling” switch contacts that change state when a TRS plug is inserted.
* Those contacts are wired so that:

  * With no TRS plug: CMB_XLR2/3 go straight to the mic split network (MIC_SPLIT_P/N).
  * With TRS plug: those connections open and the TRS tip is instead connected to the High-Z input (HIZ_IN).

In other words, the connector itself decides the mode; the schematic simply follows that.

## 2. Updated block-level behaviour

* CMB (combo) always feeds the Link mirror network passively (as already drawn).
* For the internal signal paths:

  * No TRS plug inserted:

    * CMB_XLR2/3 connected to MIC_SPLIT_P/N.
    * HIZ_IN disconnected.
    * Mic mode is active automatically.

  * TRS plug inserted:

    * CMB_XLR2/3 disconnected from MIC_SPLIT_P/N.
    * TRS tip (CMB_TRS_T) connected to HIZ_IN.
    * Inst/Line mode is active automatically.

You can keep the block diagram as-is conceptually, just mentally replace the manual Mode Select block with “mode determined by internal contacts in the combo connector”.

## 3. Netlist-level implementation (mechanical auto-switch)

Here is an updated fragment that replaces the abstract SW_MODE_A of the previous netlist. It assumes the combo connector has two changeover contacts operated by the TRS plug:

* One changeover contact per leg of the mic signal:

  * Normally closed (NC): connects XLR leg to mic split network.
  * Normally open (NO): connects TRS leg to High-Z network.
  * Common (COM): tied to the internal node going to split/Hi-Z.

3.1 New internal nodes

* MIC_HOT_COM      common hot node between mic split and TRS balancer
* MIC_COLD_COM     common cold node between mic split and (optional) TRS sense
* TRS_SENSE        optional node for logic sensing of TRS presence

3.2 Switch definition (conceptual)

Each “switch” is a changeover, but expressed as two separate elements in a generic netlist (NC and NO paths):

* SW_HOT_NC: closed when no TRS plug, open when TRS plug inserted
* SW_HOT_NO: open when no TRS plug, closed when TRS plug inserted

Cold leg is similar.

3.3 Mic/Inst auto-routing

Mic hot leg:

* From combo XLR pin 2 to common node:

  W_XH1  CMB_XLR2 MIC_HOT_COM             description=combo XLR hot into switch common

* Normally closed path: mic mode

  SW_HOT_NC  MIC_HOT_COM MIC_SPLIT_P      state=closed_if_TRS_not_inserted

* Normally open path: inst/line mode (for hot feed into HIZ input)

  SW_HOT_NO  MIC_HOT_COM HIZ_IN          state=closed_if_TRS_inserted

Mic cold leg:

* From combo XLR pin 3 to common node:

  W_XC1  CMB_XLR3 MIC_COLD_COM            description=combo XLR cold into switch common

* Normally closed path: mic mode (cold leg into transformer split)

  SW_COLD_NC MIC_COLD_COM MIC_SPLIT_N     state=closed_if_TRS_not_inserted

* Normally open path: not strictly needed for unbalanced inst/line, but can be left floating or used for sensing/balanced line:

  SW_COLD_NO MIC_COLD_COM TRS_SENSE      state=closed_if_TRS_inserted

In mic mode (no TRS plug):

* SW_HOT_NC is closed: MIC_HOT_COM → MIC_SPLIT_P
* SW_COLD_NC is closed: MIC_COLD_COM → MIC_SPLIT_N
* SW_HOT_NO and SW_COLD_NO are open, so HIZ_IN and TRS_SENSE see nothing.

In inst/line mode (TRS plug inserted):

* SW_HOT_NC and SW_COLD_NC are open: MIC_SPLIT_P/N are disconnected from the front connector.
* SW_HOT_NO is closed: MIC_HOT_COM node (now driven by the TRS tip through the combo internal connection) goes to HIZ_IN.
* SW_COLD_NO can be used for sensing or left unconnected.

The combo mechanics ensure:

* When only XLR is used: MIC_HOT_COM and MIC_COLD_COM are driven by XLR pins 2/3, TRS side is idle.
* When TRS is used: the XLR pins are not engaged; internally, MIC_HOT_COM is effectively the TRS tip.

3.4 Link network remaining unchanged

The Link mirror network defined before can stay as-is:

* It passively copies CMB_XLR2/3 (mic/balanced line) or CMB_TRS_T (inst/line) onto the Link connector.
* In practice, you have either:

  * CMB_XLR2/3 active (mic/balanced line), or
  * CMB_TRS_T active (inst/line).

Mechanical exclusivity of the combo ensures only one is actually driven.

4. Optional logic-level sensing

If you also want a logic signal to indicate the mode (for example to automatically enable/disable phantom power, or to mute/unmute the active driver), you can derive two simple logic nodes:

* MODE_INST: high when TRS is inserted.
* MODE_MIC: high when TRS is not inserted and there is an XLR connection (optional).

Simplest approach:

* Use the same mechanical contacts:

  * MODE_INST: connect one side of a pull-up resistor to Vlogic and the other side to a contact that is grounded or left open depending on TRS presence:

    R_MODE  Vlogic MODE_INST  value=100k
    SW_MODE_INST  MODE_INST GND_AUDIO  state=closed_if_TRS_inserted

    When TRS is inserted, SW_MODE_INST closes, pulling MODE_INST low or high depending on logic polarity; the micro or a simple transistor can interpret it.

* If you want XLR detection too, choose a combo connector that exposes “XLR-present” pins and use a similar network:

  R_MICDET  Vlogic MODE_MIC value=100k
  SW_MODE_MIC MODE_MIC GND_AUDIO state=closed_if_XLR_inserted

With that, you can:

* Drive a relay that fully depowers the active balancer in mic mode (fail-safe passive).
* Automatically inhibit phantom when MODE_INST is active.
* Switch indicator LEDs for Mic / Inst per channel.
