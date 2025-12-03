import FreeCAD, Part, Draft, importDXF
import os
import math

# ==========================================
# CONFIGURATION
# ==========================================
OUTPUT_DIR = os.path.join(os.path.expanduser("~"), "Desktop", "RecRack_Files")
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

# Dimensions (mm)
WIDTH_RACK = 482.6      # Total width (ears)
WIDTH_CHASSIS = 435.0   # Body width (fits in rails)
HEIGHT_1U = 44.45
DEPTH = 250.0           # Enclosure depth
THICK_PANEL = 3.0       # Front/Rear Thickness
THICK_BODY = 2.0        # Side Thickness
THICK_COVER = 1.5       # Top/Bottom Thickness

def create_base_plate(name, w, h, t):
    """Creates a basic rectangular plate."""
    obj = Part.makeBox(w, h, t)
    return obj

def make_rack_slots(panel_shape, w, h, t):
    """Adds standard EIA-310 rack mounting slots."""
    # Slots: 6x10mm ovals, center-to-center ~465mm
    slot_w, slot_h = 10.0, 6.0
    y_center = h / 2
    cuts = []
    for x in [8.75, w - 8.75]:
        s1 = Part.makeCylinder(slot_h/2, t, FreeCAD.Vector(x - 2, y_center, 0), FreeCAD.Vector(0,0,1))
        s2 = Part.makeCylinder(slot_h/2, t, FreeCAD.Vector(x + 2, y_center, 0), FreeCAD.Vector(0,0,1))
        s3 = Part.makeBox(4, slot_h, t, FreeCAD.Vector(x - 2, y_center - slot_h/2, 0))
        cuts.append(s1.fuse([s2, s3]))
    return panel_shape.cut(cuts)

def make_neutrik_combo(x, y, t):
    """Neutrik Combo / D-Series Cutout."""
    # Main Hole 24mm
    cuts = [Part.makeCylinder(12, t, FreeCAD.Vector(x, y, 0), FreeCAD.Vector(0,0,1))]
    # Screws (diagonal 24mm spacing roughly)
    # M3 holes at +/- 12mm X, +/- 9.5mm Y (approx standard D-size diagonal)
    cuts.append(Part.makeCylinder(1.6, t, FreeCAD.Vector(x-11, y+11, 0), FreeCAD.Vector(0,0,1))) # Top Left
    cuts.append(Part.makeCylinder(1.6, t, FreeCAD.Vector(x+11, y-11, 0), FreeCAD.Vector(0,0,1))) # Bot Right
    return cuts

def make_vent_grill(x, y, w, h, t):
    """Creates a ventilation grill pattern."""
    cuts = []
    slot_w = 3
    gap = 2
    num_slots = int(w / (slot_w + gap))
    start_x = x - w/2
    for i in range(num_slots):
        cx = start_x + i*(slot_w+gap)
        cuts.append(Part.makeBox(slot_w, h, t, FreeCAD.Vector(cx, y - h/2, 0)))
    return cuts

