extends Node
## CharacterHelper - Static functions for creating simple geometric character sprites
## Per style guide: 200-300px tall, 30-40% eye size, 4px outlines, round proportions

## Creates a cat character (purple)
## Returns Node2D with all character parts assembled
static func create_cat(parent: Node, center: Vector2, color: Color) -> Node2D:
	var character = Node2D.new()
	character.position = center
	parent.add_child(character)
	
	# Body (rectangle with rounded corners)
	var body = ColorRect.new()
	body.position = Vector2(-60, 20)
	body.size = Vector2(120, 80)
	body.color = color
	# Add rounded corners via theme override (Godot 4 approach)
	var body_style = StyleBoxFlat.new()
	body_style.bg_color = color
	body_style.corner_radius_top_left = 20
	body_style.corner_radius_top_right = 20
	body_style.corner_radius_bottom_left = 20
	body_style.corner_radius_bottom_right = 20
	body_style.border_width_left = 4
	body_style.border_width_top = 4
	body_style.border_width_right = 4
	body_style.border_width_bottom = 4
	body_style.border_color = Color.BLACK
	character.add_child(body)
	
	# Head (circle using ColorRect with full corner radius)
	var head = ColorRect.new()
	head.position = Vector2(-50, -80)
	head.size = Vector2(100, 100)
	head.color = color
	var head_style = StyleBoxFlat.new()
	head_style.bg_color = color
	head_style.corner_radius_top_left = 50
	head_style.corner_radius_top_right = 50
	head_style.corner_radius_bottom_left = 50
	head_style.corner_radius_bottom_right = 50
	head_style.border_width_left = 4
	head_style.border_width_top = 4
	head_style.border_width_right = 4
	head_style.border_width_bottom = 4
	head_style.border_color = Color.BLACK
	character.add_child(head)
	
	# Eyes (35% of head size = 35px diameter)
	var left_eye = ColorRect.new()
	left_eye.position = Vector2(-35, -60)
	left_eye.size = Vector2(20, 30)
	left_eye.color = Color.BLACK
	var eye_style = StyleBoxFlat.new()
	eye_style.bg_color = Color.BLACK
	eye_style.corner_radius_top_left = 10
	eye_style.corner_radius_top_right = 10
	eye_style.corner_radius_bottom_left = 10
	eye_style.corner_radius_bottom_right = 10
	character.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.position = Vector2(15, -60)
	right_eye.size = Vector2(20, 30)
	right_eye.color = Color.BLACK
	character.add_child(right_eye)
	
	# Ears (triangles using Polygon2D)
	var left_ear = Polygon2D.new()
	left_ear.polygon = PackedVector2Array([
		Vector2(-40, -80),
		Vector2(-30, -80),
		Vector2(-35, -110)
	])
	left_ear.color = color
	character.add_child(left_ear)
	
	var right_ear = Polygon2D.new()
	right_ear.polygon = PackedVector2Array([
		Vector2(30, -80),
		Vector2(40, -80),
		Vector2(35, -110)
	])
	right_ear.color = color
	character.add_child(right_ear)
	
	# Tail (separate Node2D for animation)
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(60, 40)
	character.add_child(tail)
	
	var tail_rect = ColorRect.new()
	tail_rect.position = Vector2(0, 0)
	tail_rect.size = Vector2(60, 15)
	tail_rect.color = color
	var tail_style = StyleBoxFlat.new()
	tail_style.bg_color = color
	tail_style.corner_radius_top_left = 8
	tail_style.corner_radius_top_right = 8
	tail_style.corner_radius_bottom_left = 8
	tail_style.corner_radius_bottom_right = 8
	tail_style.border_width_left = 4
	tail_style.border_width_top = 4
	tail_style.border_width_right = 4
	tail_style.border_width_bottom = 4
	tail_style.border_color = Color.BLACK
	tail.add_child(tail_rect)
	
	return character

