extends Node
## VocabZoo Animation & Style Constants
## Reference script for all timing, sizing, and style values from the style guide

# Animation Durations (in seconds)
const DURATION_MICRO = 0.125  # Button presses, micro-interactions (0.1-0.15s)
const DURATION_UI = 0.25      # UI transitions, fades, scales (0.2-0.3s)
const DURATION_SCREEN = 0.35  # Screen transitions (0.3-0.4s)
const DURATION_CHARACTER = 0.5 # Character animations (0.4-0.6s)
const DURATION_IDLE = 3.0     # Idle loops (2-4s)

# Easing Constants (use with Tween.set_ease and Tween.set_trans)
const EASE_BUTTON = Tween.EASE_OUT
const TRANS_BUTTON = Tween.TRANS_CUBIC
const EASE_ENTRANCE = Tween.EASE_OUT
const EASE_EXIT = Tween.EASE_IN
const EASE_LOOP = Tween.EASE_IN_OUT

# Scale Values
const SCALE_HOVER = 1.05
const SCALE_HOVER_MAX = 1.08
const SCALE_PRESS = 0.95
const SCALE_BOUNCE = 1.05

# Border Radius (in pixels)
const RADIUS_BUTTON = 16
const RADIUS_CARD = 20
const RADIUS_MODAL = 24
const RADIUS_SMALL = 12
const RADIUS_BADGE = 8

# Spacing System (8px base unit)
const SPACING_TINY = 4
const SPACING_SMALL = 8
const SPACING_MEDIUM = 16
const SPACING_LARGE = 24
const SPACING_XLARGE = 32
const SPACING_XXLARGE = 48

# Font Sizes (in pixels)
const FONT_DISPLAY = 56      # 48-64px for titles
const FONT_H1 = 40           # 36-42px for main headers
const FONT_H2 = 30           # 28-32px for card titles
const FONT_H3 = 22           # 20-24px for subsections
const FONT_BODY_LARGE = 18   # 18-20px for important text
const FONT_BODY = 16         # 16px standard reading
const FONT_SMALL = 14        # 14px helper text

# Shadow/Elevation Levels (use with StyleBox or create CanvasLayer effects)
const SHADOW_LEVEL_1_OFFSET = Vector2(0, 2)
const SHADOW_LEVEL_1_SIZE = 4
const SHADOW_LEVEL_2_OFFSET = Vector2(0, 4)
const SHADOW_LEVEL_2_SIZE = 8
const SHADOW_LEVEL_3_OFFSET = Vector2(0, 8)
const SHADOW_LEVEL_3_SIZE = 12
const SHADOW_LEVEL_4_OFFSET = Vector2(0, 12)
const SHADOW_LEVEL_4_SIZE = 16

# Touch Target Sizes
const TOUCH_TARGET_MIN = Vector2(44, 44)
const TOUCH_TARGET_IDEAL = Vector2(56, 56)

# Character Animation Constants
const CHARACTER_SIZE_MIN = 200
const CHARACTER_SIZE_MAX = 300
const CHARACTER_EYE_SIZE_RATIO = 0.35  # Eyes should be 30-40% of head
const CHARACTER_BLINK_INTERVAL = 3.5   # Blink every 3-4 seconds
const TAIL_WIGGLE_DURATION = 2.0       # Tail wiggle cycle

# Particle Constants
const PARTICLE_COUNT_MIN = 10
const PARTICLE_COUNT_MAX = 20
const PARTICLE_LIFETIME = 1.0
const PARTICLE_FADE_START = 0.7  # Start fading at 70% of lifetime

# UI Feedback
const SHAKE_DURATION = 0.4
const SHAKE_MAGNITUDE = 8
const FLASH_DURATION = 0.1
const GLOW_RADIUS = 20

# Helper function to create a bounce tween
static func create_bounce_tween(node: Node, property: String, from_value, to_value, duration: float = DURATION_UI) -> Tween:
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, property, to_value, duration).from(from_value)
	return tween

# Helper function to create a scale bounce (common animation)
static func create_scale_bounce(node: Control, target_scale: float = 1.0, duration: float = DURATION_UI) -> Tween:
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", Vector2(target_scale, target_scale), duration)
	return tween

# Helper function to create hover scale effect
static func create_hover_scale(node: Control, hover_in: bool = true, duration: float = 0.2) -> Tween:
	var target_scale = SCALE_HOVER if hover_in else 1.0
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "scale", Vector2(target_scale, target_scale), duration)
	return tween

# Helper function for button press animation
static func animate_button_press(button: Control) -> void:
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	# Scale down
	tween.tween_property(button, "scale", Vector2(SCALE_PRESS, SCALE_PRESS), 0.1)
	# Bounce back with overshoot
	tween.tween_property(button, "scale", Vector2(SCALE_BOUNCE, SCALE_BOUNCE), 0.15)
	# Settle
	tween.tween_property(button, "scale", Vector2.ONE, 0.1)

# Helper function for shake animation (errors)
static func animate_shake(node: Control, duration: float = SHAKE_DURATION) -> void:
	var original_pos = node.position
	var tween = node.create_tween()
	var shake_count = 4
	var shake_interval = duration / (shake_count * 2)
	
	for i in shake_count:
		tween.tween_property(node, "position:x", original_pos.x + SHAKE_MAGNITUDE, shake_interval)
		tween.tween_property(node, "position:x", original_pos.x - SHAKE_MAGNITUDE, shake_interval)
	
	tween.tween_property(node, "position", original_pos, shake_interval)