def generate_assembly():
    doc = FreeCAD.newDocument("RecRack_Enclosure")
    
    # ==========================================
    # 1. FRONT PANEL (Modified for RecRack)
    # ==========================================
    # Base
    f_geo = create_base_plate("Front_Base", WIDTH_RACK, HEIGHT_1U, THICK_PANEL)
    f_geo = make_rack_slots(f_geo, WIDTH_RACK, HEIGHT_1U, THICK_PANEL)
    
    cuts_f = []
    
    # Row 1: 8x Combo Inputs (Y=20)
    # Spacing: Groups of 4. 
    x_ch = [40, 85, 130, 175, 250, 295, 340, 385] # Optimized spacing
    for x in x_ch:
        cuts_f.extend(make_neutrik_combo(x, 20, THICK_PANEL))
        
    # Row 2: 8x TRS Link (Y=36)
    # 11.5mm holes above combos
    for x in x_ch:
        cuts_f.append(Part.makeCylinder(5.75, THICK_PANEL, FreeCAD.Vector(x, 36, 0), FreeCAD.Vector(0,0,1)))
        
    # Control Area (Right Side)
    # SD Slot (X=425)
    cuts_f.append(Part.makeBox(24, 3, THICK_PANEL, FreeCAD.Vector(425-12, 20, 0)))
    
    # OLED Display (X=455) - 30x15mm window
    cuts_f.append(Part.makeBox(30, 15, THICK_PANEL, FreeCAD.Vector(455-15, 25, 0)))
    
    # Encoder (X=455, Y=15)
    cuts_f.append(Part.makeCylinder(3.5, THICK_PANEL, FreeCAD.Vector(455, 15, 0), FreeCAD.Vector(0,0,1)))
    
    # Buttons (Rec/Stop) - small 6mm holes
    cuts_f.append(Part.makeCylinder(3, THICK_PANEL, FreeCAD.Vector(435, 15, 0), FreeCAD.Vector(0,0,1)))
    cuts_f.append(Part.makeCylinder(3, THICK_PANEL, FreeCAD.Vector(475, 15, 0), FreeCAD.Vector(0,0,1)))

    # Apply Cuts
    f_final = f_geo.cut(cuts_f)
    obj_f = doc.addObject("Part::Feature", "RecRack_Front")
    obj_f.Shape = f_final
    
    # ==========================================
    # 2. REAR PANEL (RecRack Outputs)
    # ==========================================
    # Using Chassis Width for rear panel main body usually, but user asked for 19". 
    # We will use 19" flat plate to match request.
    r_geo = create_base_plate("Rear_Base", WIDTH_RACK, HEIGHT_1U, THICK_PANEL)
    r_geo = make_rack_slots(r_geo, WIDTH_RACK, HEIGHT_1U, THICK_PANEL) # Optional on rear, but good for symmetry
    
    cuts_r = []
    
    # 16x XLR Outputs (Row A: Y=30, Row B: Y=12)
    # Spacing must be tight to fit 8 across. 
    # Center area X=40 to X=350
    start_x = 50
    step_x = 40 # 8 * 40 = 320mm span
    for i in range(8):
        x_pos = start_x + (i * step_x)
        cuts_r.extend(make_neutrik_combo(x_pos, 30, THICK_PANEL)) # Row A
        cuts_r.extend(make_neutrik_combo(x_pos, 12, THICK_PANEL)) # Row B
        
    # IEC Inlet (X=430, Y=22)
    # C14 Cutout 27.5x20
    cuts_r.append(Part.makeBox(27.5, 20, THICK_PANEL, FreeCAD.Vector(430-13.75, 22-10, 0)))
    # IEC Screws (40mm apart)
    cuts_r.append(Part.makeCylinder(1.75, THICK_PANEL, FreeCAD.Vector(430-20, 22, 0), FreeCAD.Vector(0,0,1)))
    cuts_r.append(Part.makeCylinder(1.75, THICK_PANEL, FreeCAD.Vector(430+20, 22, 0), FreeCAD.Vector(0,0,1)))
    
    # Vents (Near IEC, Far Left/Right empty space)
    cuts_r.extend(make_vent_grill(465, 22, 20, 25, THICK_PANEL)) # Right of IEC
    
    # Apply Cuts
    r_final = r_geo.cut(cuts_r)
    obj_r = doc.addObject("Part::Feature", "RecRack_Rear")
    obj_r.Shape = r_final
    # Position Rear Panel (At depth, facing backwards)
    obj_r.Placement = FreeCAD.Placement(FreeCAD.Vector(WIDTH_RACK, DEPTH, 0), FreeCAD.Rotation(FreeCAD.Vector(0,0,1), 180))

    # ==========================================
    # 3. SIDES (C-Channel Profiles)
    # ==========================================
    # Creates a C-shape: |____| to connect Front/Rear
    # Height = HEIGHT_1U, Depth = DEPTH - 2*THICK_PANEL (if sandwich) or Full Depth
    # Let's fit sides *between* Front and Rear panels.
    side_len = DEPTH - (2 * THICK_PANEL)
    
    # Profile shape (XY plane, extruded in Z (Length)) - Actually usually easier to extrude along Y.
    # We'll make a solid box and cut the inside.
    s_width = 15 # Flange width
    
    # Left Side
    s_geo = Part.makeBox(s_width, side_len, HEIGHT_1U)
    # Cutout inside to make 'C'
    cut_box = Part.makeBox(s_width - THICK_BODY, side_len, HEIGHT_1U - (2*THICK_BODY), 
                           FreeCAD.Vector(THICK_BODY, 0, THICK_BODY))
    s_final = s_geo.cut(cut_box)
    
    obj_sl = doc.addObject("Part::Feature", "Side_Left")
    obj_sl.Shape = s_final
    # Place: X offset to match Chassis Width (centered on Rack Width)
    # Rack Width 482.6. Chassis Width ~435. Center = 241.3
    # Left Side X = (482.6 - 435)/2 = 23.8
    x_offset = (WIDTH_RACK - WIDTH_CHASSIS) / 2
    obj_sl.Placement = FreeCAD.Placement(FreeCAD.Vector(x_offset, THICK_PANEL, 0), FreeCAD.Rotation(0,0,0))

    # Right Side (Mirror or duplicate)
    obj_sr = doc.addObject("Part::Feature", "Side_Right")
    obj_sr.Shape = s_final
    # Place: X = Width - x_offset - s_width
    # Rotation: 180 around Z to face inward
    obj_sr.Placement = FreeCAD.Placement(FreeCAD.Vector(WIDTH_RACK - x_offset, THICK_PANEL + side_len, 0), FreeCAD.Rotation(FreeCAD.Vector(0,0,1), 180))

    # ==========================================
    # 4. TOP & BOTTOM COVERS
    # ==========================================
    # Flat plates that sit on the side flanges
    # Width = Chassis Width - (2 * THICK_BODY) ? Or full width?
    # Usually cover is full Chassis Width (435mm).
    cover_w = WIDTH_CHASSIS
    cover_d = side_len
    
    # Top
    t_geo = create_base_plate("Top_Cover", cover_w, cover_d, THICK_COVER)
    obj_t = doc.addObject("Part::Feature", "RecRack_Top")
    obj_t.Shape = t_geo
    obj_t.Placement = FreeCAD.Placement(FreeCAD.Vector(x_offset, THICK_PANEL, HEIGHT_1U - THICK_COVER), FreeCAD.Rotation(0,0,0))

    # Bottom
    b_geo = create_base_plate("Bottom_Cover", cover_w, cover_d, THICK_COVER)
    obj_b = doc.addObject("Part::Feature", "RecRack_Bottom")
    obj_b.Shape = b_geo
    obj_b.Placement = FreeCAD.Placement(FreeCAD.Vector(x_offset, THICK_PANEL, 0), FreeCAD.Rotation(0,0,0))

    doc.recompute()
    
    # ==========================================
    # 5. EXPORT DXF
    # ==========================================
    parts = {
        "RecRack_Front.dxf": obj_f,
        "RecRack_Rear.dxf": obj_r,
        "RecRack_Top.dxf": obj_t,
        "RecRack_Bottom.dxf": obj_b,
        # For sides, we need to rotate them flat to export profile or face
        # "RecRack_Side.dxf": obj_sl 
    }
    
    print(f"Exporting to {OUTPUT_DIR}...")
    for name, obj in parts.items():
        try:
            path = os.path.join(OUTPUT_DIR, name)
            # Create a flat face reference for export if it's 3D
            # For simple plates, using the main shape usually works with legacy exporter
            importDXF.export([obj], path)
            print(f"Saved: {name}")
        except Exception as e:
            print(f"Could not export {name}: {e}")

    print("Done! Complete assembly generated.")

if __name__ == "__main__":
    generate_assembly()
