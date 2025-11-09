# UI Nostalgia Transformation - 80s/90s Video Game Console Aesthetic

## Overview

Transform the entire application UI to recreate the authentic look and feel of classic 80s/90s video game consoles (NES, SNES, Game Boy, Sega Genesis era). The design will feature a physical console frame/bezel, CRT screen effects, retro color palettes, pixelated typography, and ensure all activities fit within a defined console screen area.

## Design Philosophy

### Core Aesthetic Principles
- **Physical Console Frame**: Visible bezel/frame around the game screen, mimicking real hardware
- **CRT Display Effects**: Scanlines, screen curvature, phosphor glow, slight screen flicker
- **Retro Color Palette**: Limited color palette with high contrast (typical of 8-bit/16-bit era)
- **Pixelated Typography**: Use pixel fonts or retro-styled fonts that evoke classic game systems
- **Sharp, Minimal Corners**: Replace rounded corners with sharp edges or minimal 2-4px radius
- **Screen Containment**: All activities must fit within a defined console screen area (not full viewport)
- **Nostalgic UI Elements**: Menu systems, button styles, and feedback that recall classic game interfaces

## Technical Implementation

### 1. Console Frame Structure

**File**: `scenes/Main.tscn`

Create a layered structure:
```
Main (Control - full viewport)
├─ ConsoleBezel (NinePatchRect or TextureRect)
│  └─ ConsoleScreenArea (Control - defines playable area)
│     ├─ CRT Effects Layer (ColorRect with shader/material)
│     ├─ GameContainer (existing, now constrained to screen area)
│     └─ Scanline Overlay (ColorRect with shader)
├─ MenuContainer (existing, constrained to screen area)
└─ ModalLayer (existing, but styled for console)
```

**Console Screen Dimensions**:
- Define a fixed console screen area (e.g., 960x640 or 1024x768) centered in viewport
- All activities must fit within this area
- Add padding/margins to create visible bezel around screen

