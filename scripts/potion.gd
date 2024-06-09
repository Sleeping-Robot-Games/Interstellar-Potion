extends Node2D

@onready var game = get_tree().root.get_node('Game')

var pointer = preload("res://assets/Cursors/Cursor_Pointer.png")
var grabber = preload("res://assets/Cursors/Cursor_Grab.png")

var effect: String
var shelf_index: int
var dud: bool = false

var potion_shelf_position 
var drop_location 

var ingredients
var player_made = false
var dragging = false
var mouse_over = false

# always false, I know it's a hack. It's so loops going through ing nodes don't bork
const in_cauldron = false

func _ready():
	var potion_hex_color = g.level_dict[g.current_level].potion_colors[effect]
	$Fill.modulate = Color.html(potion_hex_color)
	ingredients = game.rubric[effect]
	global_position = potion_shelf_position

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()

func _input(event):
	# Check if the event is a mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging if the mouse button is pressed and is over the sprite
				if mouse_over:
					dragging = true
					g.dragging_potion = true
			else:
				if dragging:
					# Stop dragging when the mouse button is released
					dragging = false
					g.dragging_potion = false
					var tween = create_tween()
					tween.tween_property(self, 'global_position', drop_location, .2)
					tween.connect('finished', _on_potion_drop_tween_finished)
					
func _on_potion_drop_tween_finished():
	if drop_location == game.get_node("Distiller/PotionDropMarker").global_position:
		game.add_potion_to_distiller(self)
		
	if drop_location == game.get_node("Player/PotionDropMarker").global_position:
		game.show_potion_effect()
		
	if drop_location == game.get_node("Door/PotionDropMarker").global_position:
		game.toggle_highlight('Door', false)
		game.check_solution(self)

func _on_area_2d_mouse_entered():
	mouse_over = true
	if not g.dragging_ingredient:
		if player_made:
			game.toggle_highlight('Door', true)
		else:
			game.toggle_highlight('Distiller', true)
			game.toggle_highlight('Player', true)
		Input.set_custom_mouse_cursor(grabber)

func _on_area_2d_mouse_exited():
	mouse_over = false
	if not dragging and not g.dragging_ingredient and not g.dragging_potion:
		if player_made:
			game.toggle_highlight('Door', false)
		else:
			game.toggle_highlight('Distiller', false)
			game.toggle_highlight('Player', false)
		Input.set_custom_mouse_cursor(pointer)

func _on_area_2d_area_entered(area):
	var parent_node = area.get_parent()

	if parent_node.name == 'Player':
		game.current_test_potion = self
		drop_location = parent_node.get_node('PotionDropMarker').global_position
	if parent_node.name == 'Distiller' and game.current_distill_potion == null and game.get_next_free_ingredient_shelf_position() != -1:
		if game.count_ingredients_on_shelf() == 5:
			return
		game.current_distill_potion = self
		drop_location = parent_node.get_node('PotionDropMarker').global_position
	if parent_node.name == 'Door':
		drop_location = parent_node.get_node('PotionDropMarker').global_position

func _on_area_2d_area_exited(area):
	var parent_node = area.get_parent()
	
	if parent_node.name == 'Player' or parent_node.name == 'Distiller' or parent_node.name == 'Door':
		drop_location = potion_shelf_position
		
		if parent_node.name == 'Player':
			game.current_test_potion = null
			game.clear_test_potion_text()
			
		if parent_node.name == 'Distiller':
			game.current_distill_potion = null