## Creates a dog character (orange)
static func create_dog(parent: Node, center: Vector2, color: Color) -> Node2D:
	var character = Node2D.new()
	character.position = center
	parent.add_child(character)
	
	# Body
	var body = ColorRect.new()
	body.position = Vector2(-70, 20)
	body.size = Vector2(140, 90)
	body.color = color
	character.add_child(body)
	
	# Head (circle)
	var head = ColorRect.new()
	head.position = Vector2(-55, -90)
	head.size = Vector2(110, 110)
	head.color = color
	character.add_child(head)
	
	# Eyes (38px diameter, 35% of head)
	var left_eye = ColorRect.new()
	left_eye.position = Vector2(-40, -65)
	left_eye.size = Vector2(22, 32)
	left_eye.color = Color.BLACK
	character.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.position = Vector2(18, -65)
	right_eye.size = Vector2(22, 32)
	right_eye.color = Color.BLACK
	character.add_child(right_eye)
	
	# Floppy ears (rectangles)
	var left_ear = ColorRect.new()
	left_ear.position = Vector2(-65, -70)
	left_ear.size = Vector2(20, 40)
	left_ear.color = color.darkened(0.2)
	character.add_child(left_ear)
	
	var right_ear = ColorRect.new()
	right_ear.position = Vector2(45, -70)
	right_ear.size = Vector2(20, 40)
	right_ear.color = color.darkened(0.2)
	character.add_child(right_ear)
	
	# Tail (separate for animation)
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(70, 35)
	character.add_child(tail)
	
	var tail_rect = ColorRect.new()
	tail_rect.position = Vector2(0, 0)
	tail_rect.size = Vector2(70, 18)
	tail_rect.color = color
	tail.add_child(tail_rect)
	
	return character

## Creates a rabbit character (blue)
static func create_rabbit(parent: Node, center: Vector2, color: Color) -> Node2D:
	var character = Node2D.new()
	character.position = center
	parent.add_child(character)
	
	# Body
	var body = ColorRect.new()
	body.position = Vector2(-50, 20)
	body.size = Vector2(100, 80)
	body.color = color
	character.add_child(body)
	
	# Head (circle)
	var head = ColorRect.new()
	head.position = Vector2(-47, -75)
	head.size = Vector2(95, 95)
	head.color = color
	character.add_child(head)
	
	# Eyes (33px diameter, 35% of head)
	var left_eye = ColorRect.new()
	left_eye.position = Vector2(-35, -55)
	left_eye.size = Vector2(20, 28)
	left_eye.color = Color.BLACK
	character.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.position = Vector2(15, -55)
	right_eye.size = Vector2(20, 28)
	right_eye.color = Color.BLACK
	character.add_child(right_eye)
	
	# Long standing ears
	var left_ear = ColorRect.new()
	left_ear.position = Vector2(-35, -145)
	left_ear.size = Vector2(15, 70)
	left_ear.color = color
	character.add_child(left_ear)
	
	var right_ear = ColorRect.new()
	right_ear.position = Vector2(20, -145)
	right_ear.size = Vector2(15, 70)
	right_ear.color = color
	character.add_child(right_ear)
	
	# Fluffy tail (small circle, separate for animation)
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(50, 40)
	character.add_child(tail)
	
	var tail_rect = ColorRect.new()
	tail_rect.position = Vector2(-12, -12)
	tail_rect.size = Vector2(25, 25)
	tail_rect.color = color
	tail.add_child(tail_rect)
	
	return character

