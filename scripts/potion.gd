extends Node2D

@onready var game = get_tree().root.get_node('Game')

var effect: String
var shelf_index: int

var potion_shelf_position 
var drop_location 

var ingredients
var player_made = false
var dragging = false
var mouse_over = false

func _ready():
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
	if drop_location != potion_shelf_position:
		game.add_potion_to_distiller(self)

func _on_area_2d_mouse_entered():
	#play()
	mouse_over = true
	if not g.dragging_ingredient:
		game.toggle_highlight('Distiller', true)
		game.toggle_highlight('Player', true)

func _on_area_2d_mouse_exited():
	#if drop_location == potion_shelf_position: 
		#stop()
	mouse_over = false
	if not dragging and not g.dragging_ingredient and not g.dragging_potion:
		game.toggle_highlight('Distiller', false)
		game.toggle_highlight('Player', false)

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

func _on_area_2d_area_exited(area):
	var parent_node = area.get_parent()
	
	if parent_node.name == 'Player' or parent_node.name == 'Distiller':
		drop_location = potion_shelf_position
		
		if parent_node.name == 'Player':
			game.current_test_potion = null
			game.clear_test_potion_text()
			
		if parent_node.name == 'Distiller':
			game.current_distill_potion = null
