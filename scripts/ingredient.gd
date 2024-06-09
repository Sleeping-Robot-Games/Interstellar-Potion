extends Sprite2D

@onready var game = get_tree().root.get_node('Game')

var pointer = preload("res://assets/Cursors/Cursor_Pointer.png")
var grabber = preload("res://assets/Cursors/Cursor_Grab.png")

var shelf_index: int
var shelf_position: Vector2
var drop_location: Vector2
var color: String

var in_cauldron = false
var dragging = false
var mouse_over = false
var duration: float = 1.0
var move_distance: float = 10.0

func _ready():
	texture = load(game.ingredient_sprite_dict[color].sprite)

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()
		
func start_bob_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", position.y + move_distance, duration)
	tween.tween_property(self, "position:y", position.y - move_distance, duration)
	tween.tween_property(self, "position:y", position.y, duration)

func _input(event):
	if in_cauldron:
		return
	# Check if the event is a mouse button press
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Start dragging if the mouse button is pressed and is over the sprite
			if mouse_over:
				dragging = true
				g.dragging_ingredient = self
		else:
			if dragging:
				# Stop dragging when the mouse button is released
				dragging = false
				g.dragging_ingredient = null
				if drop_location != shelf_position:
					game.set_cauldron_ingredient(self)
					in_cauldron = true
					if not g.dragging_potion:
						game.toggle_highlight('Cauldron', false)
						Input.set_custom_mouse_cursor(pointer)
				else:
					in_cauldron = false
				
			var tween = create_tween()
			tween.tween_property(self, 'global_position', drop_location, .2)
			await tween.finished
			if in_cauldron:
				start_bob_animation()


func set_shelf_location(ingredient_shelf_node: Node2D):
	shelf_position = ingredient_shelf_node.get_node('Pos'+str(shelf_index)).global_position
	drop_location = shelf_position
	return shelf_position


func _on_area_2d_mouse_entered():
	if not in_cauldron:
		mouse_over = true
		if not g.dragging_potion:
			game.toggle_highlight('Cauldron', true)
			Input.set_custom_mouse_cursor(grabber)


func _on_area_2d_mouse_exited():
	if not in_cauldron:
		mouse_over = false
		if not dragging and not g.dragging_potion and not g.dragging_ingredient:
			game.toggle_highlight('Cauldron', false)
			Input.set_custom_mouse_cursor(pointer)


func _on_area_2d_area_entered(area):
	var parent_node = area.get_parent()
	# Go into Cauldron
	if parent_node.name == 'Cauldron' and game.cauldron_state.size() < 5:
		drop_location = game.get_cauldron_state_pos(self)
		

func _on_area_2d_area_exited(area):
	var parent_node = area.get_parent()
	
	# Go back to shelf
	if parent_node.name == 'Cauldron':
		drop_location = shelf_position
		