**Bezel Design**:
- Dark gray/black frame (#1a1a1a to #2d2d2d)
- Optional: Add texture or gradient to simulate plastic console material
- Include subtle highlights/shadows for 3D effect
- May include decorative elements (branding area, power LED indicator)

**Implementation Details**:

**Step 1: Create Console Bezel Structure**
1. Open `scenes/Main.tscn` in Godot editor
2. Select the root `Main` Control node
3. Add a new `Control` node as child, rename to `ConsoleBezel`
4. Set ConsoleBezel anchors to center:
   - Anchor preset: Center
   - Set custom size: 1100x750 (or appropriate size for viewport)
   - Position: Calculate center position based on viewport size
5. Add a `ColorRect` node as child of ConsoleBezel, rename to `BezelBackground`
6. Set BezelBackground to fill ConsoleBezel:
   - Anchor preset: Full Rect
   - Color: `Color(0.1, 0.1, 0.1, 1)` (#1a1a1a - dark gray)
7. Add a `Control` node as child of ConsoleBezel, rename to `ConsoleScreenArea`
8. Set ConsoleScreenArea size: 960x640 (or appropriate screen size)
9. Center ConsoleScreenArea within ConsoleBezel:
   - Anchor preset: Center
   - Calculate offset: (bezel_width - screen_width) / 2, (bezel_height - screen_height) / 2

**Step 2: Move Existing Containers**
1. In Main.tscn, locate `GameContainer` node
2. Drag `GameContainer` to be child of `ConsoleScreenArea` (not direct child of Main)
3. Locate `MenuContainer` node
4. Drag `MenuContainer` to be child of `ConsoleScreenArea`
5. Verify both containers are now children of ConsoleScreenArea

**Step 3: Add CRT Effects Layer**
1. Add a `ColorRect` node as child of ConsoleScreenArea, rename to `CRTEffectsLayer`
2. Set CRTEffectsLayer to fill ConsoleScreenArea:
   - Anchor preset: Full Rect
   - Color: `Color(0.04, 0.06, 0.1, 1)` (console screen background - dark blue-black)
   - Move to top of ConsoleScreenArea children (renders first, behind content)

**Step 4: Add Scanline Overlay**
1. Add a `ColorRect` node as child of ConsoleScreenArea, rename to `ScanlineOverlay`
2. Set ScanlineOverlay to fill ConsoleScreenArea:
   - Anchor preset: Full Rect
   - Color: `Color(0, 0, 0, 0.12)` (semi-transparent black for scanlines)
3. Create scanline shader or texture:
   - Option A: Use shader with repeating horizontal lines
   - Option B: Use texture with scanline pattern
   - Apply to ScanlineOverlay material
4. Move ScanlineOverlay to top of ConsoleScreenArea children (renders last, on top)

**Step 5: Update Main.gd Script**
1. Open `scripts/Main.gd`
2. Add helper functions to get console screen area:
   ```gdscript
   @onready var console_screen_area = $ConsoleBezel/ConsoleScreenArea
   
   func get_console_screen_position() -> Vector2:
       return console_screen_area.global_position
   
   func get_console_screen_size() -> Vector2:
       return console_screen_area.size
   ```
3. Update `_show_error_toast()` function:
   - Replace viewport-based positioning with console screen area positioning
   - Use `get_console_screen_position()` and `get_console_screen_size()` helpers
4. Test that toast appears within console screen area

**Step 6: Add Bezel Visual Details (Optional)**
1. Add decorative elements to ConsoleBezel:
   - Add `Label` node for "VOCAB CONSOLE" branding text
   - Position at top or bottom of bezel
   - Use retro font, small size (12-16px)
   - Color: `Color(0.5, 0.5, 0.5, 1)` (medium gray)
2. Add power LED indicator:
   - Add small `ColorRect` node to ConsoleBezel
   - Size: 8x8 or 10x10 pixels
   - Position: Top corner of bezel
   - Color: `Color(0, 1, 0, 1)` (retro green) or `Color(1, 0, 0, 1)` (red)
   - Optional: Add AnimationPlayer for pulsing effect

**Step 7: Verify Structure**
1. Run scene and verify:
   - ConsoleBezel is visible around screen
   - ConsoleScreenArea contains GameContainer and MenuContainer
   - All content fits within ConsoleScreenArea bounds
   - Bezel has appropriate visual styling

### 2. CRT Display Effects

**Implementation Options**:
- **Shader-based**: Create or use existing CRT shader for scanlines, curvature, phosphor glow
- **Texture-based**: Use overlay textures for scanlines and screen effects
- **ColorRect with modulation**: Simulate CRT color characteristics

**Effects to Include**:
- **Scanlines**: Horizontal lines across screen (every 2-4 pixels)
- **Screen Curvature**: Subtle barrel distortion at edges
- **Phosphor Glow**: Slight color bleed/bloom effect
- **Screen Flicker**: Very subtle brightness variation (optional, can be disabled)
- **Color Saturation**: Slightly desaturated colors with specific color temperature

**Implementation Details**:

**Step 1: Create Scanline Overlay (Texture-Based Approach)**
1. Create scanline texture (or use shader):
   - Option A: Create 1x4 pixel image (2px black, 2px transparent)
   - Option B: Use shader with repeating pattern
2. In Main.tscn, locate `ScanlineOverlay` ColorRect (created in Console Frame section)
3. If using texture:
   - Create new `TextureRect` node as child of ConsoleScreenArea
   - Rename to `ScanlineTexture`
   - Set to fill screen (Full Rect anchor)
   - Load scanline texture
   - Set stretch mode: Tile
   - Modulate color: `Color(1, 1, 1, 0.12)` (12% opacity)
4. If using shader:
   - Create new `.gdshader` file: `assets/shaders/scanlines.gdshader`
   - Write shader code for horizontal lines
   - Create `ShaderMaterial` resource
   - Apply to ScanlineOverlay ColorRect

**Step 2: Implement Scanline Shader (If Using Shader)**
1. Create file: `assets/shaders/scanlines.gdshader`
2. Write shader code:
   ```glsl
   shader_type canvas_item;
   
   uniform float line_spacing = 2.0;
   uniform float opacity = 0.12;
   
   void fragment() {
       float line = mod(SCREEN_UV.y * SCREEN_PIXEL_SIZE.y, line_spacing);
       if (line < 1.0) {
           COLOR = vec4(0.0, 0.0, 0.0, opacity);
       } else {
           COLOR = vec4(0.0, 0.0, 0.0, 0.0);
       }
   }
   ```
3. Create `ShaderMaterial` resource
4. Apply to ScanlineOverlay ColorRect material property

**Step 3: Add Screen Curvature Effect (Optional)**
1. Create file: `assets/shaders/crt_curvature.gdshader`
2. Write shader code for barrel distortion:
   ```glsl
   shader_type canvas_item;
   
   uniform float curvature = 0.1;
   
   void fragment() {
       vec2 uv = SCREEN_UV;
       vec2 center = vec2(0.5, 0.5);
       vec2 dist = uv - center;
       float dist_squared = dot(dist, dist);
       vec2 curved = center + dist * (1.0 + curvature * dist_squared);
       COLOR = texture(SCREEN_TEXTURE, curved);
   }
   ```
3. Create `ShaderMaterial` resource
4. Apply to ConsoleScreenArea or CRTEffectsLayer
5. Adjust curvature uniform (0.05-0.15 for subtle effect)

**Step 4: Add Phosphor Glow Effect (Optional)**
1. Create `ColorRect` node as child of ConsoleScreenArea, rename to `PhosphorGlow`
2. Set PhosphorGlow to fill screen (Full Rect anchor)
3. Create blur shader or use modulate:
   - Option A: Use `BackBufferCopy` node with blur shader
   - Option B: Use modulate with very low opacity: `Color(1, 1, 1, 0.02)`
4. Position PhosphorGlow behind content but above CRTEffectsLayer
5. Adjust opacity to very subtle (0.01-0.03)

**Step 5: Add Screen Flicker Effect (Optional)**
1. Create `AnimationPlayer` node as child of ConsoleScreenArea
2. Create new animation: "screen_flicker"
3. Add track for ConsoleScreenArea modulate property
4. Create keyframes:
   - Frame 0: modulate = `Color(1, 1, 1, 1.0)`
   - Frame 0.5: modulate = `Color(1, 1, 1, 0.98)`
   - Frame 1.0: modulate = `Color(1, 1, 1, 1.0)`
5. Set animation to loop
6. Set length: 2.0 seconds (slow, subtle)
7. Enable/disable via script or user preference

**Step 6: Adjust Color Saturation (Optional)**
1. Create `ColorRect` node as child of ConsoleScreenArea, rename to `ColorFilter`
2. Set ColorFilter to fill screen (Full Rect anchor)
3. Use modulate or shader to desaturate slightly:
   - Modulate: `Color(0.95, 0.95, 1.0, 1.0)` (slight blue tint, retro feel)
   - Or use shader for more control
4. Position ColorFilter appropriately in render order

**Step 7: Test and Tune Effects**
1. Run scene and test all effects
2. Adjust scanline opacity (0.1-0.15 range)
3. Adjust curvature intensity (subtle only)
4. Adjust phosphor glow opacity (very subtle)
5. Test flicker effect (should be barely noticeable)
6. Verify effects don't impact performance significantly
7. Add option to disable effects for accessibility

**Files to Create/Modify**:
- `assets/shaders/scanlines.gdshader` (if using shader approach)
- `assets/shaders/crt_curvature.gdshader` (if using curvature)
- `scenes/Main.tscn` - Add CRT effect nodes
- `scripts/Main.gd` - Add effect toggle functions (optional)

### 3. Theme File Overhaul

**File**: `assets/vocab_zoo_theme.tres`

**Color Palette Transformation**:

Replace current modern colors with retro palette:
- **Background**: Deep black (#000000) or very dark gray (#0a0a0a)
- **Console Screen BG**: Dark blue-black (#0a0f1a) or dark green-black (#0a1a0a) for Game Boy feel
- **Primary Colors**: 
  - Retro blue: #0066ff
  - Retro green: #00ff00
  - Retro red: #ff0000
  - Retro yellow: #ffff00
  - Retro purple: #ff00ff
  - Retro cyan: #00ffff
- **Text Colors**: High contrast white (#ffffff) or light colors (#e0e0e0)
- **Border Colors**: Sharp, high-contrast borders (white, yellow, or primary colors)
- **Panel/Card Colors**: Dark with bright borders (#1a1a1a with #ffffff borders)

**Button Styles**:
- Remove rounded corners (set corner_radius to 0-2px max)
- Sharp, pixelated appearance
- High-contrast borders (2-4px solid)
- Remove soft shadows, use hard shadows or none
- Hover states: Bright color shift, no glow effects
- Pressed states: Inverted colors or darker shade

**Panel Styles**:
- Sharp corners (0-2px radius)
- High-contrast borders
- Dark backgrounds with bright borders
- Remove gradient backgrounds, use solid colors
- Optional: Add pixelated texture overlay

**Label/Text Styles**:
- Use pixel font or retro-styled font
- High contrast colors
- Sharp text shadows (not soft)
- Remove letter spacing adjustments
- Consider monospace for certain elements

**Input Styles**:
- Sharp corners
- High-contrast borders
- Dark background with bright border on focus
- Remove soft focus effects

**Progress Bar Styles**:
- Pixelated appearance
- Sharp corners
- High-contrast colors
- Optional: Add segment divisions for retro feel

**Implementation Details**:

**Step 1: Backup and Prepare**
1. Create backup of `assets/vocab_zoo_theme.tres`
2. Open `vocab_zoo_theme.tres` in text editor (or Godot theme editor)
3. Note current structure and sub-resource IDs

**Step 2: Update Button StyleBoxFlat Sub-Resources**
1. Locate `[sub_resource type="StyleBoxFlat" id="button_normal"]`
2. Update properties:
   ```
   bg_color = Color(0, 0.4, 1, 1)  # Retro blue #0066ff
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(1, 1, 1, 1)  # White border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0  # Remove shadow
   shadow_offset = Vector2(0, 0)
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="button_hover"]`
4. Update properties:
   ```
   bg_color = Color(0, 0.5, 1, 1)  # Brighter retro blue
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(1, 1, 0, 1)  # Yellow border for contrast
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0  # Remove glow/shadow
   ```
5. Locate `[sub_resource type="StyleBoxFlat" id="button_pressed"]`
6. Update properties:
   ```
   bg_color = Color(0, 0.3, 0.8, 1)  # Darker retro blue
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(1, 1, 1, 1)  # White border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0
   ```
7. Locate `[sub_resource type="StyleBoxFlat" id="button_disabled"]`
8. Update properties:
   ```
   bg_color = Color(0.2, 0.2, 0.2, 1)  # Dark gray
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.5, 0.5, 0.5, 1)  # Gray border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0
   ```

**Step 3: Update Memory Game Button Styles**
1. Locate `[sub_resource type="StyleBoxFlat" id="button_memory_down"]`
2. Update to retro colors:
   ```
   bg_color = Color(0.2, 0.2, 0.2, 1)  # Dark gray
   border_color = Color(1, 1, 1, 1)  # White border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="button_memory_up"]`
4. Update to retro colors:
   ```
   bg_color = Color(0.1, 0.1, 0.1, 1)  # Very dark gray
   border_color = Color(1, 1, 1, 1)  # White border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
5. Locate `[sub_resource type="StyleBoxFlat" id="button_memory_matched"]`
6. Update to retro green:
   ```
   bg_color = Color(0, 1, 0, 1)  # Retro green
   border_color = Color(0, 1, 0, 1)  # Same as bg
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```

**Step 4: Update Answer Button Styles**
1. Locate `[sub_resource type="StyleBoxFlat" id="button_answer_correct"]`
2. Update to retro green:
   ```
   bg_color = Color(0, 1, 0, 1)  # Retro green
   border_color = Color(0, 1, 0, 1)
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="button_answer_wrong"]`
4. Update to retro red:
   ```
   bg_color = Color(1, 0, 0, 1)  # Retro red
   border_color = Color(1, 0, 0, 1)
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```

**Step 5: Update Panel Styles**
1. Locate `[sub_resource type="StyleBoxFlat" id="panel_card"]`
2. Update properties:
   ```
   bg_color = Color(0.1, 0.1, 0.1, 1)  # Dark gray #1a1a1a
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(1, 1, 1, 1)  # White border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0  # Remove shadow
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="panel_surface"]`
4. Update properties:
   ```
   bg_color = Color(0.15, 0.15, 0.15, 1)  # Slightly lighter gray
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
5. Locate `[sub_resource type="StyleBoxFlat" id="panel_modal"]`
6. Update properties:
   ```
   bg_color = Color(0.1, 0.1, 0.1, 1)  # Dark gray
   border_width_left = 4
   border_width_top = 4
   border_width_right = 4
   border_width_bottom = 4
   border_color = Color(1, 1, 0, 1)  # Yellow border for modals
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0  # Remove shadow
   ```

**Step 6: Update Input/LineEdit Styles**
1. Locate `[sub_resource type="StyleBoxFlat" id="input_normal"]`
2. Update properties:
   ```
   bg_color = Color(0.15, 0.15, 0.15, 1)  # Dark gray
   border_width_left = 2
   border_width_top = 2
   border_width_right = 2
   border_width_bottom = 2
   border_color = Color(0.3, 0.3, 0.3, 1)  # Subtle border
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="input_focus"]`
4. Update properties:
   ```
   bg_color = Color(0.15, 0.15, 0.15, 1)  # Dark gray
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0, 1, 1, 1)  # Retro cyan border on focus
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   shadow_size = 0  # Remove glow
   ```

**Step 7: Update ProgressBar Styles**
1. Locate `[sub_resource type="StyleBoxFlat" id="progress_bg"]`
2. Update properties:
   ```
   bg_color = Color(0.15, 0.15, 0.15, 1)  # Dark gray background
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```
3. Locate `[sub_resource type="StyleBoxFlat" id="progress_fill"]`
4. Update properties:
   ```
   bg_color = Color(0, 1, 0, 1)  # Retro green fill
   corner_radius_top_left = 2
   corner_radius_top_right = 2
   corner_radius_bottom_right = 2
   corner_radius_bottom_left = 2
   ```

**Step 8: Update Theme Resource Colors**
1. Locate `[resource]` section at end of file
2. Update Button colors:
   ```
   Button/colors/font_color = Color(1, 1, 1, 1)  # White text
   Button/colors/font_focus_color = Color(1, 1, 1, 1)
   Button/colors/font_hover_color = Color(1, 1, 1, 1)
   Button/colors/font_pressed_color = Color(1, 1, 1, 1)
   Button/colors/font_disabled_color = Color(0.7, 0.7, 0.7, 1)  # Gray disabled
   ```
3. Update Label colors:
   ```
   Label/colors/font_color = Color(1, 1, 1, 1)  # White text
   Label/colors/font_shadow_color = Color(0, 0, 0, 1)  # Black shadow
   Label/constants/shadow_offset_x = 2
   Label/constants/shadow_offset_y = 2  # Sharp shadow offset
   ```
4. Update LineEdit colors:
   ```
   LineEdit/colors/font_color = Color(1, 1, 1, 1)  # White text
   LineEdit/colors/caret_color = Color(0, 1, 1, 1)  # Retro cyan caret
   LineEdit/colors/selection_color = Color(0, 0.4, 1, 0.5)  # Retro blue selection
   ```
5. Update ProgressBar colors:
   ```
   ProgressBar/colors/font_color = Color(1, 1, 1, 1)  # White text
   ```
6. Update RichTextLabel colors (see Section 28 for details)

**Step 9: Verify All Updates**
1. Save `vocab_zoo_theme.tres`
2. Open project in Godot
3. Check for any syntax errors
4. Test theme in editor
5. Verify all buttons, panels, inputs use retro styling

### 4. Typography Update

**Font Selection**:
- **Option A**: Use existing fonts but with pixelated rendering settings
- **Option B**: Add pixel font resources (need to source or create)
- **Option C**: Use monospace font for retro computer terminal feel

**Font Sizes**:
- Maintain readability but adjust for pixel aesthetic
- Consider using multiples of 8px for pixel-perfect alignment
- Headers: 24px, 32px, 48px (multiples of 8)
- Body: 16px, 20px

**Implementation Details**:

**Step 1: Source Pixel Font**
1. Choose pixel font (recommended: "Press Start 2P" - free, open source)
2. Download font files (.ttf or .otf format)
3. Alternative fonts to consider:
   - Press Start 2P (8-bit style)
   - Pixel Font (generic pixel)
   - Monospace fonts (terminal feel)

**Step 2: Add Font to Project**
1. Copy font file(s) to `assets/fonts/` directory
2. Example: `assets/fonts/press-start-2p.ttf`
3. Godot will auto-import font on next project load
4. Verify font appears in FileSystem dock

**Step 3: Create Font Resource (If Needed)**
1. In Godot editor, right-click font file in FileSystem
2. Select "New Resource" → "FontFile"
3. Or font will auto-import as FontFile resource
4. Note the resource path for theme update

**Step 4: Update Theme Font References**
1. Open `assets/vocab_zoo_theme.tres` in text editor
2. Locate `[ext_resource]` section at top
3. Add new ExtResource for pixel font:
   ```
   [ext_resource type="FontFile" path="res://assets/fonts/press-start-2p.ttf" id="3"]
   ```
   (Use next available ID number)
4. Locate `[resource]` section
5. Update Button font:
   ```
   Button/fonts/font = ExtResource("3")  # Replace ExtResource("1") with pixel font
   ```
6. Update Label font:
   ```
   Label/fonts/font = ExtResource("3")  # Replace ExtResource("2") with pixel font
   ```
7. Update LineEdit font:
   ```
   LineEdit/fonts/font = ExtResource("3")  # Replace ExtResource("2") with pixel font
   ```
8. Update RichTextLabel fonts:
   ```
   RichTextLabel/fonts/normal_font = ExtResource("3")
   RichTextLabel/fonts/bold_font = ExtResource("3")  # Or keep bold version if available
   ```

**Step 5: Adjust Font Sizes for Pixel Aesthetic**
1. In theme file, update font sizes to multiples of 8px:
   ```
   Button/font_sizes/font_size = 16  # Keep or adjust to 16, 24, 32
   Label/font_sizes/font_size = 16  # Keep or adjust to 16, 24, 32
   LineEdit/font_sizes/font_size = 16
   RichTextLabel/font_sizes/normal_font_size = 16
   RichTextLabel/font_sizes/bold_font_size = 18  # Or 16, 24
   ```
2. Consider pixel-perfect sizing:
   - Headers: 24px, 32px, 48px, 56px (multiples of 8)
   - Body: 16px, 20px
   - Small: 12px, 14px

**Step 6: Update Scene-Level Font Size Overrides**
1. Review all `.tscn` files for `theme_override_font_sizes`
2. Update to multiples of 8px where possible:
   - Main.tscn TitleLabel: 48px or 56px (instead of 56px, keep if already multiple of 8)
   - Modal.tscn TitleLabel: 32px (instead of 32px, verify)
   - Activity scene headers: 24px or 32px
3. Update in scene files:
   ```
   theme_override_font_sizes/font_size = 32  # Example: multiple of 8
   ```

**Step 7: Test Font Rendering**
1. Save theme file
2. Open project in Godot
3. Run scene and test:
   - Button text readability
   - Label text readability
   - Input field text readability
   - RichTextLabel BBCode text
4. Adjust font sizes if text is too small/large
5. Verify pixel font renders correctly (not blurry)

**Step 8: Handle Font Fallback (If Needed)**
1. If pixel font doesn't support all characters:
   - Consider keeping Nunito for body text
   - Use pixel font only for headers/buttons
   - Or use system font fallback
2. Test with various text content
3. Ensure emojis/special characters render (see Section 31)

**File Updates**:
- `assets/fonts/` - Add pixel font file(s)
- `assets/vocab_zoo_theme.tres` - Update all font references
- All `.tscn` files - Update font size overrides to multiples of 8px

### 5. Activity Scene Constraints

**All Activity Scenes Must**:
- Fit within console screen area (not full viewport)
- Use retro-styled UI elements from updated theme
- Remove any full-screen backgrounds, use console screen background
- Ensure content doesn't overflow console screen bounds

**Files to Review** (for constraint application):
- `scenes/FillInBlank.tscn`
- `scenes/Flashcards.tscn`
- `scenes/MemoryGame.tscn`
- `scenes/MultipleChoice.tscn`
- `scenes/SentenceGen.tscn`
- `scenes/SynonymAntonym.tscn`
- `scenes/WordMatching.tscn`
- `scenes/Completion.tscn`
- `scenes/VocabularyError.tscn`

**Implementation Details**:

**Step 1: Update Each Activity Scene File (.tscn)**
For each scene file (FillInBlank, MultipleChoice, WordMatching, etc.):

1. **Open scene in Godot editor**
2. **Update Background ColorRect**:
   - Locate `Background` ColorRect node
   - Change color property:
     - From: `Color(0, 0, 0, 1)`
     - To: `Color(0.04, 0.06, 0.1, 1)` (console screen background)
   - Or remove Background entirely (let console screen provide background)
3. **Update Root Control Node**:
   - Select root Control node
   - Ensure anchors are set to Full Rect (for proper sizing)
   - Verify it will respect parent container (ConsoleScreenArea) bounds
4. **Review All UI Element Positions**:
   - Check HeaderBar, FooterBar, QuestionPanel positions
   - Ensure they use relative positioning (anchors) not absolute
   - Adjust any hardcoded offsets if needed
5. **Update Color Overrides** (see Section 14 for details):
   - Change all `theme_override_colors/font_color` to retro white
   - Update any other color overrides
6. **Save scene file**

**Step 2: Update Scene Scripts for Console Screen Dimensions**
For each activity script (FillInBlank.gd, MultipleChoice.gd, etc.):

1. **Add Console Screen Helper Functions**:
   ```gdscript
   # Get console screen area from Main scene
   func get_console_screen_area() -> Control:
       var main = get_tree().get_first_node_in_group("main")  # Or use autoload
       if main and main.has_node("ConsoleBezel/ConsoleScreenArea"):
           return main.get_node("ConsoleBezel/ConsoleScreenArea")
       return null
   
   func get_console_screen_size() -> Vector2:
       var screen_area = get_console_screen_area()
       if screen_area:
           return screen_area.size
       # Fallback to viewport if console screen not found
       return get_viewport_rect().size
   ```

2. **Replace Viewport Size Calculations**:
   - Find all instances of `get_viewport_rect().size`
   - Replace with `get_console_screen_size()`
   - Example in FillInBlank.gd:
     ```gdscript
     # Old:
     var viewport_width = get_viewport_rect().size.x
     # New:
     var screen_width = get_console_screen_size().x
     ```

3. **Update Positioning Calculations**:
   - Review all position calculations that use viewport dimensions
   - Update to use console screen dimensions
   - Ensure content centers within console screen area
   - Example:
     ```gdscript
     # Old:
     var center_x = get_viewport_rect().size.x / 2
     # New:
     var screen_area = get_console_screen_area()
     var center_x = screen_area.size.x / 2 if screen_area else get_viewport_rect().size.x / 2
     ```

4. **Update Game Area Setup** (FillInBlank.gd specific):
   - Update `_setup_game_area()` function
   - Ensure game_area respects console screen bounds
   - Update ship positioning to use console screen dimensions

**Step 3: Test Each Activity Scene**
1. **Run Main scene**
2. **Navigate to each activity**:
   - FillInBlank
   - MultipleChoice
   - WordMatching
   - SynonymAntonym
   - MemoryGame
   - SentenceGen
3. **Verify for each activity**:
   - All content fits within console screen area
   - No UI elements overflow bezel
   - Text is readable
   - Buttons are accessible
   - Game mechanics work correctly
4. **Check edge cases**:
   - Long text doesn't overflow
   - Many answer options fit on screen
   - Character positioning (if any remain) is correct
5. **Fix any overflow issues**:
   - Adjust font sizes if needed
   - Reduce spacing if needed
   - Reposition elements if needed

**Step 4: Update Completion and Error Scenes**
1. **Completion.tscn**:
   - Update Background ColorRect color
   - Update all color overrides
   - Ensure content fits in console screen
   - Remove character containers (see Section 6)
2. **VocabularyError.tscn**:
   - Update Background ColorRect color
   - Update all color overrides (see Section 29)
   - Ensure error panel fits in console screen
   - Update modulate opacity if needed

**Step 5: Create Helper Script (Optional)**
1. Create utility script for console screen helpers:
   ```gdscript
   # scripts/ConsoleScreenHelper.gd
   extends Node
   
   static func get_screen_area() -> Control:
       # Helper to get console screen area from anywhere
       # Implementation depends on scene structure
   ```
2. Or add to Main.gd as static functions
3. Use throughout activity scripts for consistency

### 6. Character Node Removal

**Files**: All activity scene files and completion screen

**Overview**:
Remove all character nodes and related video player functionality from activity scenes and completion screen. Characters are no longer needed for the retro console aesthetic.

**Files to Update**:
- `scenes/FillInBlank.tscn` - Remove Character node
- `scenes/Flashcards.tscn` - Remove Character node
- `scenes/MemoryGame.tscn` - Remove Character node
- `scenes/MultipleChoice.tscn` - Remove Character node
- `scenes/SentenceGen.tscn` - Remove Character node
- `scenes/SynonymAntonym.tscn` - Remove Character node
- `scenes/WordMatching.tscn` - Remove Character node
- `scenes/Completion.tscn` - Remove Character nodes (all 5 characters)

**Script Files to Update**:
- `scripts/FillInBlank.gd` - Remove character/video player code
- `scripts/Flashcards.gd` - Remove character/video player code
- `scripts/MemoryGame.gd` - Remove character/video player code
- `scripts/MultipleChoice.gd` - Remove character/video player code
- `scripts/SynonymAntonym.gd` - Remove character/video player code
- `scripts/WordMatching.gd` - Remove character/video player code
- `scripts/SentenceGen.gd` - Remove character/video player code
- `scripts/Completion.gd` - Remove character creation code

**Implementation Details**:

**Step 1: Remove Character Nodes from Scene Files**
For each activity scene file:

1. **FillInBlank.tscn**:
   - Open in Godot editor
   - Locate `Character` node (Node2D type, child of root)
   - Right-click → Delete
   - Save scene

2. **Flashcards.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

3. **MemoryGame.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

4. **MultipleChoice.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

5. **SentenceGen.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

6. **SynonymAntonym.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

7. **WordMatching.tscn**:
   - Open in Godot editor
   - Locate and delete `Character` node
   - Save scene

8. **Completion.tscn**:
   - Open in Godot editor
   - Locate all Character container nodes:
     - `CatContainer`
     - `DogContainer`
     - `RabbitContainer`
     - `FoxContainer`
     - `BirdContainer`
   - Delete all character container nodes and their children
   - Save scene

**Step 2: Remove Character Variables from Scripts**
For each activity script:

1. **Open script file** (e.g., `FillInBlank.gd`)
2. **Locate variable declarations** at top of file
3. **Remove these lines**:
   ```gdscript
   var fox_image: Sprite2D
   var video_player: VideoStreamPlayer
   var character_visible: bool
   ```
4. **Save file**

**Step 3: Remove Character Initialization Code**
For each activity script:

1. **Locate `_ready()` function**
2. **Find and remove**:
   ```gdscript
   # Remove all of this:
   # Create fox image from fox.png
   fox_image = Sprite2D.new()
   fox_image.name = "FoxImage"
   var texture = load("res://assets/fox.png")
   if texture:
       fox_image.texture = texture
       fox_image.scale = Vector2(0.5, 0.5)
   $Character.add_child(fox_image)
   
   # Create video player for fox animations
   video_player = VideoStreamPlayer.new()
   video_player.name = "VideoPlayer"
   video_player.size = Vector2(200, 200)
   video_player.position = $Character.position - Vector2(100, 100)
   video_player.visible = false
   add_child(video_player)
   video_player.finished.connect(_on_video_finished)
   ```
3. **Save file**

**Step 4: Remove Character Animation Functions**
For each activity script:

1. **Search for character animation functions**:
   - `_play_fox_celebration()` or similar
   - `_play_fox_sympathy()` or similar
   - `_on_video_finished()`
2. **Delete entire function definitions**
3. **Find function calls** to these functions:
   - Search for `_play_fox_celebration()`
   - Search for `_play_fox_sympathy()`
   - Remove the function calls
4. **Example locations**:
   - In answer feedback functions (correct/incorrect handlers)
   - Remove calls like: `_play_fox_celebration()` or `_play_bird_celebration()`
5. **Save file**

**Step 5: Update Completion.gd Specifically**
1. **Open `scripts/Completion.gd`**
2. **Remove `_create_characters()` function**:
   - Locate entire function
   - Delete function and all its code
3. **Remove character creation from `_ready()`**:
   - Find call to `_create_characters()`
   - Remove the call
4. **Remove CharacterHelper import** (if no longer used):
   ```gdscript
   # Remove this line if CharacterHelper not used elsewhere:
   const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
   ```
5. **Remove character container references**:
   - Any code referencing character containers should be removed
6. **Save file**

**Step 6: Clean Up Unused Code**
For each script:

1. **Search for remaining character references**:
   - Search for "Character", "fox", "video_player", "character_visible"
   - Remove any remaining references
2. **Remove unused imports**:
   - If CharacterHelper is imported but not used, remove import
   - Check for other unused imports
3. **Remove character-related comments**:
   - Search for comments mentioning characters
   - Remove or update comments
4. **Save all files**

**Step 7: Verify Removal**
1. **Open each scene in Godot editor**
2. **Verify Character node is gone**:
   - Check scene tree
   - No Character node should exist
3. **Run each activity**:
   - Verify no errors about missing Character node
   - Verify no errors about missing video_player
   - Verify activities function correctly without characters
4. **Check console for errors**:
   - No "Node not found" errors
   - No "null instance" errors related to characters

**Step 8: Test All Activities**
1. **Run Main scene**
2. **Navigate through all activities**:
   - Start game
   - Complete each activity type
   - Verify no character-related errors
   - Verify gameplay works correctly
3. **Test Completion screen**:
   - Complete all activities
   - Verify completion screen displays correctly
   - Verify no character-related errors

**Note**: CharacterHelper.gd can remain in the codebase but will not be used. It may be removed in a future cleanup phase.

### 7. Main Menu Transformation

**File**: `scenes/Main.tscn`

**Menu Styling**:
- Retro game menu appearance
- Sharp, pixelated buttons
- High-contrast text
- Optional: Add menu cursor/selector effect
- Position within console screen area

**Title Styling**:
- Pixelated or retro-styled title
- High contrast
- Sharp shadows
- Consider adding decorative borders or frames

**Implementation Details**:

**Step 1: Update Main.tscn Scene Structure**
1. **Open `scenes/Main.tscn` in Godot editor**
2. **Verify MenuContainer is child of ConsoleScreenArea**:
   - If not, drag MenuContainer to be child of ConsoleScreenArea
   - MenuContainer should be: `Main → ConsoleBezel → ConsoleScreenArea → MenuContainer`
3. **Verify VBoxContainer structure**:
   - VBoxContainer should be child of MenuContainer
   - Contains TitleLabel and StartButton

**Step 2: Update TitleLabel Styling**
1. **Select TitleLabel node** in scene tree
2. **Update font color**:
   - In Inspector, find `Theme Overrides → Colors → Font Color`
   - Change from: `Color(0.545, 0.361, 0.965, 1)` (modern purple)
   - To: `Color(0, 1, 1, 1)` (retro cyan #00ffff)
   - Or edit in .tscn file:
     ```
     theme_override_colors/font_color = Color(0, 1, 1, 1)
     ```
3. **Update font**:
   - Font will automatically use pixel font from theme (after theme update)
   - Or set theme override if needed
4. **Update font size**:
   - Current: 56px (already multiple of 8, keep or adjust to 48px)
   - In Inspector or .tscn:
     ```
     theme_override_font_sizes/font_size = 48  # Or keep 56
     ```
5. **Update shadow**:
   - In Inspector, find `Theme Overrides → Colors → Font Shadow Color`
   - Set to: `Color(0, 0, 0, 1)` (black)
   - Update shadow offset:
     ```
     theme_override_constants/shadow_offset_x = 2
     theme_override_constants/shadow_offset_y = 2
     ```
   - Sharp shadow (not soft)

**Step 3: Update StartButton**
1. **Select StartButton node**
2. **Verify button uses theme**:
   - Button will automatically use updated retro theme styles
   - No manual overrides needed (unless specific styling required)
3. **Verify button position**:
   - Button should be centered within MenuContainer
   - MenuContainer should be centered within ConsoleScreenArea
   - Test that button appears within console screen bounds

**Step 4: Update MenuContainer Layout**
1. **Select MenuContainer node**
2. **Verify anchors and positioning**:
   - Should use anchors to center within ConsoleScreenArea
   - Or use CenterContainer for automatic centering
3. **Update VBoxContainer**:
   - Verify VBoxContainer is centered
   - Adjust separation if needed:
     ```
     theme_override_constants/separation = 40  # Or appropriate spacing
     ```

**Step 5: Add Optional Menu Cursor Effect (Optional)**
1. **Create menu cursor indicator**:
   - Add `ColorRect` or `Label` node as child of VBoxContainer
   - Position next to StartButton
   - Use retro symbol: ">" or "▶" or "*"
   - Color: Retro cyan or yellow
   - Animate position for selection effect (if multiple menu items added later)

**Step 6: Test Main Menu**
1. **Run Main scene**
2. **Verify**:
   - Title displays with retro cyan color
   - Title uses pixel font
   - Title has sharp black shadow
   - StartButton has retro styling (sharp corners, retro colors)
   - All elements fit within console screen area
   - Menu is centered in console screen
3. **Test button interaction**:
   - Hover over StartButton
   - Verify hover state uses retro colors
   - Click button, verify press animation works

### 8. Modal System Update

**File**: `scenes/Modal.tscn`

**Modal Styling**:
- Sharp corners (0-2px radius)
- High-contrast borders
- Dark background with bright border
- Remove soft shadows
- Position within console screen area
- Optional: Add pixelated frame decoration

**Implementation Details**:

**Step 1: Update Modal.tscn Scene Structure**
1. **Open `scenes/Modal.tscn` in Godot editor**
2. **Verify modal structure**:
   - Root: `Modal` (Control)
   - Child: `Overlay` (ColorRect)
   - Child: `CenterContainer` (CenterContainer)
   - Child of CenterContainer: `ModalPanel` (PanelContainer)

**Step 2: Update ModalPanel Styling**
1. **Select ModalPanel node**
2. **Verify panel uses theme**:
   - PanelContainer will automatically use updated `panel_modal` style from theme
   - Will get sharp corners (2px) and retro colors automatically
3. **Update panel size if needed**:
   - Current: `custom_minimum_size = Vector2(600, 0)`
   - Ensure size fits within console screen area
   - May need to reduce to: `Vector2(550, 0)` or adjust based on console screen width
4. **Verify panel positioning**:
   - CenterContainer will center modal within parent
   - Parent should be console screen area (not full viewport)
   - Modal will automatically center within console screen

**Step 3: Update Overlay**
1. **Select Overlay ColorRect node**
2. **Verify overlay covers console screen**:
   - Overlay should cover entire parent (console screen area)
   - Current color: `Color(0, 0, 0, 0.8)` (80% opacity black)
   - Keep as-is or adjust opacity if needed
3. **Verify overlay positioning**:
   - Should use Full Rect anchors
   - Will cover console screen area when modal is shown

**Step 4: Update Text Elements**
1. **Select TitleLabel node**
2. **Verify font and colors**:
   - Font will use pixel font from theme (after theme update)
   - Font color will use theme default (white) or verify override
   - Current size: 32px (multiple of 8, good)
3. **Select BodyLabel (RichTextLabel) node**
4. **Verify RichTextLabel settings**:
   - BBCode enabled: `bbcode_enabled = true` (keep)
   - Font will use pixel font from theme
   - Default color will use retro white (after theme update)
   - Current size: 18px (adjust to 16px or 20px for pixel aesthetic)

**Step 5: Update ActionButton**
1. **Select ActionButton node**
2. **Verify button styling**:
   - Button will automatically use updated retro theme
   - Sharp corners, retro colors, high-contrast borders
   - No manual overrides needed
3. **Verify button size**:
   - Current: `custom_minimum_size = Vector2(150, 60)`
   - Size is appropriate, keep as-is

**Step 6: Update Modal.gd Script (If Needed)**
1. **Open `scripts/Modal.gd`**
2. **Verify animation code**:
   - Entrance/exit animations should work with retro styling
   - No changes needed to animation code
3. **Test modal animations**:
   - Verify scale animations work correctly
   - Verify fade animations work correctly

**Step 7: Test Modal Display**
1. **Run Main scene**
2. **Trigger modal** (click Start button)
3. **Verify**:
   - Modal appears centered in console screen area
   - Modal has sharp corners (2px radius)
   - Modal has high-contrast border (yellow from theme)
   - Text uses pixel font and retro white color
   - Overlay covers console screen area
   - Modal fits within console screen bounds
   - Button has retro styling
4. **Test modal interactions**:
   - Click action button
   - Verify modal closes correctly
   - Verify animations work smoothly

### 9. Color Constants Update

**File**: `scripts/VocabZooColors.gd`

Update color constants to match retro palette:
- Replace modern purple/pink gradients with retro color pairs
- Update background colors
- Update semantic colors (success, error, warning) to retro equivalents
- Remove or update gradient functions to use retro color combinations

**Implementation Details**:
1. Update PRIMARY colors:
   ```gdscript
   const PRIMARY_PURPLE = Color("#ff00ff")  # Retro magenta
   const PRIMARY_BLUE = Color("#0066ff")     # Retro blue
   const PRIMARY_PINK = Color("#ff00ff")     # Same as purple (retro)
   const PRIMARY_GREEN = Color("#00ff00")    # Retro green
   ```
2. Update secondary colors:
   ```gdscript
   const ORANGE = Color("#ff6600")           # Retro orange
   const YELLOW = Color("#ffff00")           # Retro yellow
   const CYAN = Color("#00ffff")             # Retro cyan
   const LIME = Color("#00ff00")             # Same as green
   ```
3. Update background colors:
   ```gdscript
   const DARK_BASE = Color("#0a0a0a")        # Very dark gray
   const LIGHT_BASE = Color("#ffffff")       # White for high contrast
   const CARD_BACKGROUND = Color("#1a1a1a")  # Dark gray
   const SURFACE = Color("#2a2a2a")          # Slightly lighter gray
   ```
4. Update semantic colors:
   ```gdscript
   const SUCCESS = Color("#00ff00")          # Retro green
   const ERROR = Color("#ff0000")            # Retro red
   const WARNING = Color("#ffff00")          # Retro yellow
   const INFO = Color("#00ffff")             # Retro cyan
   ```
5. Update gradient functions to use retro color pairs:
   ```gdscript
   static func get_purple_pink_gradient() -> Gradient:
       var gradient = Gradient.new()
       gradient.colors = [Color("#ff00ff"), Color("#ff00ff")]  # Or use cyan-blue
       return gradient
   ```

### 10. Remove Obsolete Styles

**File**: `assets/vocab_zoo_theme.tres`

Remove or replace styles that don't fit retro aesthetic:
- Soft shadows (replace with hard shadows or remove)
- Large corner radius styles (reduce to 0-2px)
- Gradient backgrounds (replace with solid colors)
- Glow effects (remove)
- Modern color schemes (replace with retro palette)

**Implementation Details**:

**Step 1: Review Theme File Structure**
1. **Open `assets/vocab_zoo_theme.tres` in text editor**
2. **Identify all StyleBoxFlat sub-resources**:
   - Search for `[sub_resource type="StyleBoxFlat"`
   - List all sub-resource IDs
   - Note which styles are referenced in [resource] section

**Step 2: Update Each StyleBoxFlat Sub-Resource**
For each StyleBoxFlat sub-resource found:

1. **Locate the sub-resource** (e.g., `[sub_resource type="StyleBoxFlat" id="button_normal"]`)
2. **Update corner_radius**:
   - Find all `corner_radius_*` properties
   - Change all values to 0, 1, or 2 (prefer 2 for slight rounding)
   - Example:
     ```
     corner_radius_top_left = 2
     corner_radius_top_right = 2
     corner_radius_bottom_right = 2
     corner_radius_bottom_left = 2
     ```
3. **Update shadow properties**:
   - Find `shadow_size` property
   - Set to 0 (remove shadow) or keep very small (2-4) for hard shadow
   - Find `shadow_offset` property
   - Set to `Vector2(0, 0)` or small offset for hard shadow
   - Find `shadow_color` property
   - Set to `Color(0, 0, 0, 0.3)` or remove entirely
4. **Update colors** (if not already updated in Step 2-8 of Theme File Overhaul):
   - Update `bg_color` to retro palette colors
   - Update `border_color` to high-contrast colors
5. **Remove glow effects**:
   - Check for any glow-related properties
   - Remove or set to 0/transparent

**Step 3: Verify Style References**
1. **Check [resource] section**:
   - Verify all referenced styles exist
   - Ensure no broken references
2. **Check for unused styles**:
   - Identify styles not referenced in [resource] section
   - Decide: keep for future use or remove
   - If removing, delete entire sub-resource block

**Step 4: Remove Unused Style Resources (Optional)**
1. **Identify unused sub-resources**:
   - Compare sub-resource IDs with [resource] references
   - Note which are not used
2. **Remove unused sub-resources**:
   - Delete entire `[sub_resource type="StyleBoxFlat" id="..."]` block
   - Be careful not to delete styles that are referenced
3. **Update load_steps count**:
   - Count remaining sub-resources
   - Update `[gd_resource type="Theme" load_steps=X format=3]` at top of file
   - X = number of ExtResources + number of SubResources + 1

**Step 5: Final Verification**
1. **Save theme file**
2. **Open project in Godot**
3. **Check for errors**:
   - No syntax errors
   - No missing resource references
   - All styles load correctly
4. **Test theme application**:
   - Create test scene with buttons, panels, labels
   - Verify all use retro styling
   - Verify sharp corners, retro colors, high-contrast borders

### 11. Runtime-Created UI Elements

**Files**: Multiple script files create UI elements programmatically

**Elements to Update**:
- **Main.gd**: Toast notifications (`Label.new()`)
- **FillInBlank.gd**: Dynamic labels (`sentence_label`, `info_label`, `word_label`)
- **MemoryGame.gd**: Dynamic buttons (`flashcard_button`)
- **Completion.gd**: Flash effects (`ColorRect.new()`)

**Implementation Details**:

**Main.gd - Toast Notifications**:

**Step 1: Update _show_error_toast() Function**
1. **Open `scripts/Main.gd`**
2. **Locate `_show_error_toast()` function** (around line 120)
3. **Update function**:
   ```gdscript
   func _show_error_toast(message: String) -> void:
       # Create toast label
       var toast = Label.new()
       toast.text = message
       toast.add_theme_color_override("font_color", Colors.LIGHT_BASE)  # White from updated Colors
       toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
       
       # Position within console screen area
       var console_screen_pos = get_console_screen_position()  # Helper from Main.gd
       var console_screen_size = get_console_screen_size()
       toast.position = Vector2(
           console_screen_pos.x + console_screen_size.x / 2 - 150, 
           console_screen_pos.y + console_screen_size.y - 100
       )
       toast.size = Vector2(300, 50)
       
       # Add to scene (add to ConsoleScreenArea or Main, depending on structure)
       add_child(toast)
       
       # Fade in, wait, fade out, remove
       toast.modulate.a = 0
       var tween = create_tween()
       tween.tween_property(toast, "modulate:a", 1.0, 0.3)
       tween.tween_interval(2.0)
       tween.tween_property(toast, "modulate:a", 0.0, 0.3)
       tween.tween_callback(toast.queue_free)
   ```
4. **Save file**

**FillInBlank.gd - Dynamic Labels**:

**Step 1: Update Sentence Label**
1. **Open `scripts/FillInBlank.gd`**
2. **Locate `sentence_label` creation** (around line 103)
3. **Update color override**:
   ```gdscript
   sentence_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)  # White
   ```
4. **Verify font size** (should already be set, verify is appropriate)

**Step 2: Update Info Label**
1. **Locate `info_label` creation** (around line 115)
2. **Update color override**:
   ```gdscript
   info_label.add_theme_color_override("font_color", Colors.WARNING)  # Retro yellow
   ```
3. **Verify info_color variable** (if used, ensure it uses retro colors)

**Step 3: Update Word Label (on ships)**
1. **Locate word label creation in `_create_word_ships()`** (around line 726)
2. **Update color override**:
   ```gdscript
   word_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)  # White
   ```
3. **Save file**

**MemoryGame.gd - Dynamic Buttons**:

**Step 1: Update Flashcard Button**
1. **Open `scripts/MemoryGame.gd`**
2. **Locate flashcard button creation** (around line 68-81)
3. **Update font color**:
   ```gdscript
   # Change from:
   flashcard_button.add_theme_color_override("font_color", Colors.DARK_BASE)
   # To:
   flashcard_button.add_theme_color_override("font_color", Colors.LIGHT_BASE)  # White for contrast
   ```
4. **Verify button uses retro theme styles**:
   - Button will automatically use updated theme
   - Verify stylebox overrides use retro colors
5. **Save file**

**Completion.gd - Flash Effects**:

**Step 1: Update Flash ColorRect**
1. **Open `scripts/Completion.gd`**
2. **Locate flash creation** (around line 69)
3. **Update flash color**:
   ```gdscript
   # Option 1: Keep white flash
   flash.color = Color(1, 1, 1, 0.8)  # White flash
   
   # Option 2: Use retro cyan flash
   flash.color = Color(0, 1, 1, 0.8)  # Retro cyan flash
   ```
4. **Recommendation**: Use retro cyan for more retro feel
5. **Save file**

### 12. Hardcoded Colors in Scripts

**Files**: Multiple scripts have hardcoded `Color()` calls

**Files to Update**:
- `scripts/FillInBlank.gd`: Spaceship graphics colors
- `scripts/CharacterHelper.gd`: Character creation colors
- `scripts/Completion.gd`: Flash effect color

**Implementation Details**:

**FillInBlank.gd - Spaceship Colors**:

**Step 1: Update Hull Color**
1. **Open `scripts/FillInBlank.gd`**
2. **Locate `_create_spaceship()` function** (around line 600-700)
3. **Find hull ColorRect creation**:
   ```gdscript
   var hull = ColorRect.new()
   hull.size = Vector2(70, 35)
   hull.position = Vector2(25, 20)
   ```
4. **Update hull color**:
   ```gdscript
   hull.color = Color(0.2, 0.2, 0.4, 1.0)  # Dark blue-gray (retro)
   ```
   - Replace: `Color(0.4, 0.45, 0.5, 1.0)` (metallic gray)
   - With: `Color(0.2, 0.2, 0.4, 1.0)` (dark blue-gray)

**Step 2: Update Cockpit Color**
1. **Locate cockpit ColorRect creation**
2. **Update cockpit color**:
   ```gdscript
   cockpit.color = Color(0.1, 0.1, 0.3, 0.8)  # Darker blue
   ```
   - Replace: `Color(0.2, 0.25, 0.3, 0.8)`
   - With: `Color(0.1, 0.1, 0.3, 0.8)`

**Step 3: Update Wing Colors**
1. **Locate left_wing and right_wing ColorRect creation**
2. **Update wing colors**:
   ```gdscript
   left_wing.color = Color(0.15, 0.15, 0.35, 1.0)  # Slightly different shade
   right_wing.color = Color(0.15, 0.15, 0.35, 1.0)
   ```

**Step 4: Verify Engine Colors**
1. **Locate engine ColorRect creation**
2. **Verify engine colors are retro cyan**:
   ```gdscript
   left_engine_glow.color = Color(0.0, 1.0, 1.0, 0.4)  # Retro cyan glow
   left_engine.color = Color(0.0, 0.8, 1.0, 1.0)  # Bright cyan engine
   ```
   - Keep as-is (already retro appropriate)

**Step 5: Verify Bullet Colors**
1. **Locate bullet ColorRect creation**
2. **Verify bullets are retro cyan**:
   ```gdscript
   bullet.color = Color(0.0, 1.0, 1.0, 1.0)  # Retro cyan bullets
   ```
   - Keep as-is (already retro appropriate)

**Step 6: Update Explosion Colors (If Needed)**
1. **Locate explosion particle/ColorRect creation**
2. **Update to retro colors**:
   ```gdscript
   # Use retro yellow/orange for explosions
   explosion.color = Color(1.0, 0.8, 0.0, 1.0)  # Retro yellow-orange
   ```
3. **Save file**

**CharacterHelper.gd - Character Colors**:

**Step 1: Update StyleBoxFlat Corner Radius**
1. **Open `scripts/CharacterHelper.gd`**
2. **Locate body StyleBoxFlat creation** (in `create_body()` function)
3. **Update corner radius**:
   ```gdscript
   body_style.corner_radius_top_left = 2  # Instead of 20
   body_style.corner_radius_top_right = 2
   body_style.corner_radius_bottom_left = 2
   body_style.corner_radius_bottom_right = 2
   ```

**Step 2: Update Head StyleBoxFlat Corner Radius**
1. **Locate head StyleBoxFlat creation** (in `create_head()` function)
2. **Update corner radius** (keep somewhat rounded for circular heads):
   ```gdscript
   # Option 1: Keep circular (50px radius)
   head_style.corner_radius_top_left = 50
   # ... (all corners 50)
   
   # Option 2: Make less rounded (more retro)
   head_style.corner_radius_top_left = 30  # Instead of 50
   head_style.corner_radius_top_right = 30
   head_style.corner_radius_bottom_left = 30
   head_style.corner_radius_bottom_right = 30
   ```
3. **Recommendation**: Keep circular (50px) for heads, but update body to 2px

**Step 3: Verify Border Colors**
1. **Locate border ColorRect creation**
2. **Verify borders use `Color.BLACK`**:
   ```gdscript
   border.color = Color.BLACK  # Keep black borders (high contrast, retro appropriate)
   ```
   - Keep as-is (appropriate for retro)

**Step 4: Verify Character Color Parameters**
1. **Review functions that accept color parameters**:
   - `create_body(color)`
   - `create_head(color)`
   - Ensure colors passed match retro palette
2. **Save file**

**Completion.gd - Flash Color**:

**Step 1: Update Flash ColorRect**
1. **Open `scripts/Completion.gd`**
2. **Locate flash ColorRect creation** (around line 69)
3. **Update flash color**:
   ```gdscript
   # Option 1: Keep white flash
   flash.color = Color(1, 1, 1, 0.8)  # White flash
   
   # Option 2: Use retro cyan flash (recommended)
   flash.color = Color(0, 1, 1, 0.8)  # Retro cyan flash
   ```
4. **Recommendation**: Use retro cyan for more retro feel
5. **Save file**

### 13. Theme Override Calls in Scripts

**Files**: Scripts use `add_theme_color_override()` with old color constants

**Files to Update**:
- `scripts/FillInBlank.gd`
- `scripts/MultipleChoice.gd`
- `scripts/WordMatching.gd`
- `scripts/SynonymAntonym.gd`
- `scripts/MemoryGame.gd`

**Implementation Details**:

**Step 1: Verify Color Constants Are Updated**
1. **Ensure `VocabZooColors.gd` has been updated** (see Section 9)
2. **Verify color constants**:
   - `Colors.LIGHT_BASE` = `Color("#ffffff")` (white) ✓
   - `Colors.SUCCESS` = `Color("#00ff00")` (retro green) ✓
   - `Colors.ERROR` = `Color("#ff0000")` (retro red) ✓
   - `Colors.WARNING` = `Color("#ffff00")` (retro yellow) ✓
   - `Colors.DARK_BASE` = `Color("#0a0a0a")` (very dark) ✓

**Step 2: Update FillInBlank.gd**
1. **Open `scripts/FillInBlank.gd`**
2. **Search for `add_theme_color_override` calls**
3. **Verify all use updated color constants**:
   - `Colors.LIGHT_BASE` for text (white) ✓
   - `Colors.WARNING` for info labels (yellow) ✓
   - No changes needed if already using Colors constants

**Step 3: Update MultipleChoice.gd**
1. **Open `scripts/MultipleChoice.gd`**
2. **Search for `add_theme_color_override` calls**
3. **Verify feedback colors**:
   - Correct answers: `Colors.SUCCESS` (green) ✓
   - Wrong answers: `Colors.ERROR` (red) ✓
   - No changes needed if already using Colors constants

**Step 4: Update WordMatching.gd**
1. **Open `scripts/WordMatching.gd`**
2. **Search for `add_theme_color_override` calls**
3. **Verify feedback colors**:
   - Correct matches: `Colors.SUCCESS` (green) ✓
   - Wrong matches: `Colors.ERROR` (red) ✓
   - No changes needed if already using Colors constants

**Step 5: Update SynonymAntonym.gd**
1. **Open `scripts/SynonymAntonym.gd`**
2. **Search for `add_theme_color_override` calls**
3. **Verify feedback colors**:
   - Correct answers: `Colors.SUCCESS` (green) ✓
   - Wrong answers: `Colors.ERROR` (red) ✓
   - No changes needed if already using Colors constants

**Step 6: Update MemoryGame.gd**
1. **Open `scripts/MemoryGame.gd`**
2. **Locate flashcard button creation** (around line 68-81)
3. **Update font color**:
   ```gdscript
   # Change from:
   flashcard_button.add_theme_color_override("font_color", Colors.DARK_BASE)
   # To:
   flashcard_button.add_theme_color_override("font_color", Colors.LIGHT_BASE)  # White for contrast
   ```
4. **Verify button background colors**:
   - Matched cards: `Colors.SUCCESS` (green) ✓
   - No changes needed if already using Colors constants
5. **Save file**

**Step 7: Verify All Files**
1. **Search codebase for hardcoded color values**:
   - Search for `Color(0.973, 0.98, 0.988, 1)` (old light color)
   - Search for `Color(0.545, 0.361, 0.965, 1)` (old purple)
   - Replace any found with appropriate Colors constants
2. **Test all activities**:
   - Verify text is readable (white on dark backgrounds)
   - Verify feedback colors (green/red) are correct
   - Verify all UI elements use retro colors

### 14. Scene-Level Color Overrides

**Files**: All `.tscn` files have `theme_override_colors` that need updating

**Implementation Details**:

**Step 1: Update All Activity Scene Files**
For each activity scene file (FillInBlank.tscn, MultipleChoice.tscn, WordMatching.tscn, etc.):

1. **Open scene file in text editor or Godot editor**
2. **Search for `theme_override_colors/font_color`**
3. **Update all font color overrides**:
   ```gdscript
   # Replace:
   theme_override_colors/font_color = Color(0.973, 0.98, 0.988, 1)
   # With:
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White for high contrast
   ```
4. **Update all other color overrides**:
   - Search for `theme_override_colors/` properties
   - Update to retro palette colors as needed
5. **Save scene file**

**Step 2: Update Main.tscn**
1. **Open `scenes/Main.tscn`**
2. **Locate TitleLabel node**
3. **Update font color**:
   ```gdscript
   # Replace:
   theme_override_colors/font_color = Color(0.545, 0.361, 0.965, 1)
   # With:
   theme_override_colors/font_color = Color(0, 1, 1, 1)  # Retro cyan
   ```
4. **Update shadow color** (if present):
   ```gdscript
   theme_override_colors/font_shadow_color = Color(0, 0, 0, 1)  # Black shadow
   ```
5. **Save scene file**

**Step 3: Update Modal.tscn**
1. **Open `scenes/Modal.tscn`**
2. **Locate TitleLabel and BodyLabel nodes**
3. **Update font colors**:
   ```gdscript
   # TitleLabel:
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   
   # BodyLabel (RichTextLabel):
   # Will use theme default (white) after theme update
   ```
4. **Save scene file**

**Step 4: Update VocabularyError.tscn**
1. **Open `scenes/VocabularyError.tscn`**
2. **Locate ErrorIcon Label node**
3. **Update font color**:
   ```gdscript
   # Replace:
   theme_override_colors/font_color = Color(0.960784, 0.619608, 0.0431373, 1)
   # With:
   theme_override_colors/font_color = Color(1, 1, 0, 1)  # Retro yellow for warnings
   ```
4. **Locate ErrorTitle Label node**
5. **Update font color**:
   ```gdscript
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   ```
6. **Locate ErrorMessage Label node**
7. **Update font color**:
   ```gdscript
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   ```
8. **Locate HelpText Label node**
9. **Update font color and modulate**:
   ```gdscript
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   # Update modulate if needed (see Section 29)
   ```
10. **Save scene file**

**Step 5: Update Completion.tscn**
1. **Open `scenes/Completion.tscn`**
2. **Locate all Label nodes**
3. **Update font colors**:
   ```gdscript
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   ```
4. **Save scene file**

**Step 6: Update All Background ColorRects**
For each scene file:

1. **Locate Background ColorRect node**
2. **Update color property**:
   ```gdscript
   # Replace:
   color = Color(0, 0, 0, 1)
   # With console screen background:
   color = Color(0.04, 0.06, 0.1, 1)  # Dark blue-black for console screen
   ```
3. **Alternative**: Remove Background ColorRect entirely and let console screen provide background
4. **Save scene file**

**Step 7: Verify All Updates**
1. **Open project in Godot**
2. **Check for errors**:
   - No syntax errors in scene files
   - All color values are valid
3. **Test each scene**:
   - Run Main scene
   - Navigate through all activities
   - Verify all text is readable (white on dark)
   - Verify all colors match retro palette

### 15. Character Styling Update

**File**: `scripts/CharacterHelper.gd`

**Implementation Details**:

**Step 1: Update Body StyleBoxFlat Corner Radius**
1. **Open `scripts/CharacterHelper.gd`**
2. **Locate `create_body()` function**
3. **Find body StyleBoxFlat creation**:
   ```gdscript
   var body_style = StyleBoxFlat.new()
   body_style.bg_color = color
   ```
4. **Update corner radius**:
   ```gdscript
   # Replace:
   body_style.corner_radius_top_left = 20
   body_style.corner_radius_top_right = 20
   body_style.corner_radius_bottom_left = 20
   body_style.corner_radius_bottom_right = 20
   # With:
   body_style.corner_radius_top_left = 2  # Sharp corners
   body_style.corner_radius_top_right = 2
   body_style.corner_radius_bottom_left = 2
   body_style.corner_radius_bottom_right = 2
   ```

**Step 2: Update Head StyleBoxFlat Corner Radius**
1. **Locate `create_head()` function**
2. **Find head StyleBoxFlat creation**:
   ```gdscript
   var head_style = StyleBoxFlat.new()
   head_style.bg_color = color
   ```
3. **Update corner radius** (keep somewhat rounded for circular heads):
   ```gdscript
   # Option 1: Keep circular (50px radius) - recommended for heads
   head_style.corner_radius_top_left = 50
   head_style.corner_radius_top_right = 50
   head_style.corner_radius_bottom_left = 50
   head_style.corner_radius_bottom_right = 50
   
   # Option 2: Make less rounded (more retro)
   head_style.corner_radius_top_left = 30  # Less rounded, more retro
   head_style.corner_radius_top_right = 30
   head_style.corner_radius_bottom_left = 30
   head_style.corner_radius_bottom_right = 30
   ```
4. **Recommendation**: Keep circular (50px) for heads, but update body to 2px

**Step 3: Verify Border Colors**
1. **Locate border ColorRect creation** (in various character creation functions)
2. **Verify borders use `Color.BLACK`**:
   ```gdscript
   border.color = Color.BLACK  # Keep black borders (high contrast, retro appropriate)
   ```
   - Keep as-is (appropriate for retro)
   - Border width: 4px (keep as-is)

**Step 4: Verify Character Color Parameters**
1. **Review functions that accept color parameters**:
   - `create_body(color)`
   - `create_head(color)`
   - `create_limb(color)`
   - `create_ear(color)`
2. **Ensure colors passed match retro palette**:
   - Colors are passed as parameters, so caller must use retro colors
   - Verify callers use Colors constants (after Section 9 update)
3. **Save file**

**Note**: CharacterHelper.gd will not be used after character removal (Section 6), but updating it ensures consistency if it's ever used again.

### 16. Game Visual Element Updates

**File**: `scripts/FillInBlank.gd`

**Implementation Details**:

**Step 1: Update Spaceship Hull Color**
1. **Open `scripts/FillInBlank.gd`**
2. **Locate `_create_spaceship()` function** (around line 600-700)
3. **Find hull ColorRect creation**:
   ```gdscript
   var hull = ColorRect.new()
   hull.size = Vector2(70, 35)
   hull.position = Vector2(25, 20)
   ```
4. **Update hull color**:
   ```gdscript
   hull.color = Color(0.2, 0.2, 0.4, 1.0)  # Dark blue-gray (retro)
   ```
   - Replace: `Color(0.4, 0.45, 0.5, 1.0)` (metallic gray)
   - With: `Color(0.2, 0.2, 0.4, 1.0)` (dark blue-gray)

**Step 2: Update Cockpit Color**
1. **Locate cockpit ColorRect creation**
2. **Update cockpit color**:
   ```gdscript
   cockpit.color = Color(0.1, 0.1, 0.3, 0.8)  # Very dark blue
   ```
   - Replace: `Color(0.2, 0.25, 0.3, 0.8)`
   - With: `Color(0.1, 0.1, 0.3, 0.8)`

**Step 3: Update Wing Colors**
1. **Locate left_wing and right_wing ColorRect creation**
2. **Update wing colors**:
   ```gdscript
   left_wing.color = Color(0.15, 0.15, 0.35, 1.0)  # Slightly different shade
   right_wing.color = Color(0.15, 0.15, 0.35, 1.0)
   ```

**Step 4: Verify Engine Colors**
1. **Locate engine ColorRect creation**
2. **Verify engine colors are retro cyan**:
   ```gdscript
   left_engine_glow.color = Color(0.0, 1.0, 1.0, 0.4)  # Retro cyan glow
   left_engine.color = Color(0.0, 0.8, 1.0, 1.0)  # Bright cyan engine
   right_engine_glow.color = Color(0.0, 1.0, 1.0, 0.4)
   right_engine.color = Color(0.0, 0.8, 1.0, 1.0)
   ```
   - Keep as-is (already retro appropriate)

**Step 5: Verify Bullet Colors**
1. **Locate bullet ColorRect creation** (in `_create_bullet()` or similar)
2. **Verify bullets are retro cyan**:
   ```gdscript
   bullet.color = Color(0.0, 1.0, 1.0, 1.0)  # Retro cyan bullets
   ```
   - Keep as-is (already retro appropriate)

**Step 6: Update Explosion Colors**
1. **Locate explosion ColorRect or particle creation** (in `_create_explosion()` or similar)
2. **Update to retro colors**:
   ```gdscript
   # Option 1: Retro yellow-orange explosion
   explosion.color = Color(1.0, 0.8, 0.0, 1.0)  # Retro yellow-orange
   
   # Option 2: Retro red explosion
   explosion.color = Color(1.0, 0.0, 0.0, 1.0)  # Retro red
   
   # Option 3: Retro cyan explosion (matches bullets)
   explosion.color = Color(0.0, 1.0, 1.0, 1.0)  # Retro cyan
   ```
3. **Recommendation**: Use retro yellow-orange for explosions
4. **Save file**

### 17. Background ColorRect Updates

**Files**: All scene files have Background ColorRect nodes

**Implementation Details**:

**Step 1: Review Each Scene's Background**
For each scene file (FillInBlank.tscn, MultipleChoice.tscn, etc.):

1. **Open scene in Godot editor or text editor**
2. **Locate Background ColorRect node**
3. **Note current color**: `Color(0, 0, 0, 1)` (black)

**Step 2: Choose Approach**
**Option A: Update Background Colors** (if keeping Background nodes):
1. **Update Background ColorRect color**:
   ```gdscript
   # Replace:
   color = Color(0, 0, 0, 1)
   # With:
   color = Color(0.04, 0.06, 0.1, 1)  # Dark blue-black (console screen)
   ```
2. **Apply to all activity scenes**:
   - FillInBlank.tscn
   - MultipleChoice.tscn
   - WordMatching.tscn
   - SynonymAntonym.tscn
   - MemoryGame.tscn
   - SentenceGen.tscn
   - Flashcards.tscn
   - Completion.tscn
   - VocabularyError.tscn
3. **Save all scene files**

**Option B: Remove Background Nodes** (preferred - single source of truth):
1. **Open each scene in Godot editor**
2. **Select Background ColorRect node**
3. **Delete Background node**:
   - Right-click → Delete
   - Or select and press Delete key
4. **Apply to all activity scenes** (same list as above)
5. **Verify console screen area provides background**:
   - ConsoleScreenArea in Main.tscn has CRTEffectsLayer with console screen background
   - All activities will use this consistent background
6. **Save all scene files**

**Step 3: Verify Background Consistency**
1. **Run Main scene**
2. **Navigate through all activities**:
   - Verify background is consistent (console screen background)
   - Verify no black backgrounds appear
   - Verify all content is visible on background
3. **Test edge cases**:
   - Long text doesn't create visual issues
   - Buttons are visible on background
   - All UI elements have proper contrast

**Recommendation**: Use Option B (remove Background nodes) for consistency and easier maintenance.

### 18. StyleBox Creation Updates

**File**: `scripts/CharacterHelper.gd`

**Implementation Details**:

Update all StyleBoxFlat creation to use sharp corners:
```gdscript
# Current (rounded):
body_style.corner_radius_top_left = 20
# Updated (sharp):
body_style.corner_radius_top_left = 2

# For circular heads, reduce rounding:
head_style.corner_radius_top_left = 30  # Instead of 50
```

### 19. Animation Constants Update

**File**: `scripts/VocabZooConstants.gd`

**Overview**:
Update animation and style constants to match retro aesthetic - sharper, more immediate animations with minimal bounce.

**Implementation Details**:

1. **Border Radius Constants**:
   ```gdscript
   # Update to sharp corners for retro:
   const RADIUS_BUTTON = 2      # Instead of 16
   const RADIUS_CARD = 2          # Instead of 20
   const RADIUS_MODAL = 2       # Instead of 24
   const RADIUS_SMALL = 2       # Instead of 12
   const RADIUS_BADGE = 2       # Instead of 8
   ```

2. **Animation Easing Adjustments** (Optional - for more "snappy" retro feel):
   ```gdscript
   # Consider making animations less bouncy:
   # Keep TRANS_CUBIC for buttons (snappy)
   # Consider TRANS_QUART or TRANS_QUINT for more immediate feel
   # Reduce TRANS_BACK usage (less bouncy)
   ```

3. **Scale Values** (May need adjustment):
   ```gdscript
   # Keep existing scale values or make more subtle:
   const SCALE_HOVER = 1.03     # Instead of 1.05 (more subtle)
   const SCALE_BOUNCE = 1.02    # Instead of 1.05 (less bounce)
   ```

4. **Shadow Constants** (Update for harder shadows):
   ```gdscript
   # Reduce shadow sizes for retro (harder, less soft):
   const SHADOW_LEVEL_1_SIZE = 2    # Instead of 4
   const SHADOW_LEVEL_2_SIZE = 4    # Instead of 8
   const SHADOW_LEVEL_3_SIZE = 6   # Instead of 12
   const SHADOW_LEVEL_4_SIZE = 8   # Instead of 16
   ```

5. **Animation Timing** (May need to be snappier):
   ```gdscript
   # Consider slightly faster animations for retro feel:
   const DURATION_MICRO = 0.1       # Instead of 0.125
   const DURATION_UI = 0.2          # Instead of 0.25
   ```

**Note**: Test animations after changes to ensure they feel appropriate for retro aesthetic.

### 20. Button Style Reset Functions

**Files**: Scripts with `_reset_button_style()` functions

**Overview**:
Multiple scripts have functions that reset button styles by removing theme overrides. These rely on default theme styles, so ensure the default theme is retro-styled.

**Files with Reset Functions**:
- `scripts/WordMatching.gd` - `_reset_button_style()`
- `scripts/MultipleChoice.gd` - `_reset_button_style()`
- `scripts/SynonymAntonym.gd` - `_reset_button_style()`

**Implementation Details**:

1. **Verify Reset Functions Work Correctly**:
   - These functions call `remove_theme_stylebox_override()` and `remove_theme_color_override()`
   - After removal, buttons should fall back to default theme styles
   - Ensure default theme styles are retro (handled in Theme File Overhaul)

2. **No Code Changes Needed**:
   - Reset functions should work automatically once theme is updated
   - Test that buttons reset to retro styles after being overridden

3. **Testing**:
   - Test button reset after correct/incorrect answers
   - Verify buttons return to retro default styles
   - Ensure no visual glitches during reset

### 21. Explosion and Visual Effects

**File**: `scripts/FillInBlank.gd`

**Overview**:
Update explosion effects and other visual feedback to use retro colors and styling.

**Implementation Details**:

1. **Explosion ColorRects**:
   ```gdscript
   # Current uses Colors.SUCCESS (will be retro green after color update)
   explosion.color = Colors.SUCCESS  # Retro green (#00ff00)
   # Verify this works correctly with updated color constants
   ```

2. **Explosion Animation**:
   - Keep existing scale and fade animations
   - Colors will automatically use retro palette after VocabZooColors.gd update
   - Test explosion appearance with retro green

3. **Ship Explosion Animation**:
   ```gdscript
   # Ship explosion uses modulate for fade
   # Keep existing animation, colors will update automatically
   # Verify ship colors match retro palette (handled in section 16)
   ```

4. **Modulate Color Resets**:
   ```gdscript
   # Update Color.WHITE resets to ensure compatibility:
   ship.button.modulate = Color.WHITE  # Keep as-is, white is appropriate for retro
   ```

### 22. Animation Timing and Easing Adjustments

**Files**: Multiple script files using animations

**Overview**:
Review and potentially adjust animation timing and easing to be more "snappy" and less bouncy for retro feel.

**Implementation Details**:

1. **Scale Bounce Animations**:
   - Used in feedback labels: `Anim.create_scale_bounce()`
   - Consider if TRANS_BACK (bouncy) should be replaced with TRANS_CUBIC (snappier)
   - Test feedback animations feel appropriate for retro

2. **Floating/Entrance Animations**:
   - FillInBlank.gd has ship floating animations using TRANS_SINE
   - Entrance animations use TRANS_BACK (bouncy)
   - Consider making entrance animations less bouncy:
     ```gdscript
     # Option: Change TRANS_BACK to TRANS_CUBIC for less bounce
     entrance_tween.set_trans(Tween.TRANS_CUBIC)  # Instead of TRANS_BACK
     ```

3. **Button Press Animations**:
   - Uses TRANS_CUBIC (good for retro)
   - Keep existing timing, but verify feels snappy

4. **Modal Animations**:
   - Modal.gd uses TRANS_BACK for entrance
   - Consider making less bouncy for retro:
     ```gdscript
     # Option: Change to TRANS_CUBIC
     panel_tween.set_trans(Tween.TRANS_CUBIC)  # Instead of TRANS_BACK
     ```

5. **Completion Screen Animations**:
   - Uses TRANS_BACK for title bounce
   - Consider making less bouncy or keeping for celebration effect

**Note**: Test all animations after changes to ensure they feel appropriate. Some bounce may be acceptable for celebration/feedback moments.

### 23. Viewport and Display Settings

**File**: `project.godot`

**Overview**:
Review viewport settings to ensure they work well with console screen area constraints.

**Current Settings**:
```
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
```

**Implementation Details**:

1. **Viewport Size**:
   - Current 1280x720 is good for console screen area
   - Console screen area should be smaller (e.g., 960x640)
   - No changes needed to viewport size

2. **Stretch Mode**:
   - "canvas_items" mode is appropriate
   - Ensures UI scales correctly
   - No changes needed

3. **Considerations**:
   - Console screen area should be calculated relative to viewport
   - Ensure console screen maintains aspect ratio
   - Test on different screen sizes if possible

**No Code Changes Required**: Viewport settings are fine as-is.

### 24. Engine Glow and Pulsing Effects

**File**: `scripts/FillInBlank.gd`

**Overview**:
Update engine glow pulsing animations to use retro colors (already cyan, which is good).

**Implementation Details**:

1. **Engine Glow Colors**:
   ```gdscript
   # Already using retro cyan:
   left_engine_glow.color = Color(0.0, 1.0, 1.0, 0.4)  # Retro cyan - good!
   # Keep as-is, already retro appropriate
   ```

2. **Pulsing Animation**:
   - Uses color interpolation between base and bright
   - Animation timing is fine (0.8s loops)
   - Keep existing implementation

3. **No Changes Needed**:
   - Engine glows already use retro cyan color
   - Animation is appropriate for retro aesthetic

### 25. Shake Animations

**File**: `scripts/VocabZooConstants.gd` and usage in scripts

**Overview**:
Shake animations for error feedback should work fine with retro aesthetic.

**Implementation Details**:

1. **Shake Constants**:
   ```gdscript
   const SHAKE_DURATION = 0.4
   const SHAKE_MAGNITUDE = 8
   ```
   - These values are appropriate for retro
   - No changes needed

2. **Shake Usage**:
   - Used in FillInBlank.gd for wrong answer feedback
   - Animation is snappy and appropriate
   - Colors will update automatically with color constants

3. **No Changes Needed**: Shake animations work well for retro aesthetic.

### 26. Particle Constants

**File**: `scripts/VocabZooConstants.gd`

**Overview**:
Particle constants are defined but may not be actively used. If particles are used, ensure they use retro colors.

**Implementation Details**:

1. **Particle Constants**:
   ```gdscript
   const PARTICLE_COUNT_MIN = 10
   const PARTICLE_COUNT_MAX = 20
   const PARTICLE_LIFETIME = 1.0
   const PARTICLE_FADE_START = 0.7
   ```

2. **If Particles Are Used**:
   - Ensure particle colors use retro palette
   - Use Colors.SUCCESS, Colors.WARNING, etc. for particle colors
   - Keep particle count low for retro feel

3. **Search for Particle Usage**:
   - Check if Particle2D or similar nodes are used
   - Update particle colors if found
   - If not used, constants can remain for potential future use

### 27. Modulate Color Usage

**Files**: Multiple scripts use `modulate` for fade effects

**Overview**:
Review all modulate usage to ensure colors are appropriate for retro aesthetic.

**Implementation Details**:

1. **Modulate Alpha (Fade Effects)**:
   - Used extensively for fade in/out animations
   - No color changes needed, only alpha
   - Keep existing implementation

2. **Modulate Color (Tinting)**:
   - FillInBlank.gd uses `modulate = Color(1.0, 0.3, 0.3, 1.0)` for red tint
   - Update to retro red if needed:
     ```gdscript
     ship.button.modulate = Color(1.0, 0.0, 0.0, 1.0)  # Retro red
     ```

3. **Color.WHITE Resets**:
   - Multiple scripts reset to `Color.WHITE`
   - White is appropriate for retro (high contrast)
   - Keep as-is

4. **Review All Modulate Usage**:
   - Check FillInBlank.gd, Modal.gd, Completion.gd, Main.gd
   - Ensure any color modulation uses retro palette
   - Most modulate usage is for alpha (fade), which is fine

### 28. RichTextLabel Theme Colors

**File**: `assets/vocab_zoo_theme.tres`

**Overview**:
Update RichTextLabel default color in theme to match retro high-contrast palette.

**Current State**:
```
RichTextLabel/colors/default_color = Color(0.973, 0.98, 0.988, 1)  # Modern light color
```

**Implementation Details**:

1. **Update Default Color**:
   ```gdscript
   # In vocab_zoo_theme.tres, update:
   RichTextLabel/colors/default_color = Color(1, 1, 1, 1)  # White for high contrast
   ```

2. **Font Updates** (already covered in Typography section):
   - Ensure RichTextLabel uses pixel/retro font
   - Update font sizes to multiples of 8px if needed

3. **BBCode Styling**:
   - RichTextLabel is used in Modal.tscn with BBCode enabled
   - Main.gd uses `[center]` BBCode tags
   - No color/font BBCode tags found, but default color will apply to all text
   - Verify BBCode text renders correctly with retro colors

**Files Affected**:
- `assets/vocab_zoo_theme.tres` - Update RichTextLabel default_color
- `scenes/Modal.tscn` - Uses RichTextLabel with BBCode
- `scripts/Main.gd` - Uses BBCode in modal body text

### 29. VocabularyError Modulate and Styling

**File**: `scenes/VocabularyError.tscn`

**Overview**:
Review and update modulate opacity and color overrides in VocabularyError scene.

**Current Issues**:

1. **HelpText Modulate**:
   - Line 78: `modulate = Color(1, 1, 1, 0.7)` (70% opacity)
   - May need to be full opacity for retro high-contrast aesthetic

2. **Color Overrides**:
   - ErrorIcon: `Color(0.960784, 0.619608, 0.0431373, 1)` (orange) - needs retro yellow
   - ErrorTitle: `Color(0.972549, 0.980392, 0.988235, 1)` (light) - needs retro white
   - ErrorMessage: `Color(0.972549, 0.980392, 0.988235, 1)` (light) - needs retro white
   - HelpText: `Color(0.972549, 0.980392, 0.988235, 1)` (light) - needs retro white

3. **Background ColorRect**:
   - `Color(0, 0, 0, 1)` - needs console screen background color

**Implementation Details**:

1. **Update Color Overrides**:
   ```gdscript
   # ErrorIcon - retro yellow for warning
   theme_override_colors/font_color = Color(1, 1, 0, 1)  # Retro yellow
   
   # ErrorTitle - retro white
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   
   # ErrorMessage - retro white
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   
   # HelpText - retro white
   theme_override_colors/font_color = Color(1, 1, 1, 1)  # White
   ```

2. **Review Modulate Opacity**:
   ```gdscript
   # Option 1: Keep reduced opacity for subtle help text
   modulate = Color(1, 1, 1, 0.7)  # Keep as-is
   
   # Option 2: Full opacity for retro high-contrast
   modulate = Color(1, 1, 1, 1.0)  # Full opacity
   ```
   - Recommendation: Use full opacity (1.0) for retro high-contrast aesthetic

3. **Update Background**:
   ```gdscript
   # Background ColorRect
   color = Color(0.04, 0.06, 0.1, 1)  # Console screen background
   ```

### 30. BBCode Text Styling

**Files**: `scripts/Main.gd`, `scenes/Modal.tscn`

**Overview**:
Verify BBCode text styling works correctly with retro theme and colors.

**Current Usage**:

1. **Main.gd**:
   ```gdscript
   var body_text = "[center]You'll complete vocabulary activities to learn new words!\n\n"
   body_text += "Each activity will help you practice and remember.\n\n"
   body_text += "Ready to start? Let's go![/center]"
   ```
   - Uses `[center]` BBCode tag only
   - No color or font tags found

2. **Modal.tscn**:
   - RichTextLabel has `bbcode_enabled = true`
   - Uses default theme colors

**Implementation Details**:

1. **No Code Changes Needed** (if RichTextLabel theme is updated):
   - BBCode text will use RichTextLabel default_color from theme
   - After updating theme default_color to white, all BBCode text will be retro white
   - `[center]` tag will work correctly

2. **Verification**:
   - Test that BBCode text renders with retro white color
   - Ensure text is readable against retro backgrounds
   - Verify centering works correctly

3. **Future Considerations**:
   - If color BBCode tags are added later, ensure they use retro palette
   - Example: `[color=#00ffff]text[/color]` for retro cyan

### 31. Emoji Rendering Considerations

**Files**: Multiple scripts and scenes use emojis

**Overview**:
Review emoji usage and ensure they render appropriately with retro pixel fonts and aesthetic.

**Current Emoji Usage**:

1. **Feedback Messages**:
   - `scripts/MultipleChoice.gd`: "Correct! 🎉"
   - `scenes/MemoryGame.tscn`: "All Matched! 🎉"
   - `scenes/Completion.tscn`: "You Did It! 🌟"

2. **Modal Titles**:
   - `scripts/Main.gd`: "Welcome, Friend! 🎉"

3. **Error Icons**:
   - `scenes/VocabularyError.tscn`: "⚠️"

**Implementation Details**:

1. **Emoji Rendering with Pixel Fonts**:
   - Pixel fonts may not support emoji characters well
   - Emojis may render as missing character boxes or fallback to system font
   - Test emoji rendering with chosen pixel font

2. **Options**:

   **Option A: Keep Emojis** (if font supports):
   - Test that chosen pixel font supports emojis
   - If not supported, emojis will fallback to system font (may look inconsistent)
   - Acceptable if fallback is subtle

   **Option B: Replace with Text**:
   ```gdscript
   # Replace emojis with text alternatives:
   "Correct! [OK]"  # Instead of 🎉
   "You Did It! [SUCCESS]"  # Instead of 🌟
   "Warning!"  # Instead of ⚠️
   ```

   **Option C: Replace with Retro Symbols**:
   ```gdscript
   # Use ASCII/retro symbols:
   "Correct! ***"  # Asterisks for celebration
   "You Did It! !!!"  # Exclamation marks
   "[!]"  # ASCII warning symbol
   ```

   **Option D: Remove Emojis**:
   ```gdscript
   # Simply remove emojis:
   "Correct!"
   "You Did It!"
   "Warning"
   ```

3. **Recommendation**:
   - Test emoji rendering first
   - If pixel font doesn't support emojis well, use Option D (remove) or Option C (retro symbols)
   - Maintains consistent retro aesthetic

4. **Files to Update** (if removing/replacing emojis):
   - `scripts/Main.gd` - Modal title
   - `scripts/MultipleChoice.gd` - Feedback text
   - `scenes/MemoryGame.tscn` - Feedback text
   - `scenes/Completion.tscn` - Title text
   - `scenes/VocabularyError.tscn` - Error icon (consider ASCII alternative)

### 32. Project-Level Theme Reference

**File**: `project.godot`

**Overview**:
Verify project-level theme is correctly configured and will apply retro theme globally.

**Current Configuration**:
```
[gui]
theme/custom="res://assets/vocab_zoo_theme.tres"
```

**Implementation Details**:

1. **Verification**:
   - Current configuration is correct
   - Theme is set at project level, so all scenes inherit it
   - No changes needed to project.godot

2. **Theme Application**:
   - All scenes will automatically use updated retro theme
   - Individual scene overrides will still work (theme_override_*)
   - Runtime theme overrides will still work (add_theme_*_override)

3. **Testing**:
   - Verify theme applies to all new scenes
   - Ensure no scenes bypass the theme
   - Check that theme updates propagate correctly

**No Code Changes Required**: Project theme configuration is correct.

### 33. Additional Immersive Elements

**Optional Enhancements**:
- **Screen Power-On Effect**: Fade in with scanline effect on initial load
- **Static/Noise Texture**: Subtle screen noise overlay (very low opacity)
- **Screen Refresh Effect**: Subtle screen refresh flicker (optional, can be toggled)
- **Console Branding**: Add decorative text/logo in bezel area (e.g., "VOCAB CONSOLE" or similar)
- **Power Indicator**: Small LED indicator in bezel (can show activity state)
- **Button Sound Effects**: Retro-style button click sounds (separate from current sound system)

**Implementation Details**:

**Screen Power-On Effect**:
```gdscript
# In Main.gd _ready():
func _ready() -> void:
    # ... existing code ...
    _play_power_on_effect()

func _play_power_on_effect() -> void:
    var screen = $ConsoleScreenArea
    screen.modulate.a = 0
    var tween = create_tween()
    tween.tween_property(screen, "modulate:a", 1.0, 0.5)
    # Add scanline fade-in effect
```

**Console Branding**:
- Add Label node to ConsoleBezel
- Text: "VOCAB CONSOLE" or similar
- Use retro font, small size
- Position in bezel area (top or bottom)

**Power LED Indicator**:
- Add small ColorRect to ConsoleBezel
- Color: Retro green or red
- Position: Top corner of bezel
- Animate opacity for "active" state

## Implementation Order

1. **Phase 1: Console Frame & Screen Area**
   - Create console bezel structure in Main.tscn
   - Define console screen area constraints
   - Update Main.tscn layout
   - Update Main.gd to handle console screen positioning

2. **Phase 2: Color Constants Update**
   - Update VocabZooColors.gd with retro palette
   - Test that all color references work

3. **Phase 3: Theme Color & Style Overhaul**
   - Update vocab_zoo_theme.tres with retro colors
   - Replace button styles (sharp corners, high contrast)
   - Update panel styles
   - Update label/text styles
   - Update input styles
   - Remove obsolete modern styles

4. **Phase 4: Typography**
   - Source or configure pixel/retro fonts
   - Update font references in theme
   - Adjust font sizes for pixel aesthetic

5. **Phase 5: Scene Color Override Updates**
   - Update all theme_override_colors in .tscn files
   - Update Background ColorRect colors
   - Update Main.tscn title color

6. **Phase 6: Runtime UI Element Updates**
   - Update Main.gd toast notifications
   - Update FillInBlank.gd dynamic labels
   - Update MemoryGame.gd dynamic buttons
   - Update Completion.gd flash effects

7. **Phase 7: Script Color Updates**
   - Update hardcoded colors in FillInBlank.gd (spaceships)
   - Update CharacterHelper.gd (corner radius, verify colors)
   - Update Completion.gd flash color

8. **Phase 8: Theme Override Call Updates**
   - Verify all add_theme_color_override() calls use updated colors
   - Fix MemoryGame.gd font color contrast

9. **Phase 9: Character Styling Update**
   - Update CharacterHelper.gd StyleBox creation
   - Test character appearance

10. **Phase 10: Game Visual Element Updates**
    - Update FillInBlank.gd spaceship colors
    - Test game visuals

11. **Phase 11: Background Color Updates**
    - Update all Background ColorRects
    - Or remove and use console screen background

12. **Phase 12: CRT Effects**
    - Implement scanline overlay
    - Add screen curvature effect (if using shader)
    - Add phosphor glow effect
    - Test and tune effect intensity

13. **Phase 13: Character Node Removal**
    - Remove Character nodes from all activity scene files
    - Remove character/video player code from all activity scripts
    - Remove character creation from Completion.gd
    - Clean up unused character-related code

14. **Phase 14: Activity Scene Constraints**
    - Update all activity scenes to fit console screen area
    - Apply retro styling from updated theme
    - Test each activity for proper containment
    - Update scene scripts for console screen dimensions

15. **Phase 15: Animation Constants Update**
    - Update border radius constants in VocabZooConstants.gd
    - Update shadow constants for harder shadows
    - Adjust scale values for more subtle effects
    - Consider animation timing adjustments

16. **Phase 16: Animation Timing & Easing**
    - Review and adjust animation easing (less bouncy)
    - Update entrance animations to be snappier
    - Test all animations for retro feel

17. **Phase 17: Visual Effects Updates**
    - Verify explosion effects use retro colors
    - Update modulate color usage if needed
    - Test all visual feedback animations

18. **Phase 18: RichTextLabel and BBCode Updates**
    - Update RichTextLabel default color in theme
    - Verify BBCode text renders correctly with retro colors
    - Test modal body text appearance

19. **Phase 19: VocabularyError Styling**
    - Update all color overrides in VocabularyError.tscn
    - Review and update modulate opacity
    - Update background color

20. **Phase 20: Emoji Rendering Review**
    - Test emoji rendering with pixel font
    - Decide on emoji handling (keep, replace, or remove)
    - Update emoji usage if needed

21. **Phase 21: Menu & Modal Updates**
    - Update main menu styling
    - Update modal styling
    - Ensure retro aesthetic consistency

22. **Phase 22: Polish & Immersive Elements**
    - Add power-on effect
    - Add optional screen noise
    - Add console branding elements
    - Fine-tune all effects and styling

## Technical Considerations

### Performance
- CRT shader effects may impact performance - provide option to disable
- Scanline overlay should be lightweight (texture or simple shader)
- Screen effects should be subtle to avoid distraction

### Accessibility
- Maintain text readability despite retro aesthetic
- Ensure sufficient contrast ratios
- Consider option to disable screen effects for users sensitive to flicker

### Responsive Design
- Console screen area should scale appropriately on different viewport sizes
- Maintain aspect ratio of console screen
- Bezel should scale proportionally

## Files to Modify

### Primary Files
- `assets/vocab_zoo_theme.tres` - Complete style overhaul
- `scenes/Main.tscn` - Add console frame structure
- `scripts/VocabZooColors.gd` - Update color constants
- `scripts/Main.gd` - Update for console screen area, toast notifications

### Activity Scene Files (for constraint application, color updates, and character removal)
- `scenes/FillInBlank.tscn` - Color overrides, background, remove Character node
- `scenes/Flashcards.tscn` - Color overrides, background, remove Character node
- `scenes/MemoryGame.tscn` - Color overrides, background, remove Character node
- `scenes/MultipleChoice.tscn` - Color overrides, background, remove Character node
- `scenes/SentenceGen.tscn` - Color overrides, background, remove Character node
- `scenes/SynonymAntonym.tscn` - Color overrides, background, remove Character node
- `scenes/WordMatching.tscn` - Color overrides, background, remove Character node
- `scenes/Completion.tscn` - Color overrides, background, remove Character nodes (all 5)
- `scenes/VocabularyError.tscn` - Color overrides, background, modulate opacity review
- `scenes/Modal.tscn` - Color overrides

### Script Files (for runtime UI, colors, constraints, and character removal)
- `scripts/FillInBlank.gd` - Dynamic labels, hardcoded colors, spaceship colors, console screen constraints, character/video player removal
- `scripts/Flashcards.gd` - Console screen constraints, character/video player removal
- `scripts/MemoryGame.gd` - Dynamic buttons, theme overrides, console screen constraints, character/video player removal
- `scripts/MultipleChoice.gd` - Theme overrides, console screen constraints, character/video player removal
- `scripts/SynonymAntonym.gd` - Theme overrides, console screen constraints, character/video player removal
- `scripts/WordMatching.gd` - Theme overrides, console screen constraints, character/video player removal
- `scripts/SentenceGen.gd` - Console screen constraints, character/video player removal
- `scripts/Completion.gd` - Flash effects, console screen constraints, character creation removal
- `scripts/VocabZooConstants.gd` - Animation constants, border radius, shadow constants, scale values
- `scripts/CharacterHelper.gd` - StyleBox creation, corner radius (may not be needed after character removal)
- `scripts/VocabularyError.gd` - Console screen constraints (if needed)

## Success Criteria

- All activities fit within defined console screen area
- Visual aesthetic clearly evokes 80s/90s video game consoles
- CRT effects are visible but not distracting
- Retro color palette is consistently applied throughout
- Typography has pixelated/retro appearance
- Sharp corners and high-contrast borders throughout
- No modern UI elements (rounded corners, soft shadows, gradients) remain
- All runtime-created UI elements use retro styling
- All hardcoded colors replaced with retro palette
- All scene color overrides updated to retro palette
- All character nodes removed from activity and completion screens
- Animation constants updated for retro aesthetic
- Visual effects use retro colors and styling
- RichTextLabel theme colors updated for retro palette
- BBCode text renders correctly with retro styling
- Emoji rendering handled appropriately (kept, replaced, or removed)
- All modulate and opacity values reviewed for retro aesthetic
- Immersive experience that feels like playing on classic hardware

