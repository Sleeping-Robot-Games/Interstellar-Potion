extends Node2D

@export var solution = ['red', 'green', 'green', 'green', 'blue']

var rubric_row_scene = preload("res://scenes/rubric_row.tscn")
var ingredient_scene = preload("res://scenes/ingredient.tscn")

var rubric = {
	'sparkle': ['red', 'green'],
	'smoke': ['green', 'blue'],
	'shrink': ['blue', 'blue']
}

var current_test_potion
var current_distill_potion
var max_ingredient_shelf_space = 6
var ingredient_shelf_state = {}
var cauldron_state = []

func _ready():
	# Set Door Requirements
	var requirement_nodes = $Door/Label2/Requirements.get_children()
	for i in range(requirement_nodes.size()):
		requirement_nodes[i].color = Color.html(g.hex_conversion[solution[i]])
	
	# Set Rubric
	for effect in rubric.keys():
		var row_instance = rubric_row_scene.instantiate()
		row_instance.effect = effect
		$Rubric/Container.add_child(row_instance)
	
	# Sets up dictionary with positions and empty null values
	for i in range(max_ingredient_shelf_space):
		ingredient_shelf_state[i + 1] = null


func _process(delta):
	if Input.is_action_pressed("Escape"):
		get_tree().quit()

func clear_test_potion_text():
	$TestPotion/Label.text = ''

func get_next_free_shelf_position() -> int:
	for index in ingredient_shelf_state.keys():
		if ingredient_shelf_state[index] == null:
			return index
	return -1


func distill_potion():
	for ingredient in current_distill_potion.ingredients:
		# Ingredient instantiate
		var new_ingredient = ingredient_scene.instantiate()
		var shelf_index = get_next_free_shelf_position()
		ingredient_shelf_state[shelf_index] = new_ingredient
		var ingredient_shelf_node = get_node("IngredientShelf")
		var dragables_node = get_node('Dragables')
		
		# Ingredient setup
		new_ingredient.color = ingredient
		new_ingredient.shelf_index = shelf_index
		var shelf_position = new_ingredient.set_shelf_location(ingredient_shelf_node)
		new_ingredient.global_position = $Distiller/Marker2D.global_position
		
		# Remove potion
		current_distill_potion.queue_free()
		# Add Ingredient
		dragables_node.add_child(new_ingredient)
		
		# Animation ingredient to shelf
		var tween = create_tween()
		tween.tween_property(new_ingredient, 'global_position', shelf_position, 1)
	
	
func get_cauldron_state_pos(ingredient):
	if cauldron_state.size() < 5:
		return $Cauldron/StateHolder.get_node("Pos"+str(cauldron_state.size()+1)).global_position
	return ingredient.shelf_position
	
func set_cauldron_ingredient(ingredient):
	cauldron_state.append(ingredient)
	ingredient_shelf_state[ingredient.shelf_index] = null
	
func _on_TestPotion_button_up():
	if current_test_potion:
		$TestPotion/Label.text = current_test_potion.effect

func _on_Distill_button_up():
	if current_distill_potion and get_next_free_shelf_position() != -1:
		distill_potion()
