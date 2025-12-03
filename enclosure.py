import FreeCAD, Part, Draft, importDXF
import os

# --- Configuration ---
# Output directory (Defaults to your Desktop, change if needed)
output_dir = os.path.join(os.path.expanduser("~"), "Desktop")
panel_thickness = 2.0  # mm (Standard Aluminum)

def create_panel_base(name, width=482.6, height=44.45, thickness=2.0):
    """Creates the 1U panel base with EIA-310 rack slots."""
    # Base Plate
    base = Part.makeBox(width, height, thickness)
    
    # Rack Slots (Oval Stadium Shape) - EIA-310 Spacing
    # Center-to-center width: 465.1mm. Distance from edge: 8.75mm
    slot_w, slot_h = 10.0, 6.0
    y_center = height / 2
    cutouts = []
    
    for x in [8.75, width - 8.75]:
        # Create stadium shape: Box + 2 Cylinders
        s1 = Part.makeCylinder(slot_h/2, thickness, FreeCAD.Vector(x - (slot_w-slot_h)/2, y_center, 0), FreeCAD.Vector(0,0,1))
        s2 = Part.makeCylinder(slot_h/2, thickness, FreeCAD.Vector(x + (slot_w-slot_h)/2, y_center, 0), FreeCAD.Vector(0,0,1))
        s3 = Part.makeBox(slot_w-slot_h, slot_h, thickness, FreeCAD.Vector(x - (slot_w-slot_h)/2, y_center - slot_h/2, 0))
        slot = s1.fuse([s2, s3])
        cutouts.append(slot)
        
    final_panel = base.cut(cutouts)
    obj = FreeCAD.ActiveDocument.addObject("Part::Feature", name)
    obj.Shape = final_panel
    return obj

def make_neutrik_d_cutout(x, y, thickness):
    """Creates a standard Neutrik 'D' Series cutout (24mm hole + diagonal screws)."""
    # Main Hole: 24mm diameter
    main_hole = Part.makeCylinder(12, thickness, FreeCAD.Vector(x, y, 0), FreeCAD.Vector(0,0,1))
    
    # Mounting Holes: Diagonal (Top-Left / Bottom-Right)
    # Standard spacing: 19mm Vertical, 24mm Horizontal
    # From center: +/- 12mm X, +/- 9.5mm Y
    screw_r = 1.6 # M3 clearance (3.2mm dia)
    s1 = Part.makeCylinder(screw_r, thickness, FreeCAD.Vector(x-12, y+9.5, 0), FreeCAD.Vector(0,0,1)) # Top-Left
    s2 = Part.makeCylinder(screw_r, thickness, FreeCAD.Vector(x+12, y-9.5, 0), FreeCAD.Vector(0,0,1)) # Bot-Right
    
    return [main_hole, s1, s2]

def make_iec_cutout(x, y, thickness):
    """Creates IEC C14 Cutout with screw holes."""
    # Main Body: 27.5mm x 20.0mm
    body = Part.makeBox(27.5, 20.0, thickness, FreeCAD.Vector(x-27.5/2, y-20.0/2, 0))
    
    # Mounting Holes: 40mm spacing (horizontal)
    screw_r = 1.75 # 3.5mm dia
    s1 = Part.makeCylinder(screw_r, thickness, FreeCAD.Vector(x-20, y, 0), FreeCAD.Vector(0,0,1))
    s2 = Part.makeCylinder(screw_r, thickness, FreeCAD.Vector(x+20, y, 0), FreeCAD.Vector(0,0,1))
    
    return [body, s1, s2]

def make_recrack_files():
    doc = FreeCAD.newDocument("RecRack_Project")
    
    # ==========================================
    # 1. FRONT PANEL GENERATION
    # ==========================================
    front = create_panel_base("RecRack_Front", thickness=panel_thickness)
    front_cuts = []
    
    # Row 1: Combo XLR (Y=20mm)
    x_combos = [40, 90, 140, 190, 240, 290, 340, 390]
    for x in x_combos:
        front_cuts.extend(make_neutrik_d_cutout(x, 20, panel_thickness))
        
    # Row 2: TRS Link (Y=35mm)
    # Standard 1/4" Jack (11.5mm dia)
    for x in x_combos:
        trs = Part.makeCylinder(11.5/2, panel_thickness, FreeCAD.Vector(x, 35, 0), FreeCAD.Vector(0,0,1))
        front_cuts.append(trs)
        
    # Control Area (Right Side)
    # SD Slot (Approx 24x4mm) at X=435, Y=20
    sd_slot = Part.makeBox(24, 4, panel_thickness, FreeCAD.Vector(435-12, 20-2, 0))
    front_cuts.append(sd_slot)
    
    # OLED Cutout (Rect 30x15) at X=460, Y=32.5
    oled = Part.makeBox(30, 15, panel_thickness, FreeCAD.Vector(460-15, 32.5-7.5, 0))
    front_cuts.append(oled)
    
    # Encoder Hole (7mm dia) at X=460, Y=15
    enc = Part.makeCylinder(3.5, panel_thickness, FreeCAD.Vector(460, 15, 0), FreeCAD.Vector(0,0,1))
    front_cuts.append(enc)

    # Apply Cuts
    front.Shape = front.Shape.cut(front_cuts)
    
    # ==========================================
    # 2. REAR PANEL GENERATION
    # ==========================================
    rear = create_panel_base("RecRack_Rear", thickness=panel_thickness)
    rear_cuts = []
    
    # 16x XLR Outputs (Row A Y=30, Row B Y=12)
    # X Coords: 35, 80, 125, 170, 215, 260, 305, 350
    x_outs = [35, 80, 125, 170, 215, 260, 305, 350]
    for x in x_outs:
        rear_cuts.extend(make_neutrik_d_cutout(x, 30, panel_thickness)) # Top Row
        rear_cuts.extend(make_neutrik_d_cutout(x, 12, panel_thickness)) # Bottom Row
        
    # IEC Inlet (Right side X=420, Y=22)
    rear_cuts.extend(make_iec_cutout(420, 22, panel_thickness))
    
    # Apply Cuts
    rear.Shape = rear.Shape.cut(rear_cuts)
    
    doc.recompute()
    
    # ==========================================
    # 3. EXPORT
    # ==========================================
    print(f"Exporting files to {output_dir}...")
    
    # Export DXF (2D Projection of the face)
    try:
        import importDXF
        # Export Front
        f_path = os.path.join(output_dir, "RecRack_Front.dxf")
        importDXF.export([front], f_path)
        print(f"Created: {f_path}")
        
        # Export Rear
        r_path = os.path.join(output_dir, "RecRack_Rear.dxf")
        importDXF.export([rear], r_path)
        print(f"Created: {r_path}")
        
        print("Success! Open the files to verify cutouts.")
    except Exception as e:
        print(f"DXF Export Error: {e}. You can manually export by selecting the face -> File -> Export.")

make_recrack_files()
