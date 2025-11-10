extends Node
## VocabZoo Color Palette
## Reference script for all colors defined in the style guide

# Primary Colors
const PRIMARY_PURPLE = Color("#39FF14")  # Sci-fi lime green (was purple)
const PRIMARY_BLUE = Color("#3B82F6")
const PRIMARY_PINK = Color("#EC4899")
const PRIMARY_GREEN = Color("#10B981")

# Secondary/Accent Colors
const ORANGE = Color("#F97316")
const YELLOW = Color("#FBBF24")
const CYAN = Color("#06B6D4")
const LIME = Color("#84CC16")

# Background Colors
const DARK_BASE = Color("#1E1B2E")
const LIGHT_BASE = Color("#F8FAFC")
const CARD_BACKGROUND = Color("#2D2640")
const SURFACE = Color("#3D3450")

# Semantic Colors
const SUCCESS = Color("#10B981")
const ERROR = Color("#EF4444")
const WARNING = Color("#F59E0B")
const INFO = Color("#3B82F6")

# Gradient Pairs (use with Gradient resource)
static func get_purple_pink_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = [PRIMARY_PURPLE, PRIMARY_PINK]
	return gradient

static func get_blue_cyan_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = [PRIMARY_BLUE, CYAN]
	return gradient

static func get_orange_yellow_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = [ORANGE, YELLOW]
	return gradient

static func get_green_cyan_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = [PRIMARY_GREEN, CYAN]
	return gradient

