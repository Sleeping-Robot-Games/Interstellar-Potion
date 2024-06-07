extends AnimatedSprite2D

@onready var game = get_tree().root.get_node('Game')
@onready var potion_shelf = get_parent()

@export var effect = 'smoke'
@export var shelf_index = 1
@onready var potion_shelf_position = potion_shelf.get_node('Pos'+str(shelf_index)).global_position
@onready var drop_location = potion_shelf_position

var ingredients
var dragging = false
var mouse_over = false

func _ready():
	ingredients = game.rubric[effect]

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
			else:
				# Stop dragging when the mouse button is released
				dragging = false
				global_position = drop_location

func _on_area_2d_mouse_entered():
	play()
	mouse_over = true

func _on_area_2d_mouse_exited():
	if drop_location == potion_shelf_position: 
		stop()
	mouse_over = false

func _on_area_2d_area_entered(area):
	var parent_node = area.get_parent()
	if parent_node.name == 'TestPotion' or parent_node.name == 'Distiller':
		drop_location = parent_node.get_node('Marker2D').global_position


func _on_area_2d_area_exited(area):
	var parent_node = area.get_parent()
	if parent_node.name == 'TestPotion' or parent_node.name == 'Distiller':
		drop_location = potion_shelf_position