## Creates a fox character (red-orange)
static func create_fox(parent: Node, center: Vector2, color: Color) -> Node2D:
	var character = Node2D.new()
	character.position = center
	parent.add_child(character)
	
	# Body
	var body = ColorRect.new()
	body.position = Vector2(-65, 20)
	body.size = Vector2(130, 85)
	body.color = color
	character.add_child(body)
	
	# Head (circle)
	var head = ColorRect.new()
	head.position = Vector2(-52, -85)
	head.size = Vector2(105, 105)
	head.color = color
	character.add_child(head)
	
	# Eyes (36px diameter, 35% of head)
	var left_eye = ColorRect.new()
	left_eye.position = Vector2(-38, -62)
	left_eye.size = Vector2(21, 30)
	left_eye.color = Color.BLACK
	character.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.position = Vector2(17, -62)
	right_eye.size = Vector2(21, 30)
	right_eye.color = Color.BLACK
	character.add_child(right_eye)
	
	# Pointed ears (triangles)
	var left_ear = Polygon2D.new()
	left_ear.polygon = PackedVector2Array([
		Vector2(-42, -85),
		Vector2(-33, -85),
		Vector2(-37, -120)
	])
	left_ear.color = color
	character.add_child(left_ear)
	
	var right_ear = Polygon2D.new()
	right_ear.polygon = PackedVector2Array([
		Vector2(33, -85),
		Vector2(42, -85),
		Vector2(37, -120)
	])
	right_ear.color = color
	character.add_child(right_ear)
	
	# Fluffy tail (separate for animation)
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(65, 40)
	character.add_child(tail)
	
	var tail_rect = ColorRect.new()
	tail_rect.position = Vector2(0, 0)
	tail_rect.size = Vector2(80, 25)
	tail_rect.color = color
	tail.add_child(tail_rect)
	
	return character

## Creates a bird character (green)
static func create_bird(parent: Node, center: Vector2, color: Color) -> Node2D:
	var character = Node2D.new()
	character.position = center
	parent.add_child(character)
	
	# Body (round)
	var body = ColorRect.new()
	body.position = Vector2(-55, -10)
	body.size = Vector2(110, 90)
	body.color = color
	character.add_child(body)
	
	# Head (circle, 95px diameter)
	var head = ColorRect.new()
	head.position = Vector2(-47, -95)
	head.size = Vector2(95, 95)
	head.color = color
	character.add_child(head)
	
	# Eyes (33px diameter, 35% of head)
	var left_eye = ColorRect.new()
	left_eye.position = Vector2(-33, -65)
	left_eye.size = Vector2(18, 26)
	left_eye.color = Color.BLACK
	character.add_child(left_eye)
	
	var right_eye = ColorRect.new()
	right_eye.position = Vector2(15, -65)
	right_eye.size = Vector2(18, 26)
	right_eye.color = Color.BLACK
	character.add_child(right_eye)
	
	# Beak (small triangle, orange accent)
	var beak = Polygon2D.new()
	beak.polygon = PackedVector2Array([
		Vector2(0, -40),
		Vector2(-8, -30),
		Vector2(8, -30)
	])
	beak.color = Color("#F97316")  # Orange
	character.add_child(beak)
	
	# Beak outline
	var beak_outline = Line2D.new()
	beak_outline.add_point(Vector2(0, -40))
	beak_outline.add_point(Vector2(-8, -30))
	beak_outline.add_point(Vector2(8, -30))
	beak_outline.add_point(Vector2(0, -40))
	beak_outline.width = 3
	beak_outline.default_color = Color.BLACK
	character.add_child(beak_outline)
	
	# Left Wing (separate Node2D for animation) - rounded rectangle 20x30
	var wing_left = Node2D.new()
	wing_left.name = "WingLeft"
	wing_left.position = Vector2(-60, 10)
	character.add_child(wing_left)
	
	var wing_left_rect = ColorRect.new()
	wing_left_rect.position = Vector2(-10, -15)
	wing_left_rect.size = Vector2(20, 30)
	wing_left_rect.color = color.darkened(0.2)
	wing_left.add_child(wing_left_rect)
	
	# Right Wing (mirror of left, but not animated separately)
	var wing_right = ColorRect.new()
	wing_right.position = Vector2(40, -5)
	wing_right.size = Vector2(20, 30)
	wing_right.color = color.darkened(0.2)
	character.add_child(wing_right)
	
	# Tail feathers (3 small feather shapes) - separate Node2D
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(0, 80)
	character.add_child(tail)
	
	# 3 feather shapes (simple ovals)
	for i in range(3):
		var feather = ColorRect.new()
		feather.position = Vector2((i - 1) * 12 - 7, 0)
		feather.size = Vector2(15, 25)
		feather.color = color.darkened(0.3)
		tail.add_child(feather)
	
	return character
