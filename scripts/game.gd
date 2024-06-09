extends Node2D

@export var solution = ['red', 'green', 'green', 'green', 'blue']

var rubric_row_scene = preload("res://scenes/rubric_row.tscn")
var potion_scene = preload("res://scenes/potion.tscn")
var ingredient_scene = preload("res://scenes/ingredient.tscn")

var rubric = {
	'sparkle': ['red', 'green'],
	'smoke': ['green', 'blue'],
	'shrink': ['blue', 'blue'],
}

var ingredient_sprite_dict = {}

var current_test_potion
var current_distill_potion
var max_ingredient_shelf_space = 6
var max_potion_shelf_space = 5
var ingredient_shelf_state = {}
var potion_shelf_state = {}
var cauldron_state = []
var spoon_disabled = true

func _ready():
	# Set game window
	var window = get_window()
	var screen_size = DisplayServer.screen_get_size()
	var window_size = Vector2i(1280, 720)
	window.size = window_size
	window.position = (screen_size - window_size) / 2

	# Set Door Requirements
	var requirement_nodes = $Door/Requirements.get_children()
	for i in range(requirement_nodes.size()):
		requirement_nodes[i].color = Color.html(g.hex_conversion[solution[i]])
	
	# Set Rubric
	for effect in rubric.keys():
		var row_instance = rubric_row_scene.instantiate()
		row_instance.effect = effect
		$Rubric/Container.add_child(row_instance)
		
	# Set and randomize ingredient sprites based on colors
	var colors = ['blue', 'green', 'red', 'purple']
	var glyph_sprite_pairs = [
		{'glyph': 'res://assets/Ingredient_Glyph_Crystal.png', 'sprite': 'res://assets/Draggables/Ingredient_Crystal.png'},
		{'glyph': 'res://assets/Ingredient_Glyph_Sack.png', 'sprite': 'res://assets/Draggables/Ingredient_Sack.png'},
		{'glyph': 'res://assets/Ingredient_Glyph_Bowl.png', 'sprite': 'res://assets/Draggables/Ingredient_Bowl.png'},
		{'glyph': 'res://assets/Ingredient_Glyph_Tincture.png', 'sprite': 'res://assets/Draggables/Ingredient_Tincture.png'}
	]
	glyph_sprite_pairs.shuffle()
	for i in range(colors.size()):
		ingredient_sprite_dict[colors[i]] = glyph_sprite_pairs[i]
	
	# Sets up dictionaries with positions and empty null values
	for i in range(max_ingredient_shelf_space):
		ingredient_shelf_state[i + 1] = null
	
	for i in range(max_potion_shelf_space):
		potion_shelf_state[i + 1] = null

	# Set inital potions
	fill_potion_shelf()

func _process(delta):
	if Input.is_action_pressed("Escape"):
		get_tree().quit()


func fill_potion_shelf():
	# Fill shelf until there's no more room
	while get_next_free_potion_shelf_position() != -1:
		var new_potion = potion_scene.instantiate()
		var shelf_index = get_next_free_potion_shelf_position()
		var effect = rubric.keys().pick_random()
		
		potion_shelf_state[shelf_index] = new_potion
		var potion_shelf_node = get_node("PotionShelf")
		var dragables_node = get_node('Dragables')
		
		new_potion.shelf_index = shelf_index
		new_potion.effect = effect
		new_potion.potion_shelf_position = potion_shelf_node.get_node('Pos'+str(shelf_index)).global_position
		new_potion.drop_location = new_potion.potion_shelf_position
		
		dragables_node.add_child(new_potion)

func clear_test_potion_text():
	$Player/Label.text = ''

func count_ingredients_on_shelf() -> int:
	var count = 0
	for index in ingredient_shelf_state.keys():
		if ingredient_shelf_state[index] != null:
			count += 1
	return count
	
func get_next_free_ingredient_shelf_position() -> int:
	for index in ingredient_shelf_state.keys():
		if ingredient_shelf_state[index] == null:
			return index
	return -1

func get_next_free_potion_shelf_position() -> int:
	for index in potion_shelf_state.keys():
		if potion_shelf_state[index] == null:
			return index
	return -1

func distill_potion():
	for ingredient in current_distill_potion.ingredients:
		# Ingredient instantiate
		var new_ingredient = ingredient_scene.instantiate()
		var shelf_index = get_next_free_ingredient_shelf_position()
		ingredient_shelf_state[shelf_index] = new_ingredient
		var ingredient_shelf_node = get_node("IngredientShelf")
		var dragables_node = get_node('Dragables')
		
		# Ingredient setup
		new_ingredient.color = ingredient
		new_ingredient.shelf_index = shelf_index
		var shelf_position = new_ingredient.set_shelf_location(ingredient_shelf_node)
		new_ingredient.global_position = get_node("Distiller/IngredientExitMarker").global_position
		# Remove potion
		current_distill_potion.queue_free()
		# TODO: Reset color of Distiller when potion is gone
		# Add Ingredient
		dragables_node.add_child(new_ingredient)
		
		# Animation ingredient to shelf
		var tween = create_tween()
		tween.tween_property(new_ingredient, 'global_position', shelf_position, .5)
	
	
func get_cauldron_state_pos(ingredient):
	if cauldron_state.size() < 5:
		return $Cauldron/StateHolder.get_node("Pos"+str(cauldron_state.size()+1)).global_position
	return ingredient.shelf_position
	
func set_cauldron_ingredient(ingredient):
	cauldron_state.append(ingredient)
	ingredient_shelf_state[ingredient.shelf_index] = null
	# animate glyph of ingredient
	var glyph = get_node("Cauldron/Glyph"+str(cauldron_state.size()))
	glyph.texture = load(ingredient_sprite_dict[ingredient.color].glyph)
	var tween = create_tween()
	tween.tween_property(glyph, "modulate:a", 1.0, 2)
	
	if cauldron_state.size() >= 2:
		spoon_disabled = false
		toggle_highlight("Spoon", true)
	
func toggle_highlight(object: String, toggle: bool):
	get_node(object+"/"+"Highlight").visible = toggle
	
func _on_TestPotion_button_up():
	if current_test_potion:
		$Player/Label.text = current_test_potion.effect

func add_potion_to_distiller(potion):
	# TODO: Change color of Distiller when potion is here
	await get_tree().create_timer(1).timeout 
	current_distill_potion = potion
	distill_potion()

func _on_Cauldron_button_up():
	if spoon_disabled:
		return
	# TODO: Clear cauldron state
	# Clear ingredient runes on the cauldron
	# Create a new potion based on the ingredients given and the rubric
	# Tween it to the top shelf
	var starting_pos = $Spoon.position
	var tween = create_tween()
	tween.tween_property($Spoon, 'position:x', starting_pos.x - 200, .4)
	tween.tween_property($Spoon, 'position:x', starting_pos.x, .4)
	tween.connect("finished", on_spoon_tween_finished)
	spoon_disabled = true
	
func on_spoon_tween_finished():
	spoon_disabled = false

func _on_PotionRefill_button_up():
	fill_potion_shelf()

