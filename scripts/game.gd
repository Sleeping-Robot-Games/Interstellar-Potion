extends Node2D

var rubric_row_scene = preload("res://scenes/rubric_row.tscn")
var potion_scene = preload("res://scenes/potion.tscn")
var ingredient_scene = preload("res://scenes/ingredient.tscn")
var tutorial_music = preload("res://sfx/BGM/BGM - Tutorial.ogg")
var stage_1_music = preload("res://sfx/BGM/BGM - Stage 1.ogg")
var stage_2_music = preload("res://sfx/BGM/BGM - Stage 2.ogg")

var dialogue_state = []
var distill_counter = 0
var first_potion = true

var solution = []
var rubric = {}

var ingredient_sprite_dict = {}

var current_test_potion
var current_distill_potion
var max_ingredient_shelf_space = 6
var max_potion_shelf_space = 5
var max_player_made_potion_shelf_space = 5
var ingredient_shelf_state = {}
var potion_shelf_state = {}
var player_made_potion_shelf_state = {}
var cauldron_state = []
var spoon_disabled = true

func _ready():
	if OS.get_name() == "Windows":
		# Set game window
		var window = get_window()
		var screen_size = DisplayServer.screen_get_size()
		var window_size = Vector2i(1280, 720)
		window.size = window_size
		window.position = (screen_size - window_size) / 2
	
	# Music
	var music
	if g.current_level == 1:
		music = tutorial_music
	else:
		music = stage_2_music
	$AudioStreamPlayer.stream = music
	$AudioStreamPlayer.play()
	
	# Set Level
	solution = g.level_dict[g.current_level].solution
	rubric = g.level_dict[g.current_level].rubric

	# Set Door Requirements
	var requirement_nodes = $Door/Requirements.get_children()
	for i in range(requirement_nodes.size()):
		requirement_nodes[i].texture = load("res://assets/Glyphs/Glyph"+str(solution[i])+".png")
	
	# Set Rubric
	for effect in rubric.keys():
		if effect == 'solution':
			continue
		var row_instance = rubric_row_scene.instantiate()
		row_instance.effect = effect
		$Rubric/Container.add_child(row_instance)
		
	# Set and randomize ingredient sprites based on glyphs
	var glyphs = [1, 2, 3, 4]
	var rune_sprite_pairs = [
		{'rune': 'res://assets/Ingredient_Glyph_Crystal.png', 'sprite': 'res://assets/Draggables/Ingredient_Crystal.png'},
		{'rune': 'res://assets/Ingredient_Glyph_Sack.png', 'sprite': 'res://assets/Draggables/Ingredient_Sack.png'},
		{'rune': 'res://assets/Ingredient_Glyph_Bowl.png', 'sprite': 'res://assets/Draggables/Ingredient_Bowl.png'},
		{'rune': 'res://assets/Ingredient_Glyph_Tincture.png', 'sprite': 'res://assets/Draggables/Ingredient_Tincture.png'}
	]
	rune_sprite_pairs.shuffle()
	for i in range(glyphs.size()):
		ingredient_sprite_dict[glyphs[i]] = rune_sprite_pairs[i]
	
	# Sets up dictionaries with positions and empty null values
	for i in range(max_ingredient_shelf_space):
		ingredient_shelf_state[i + 1] = null
	
	for i in range(max_potion_shelf_space):
		potion_shelf_state[i + 1] = null
		
	for i in range(max_player_made_potion_shelf_space):
		player_made_potion_shelf_state[i + 1] = null

	# Set inital potions
	fill_potion_shelf()
	
	play_dialogue("Intro")
	await get_tree().create_timer(10).timeout
	play_dialogue("DrinkPotion")
	

func _process(delta):
	if Input.is_action_pressed("Escape"):
		get_tree().quit()

func check_solution(potion):
	var check_solution = solution
	check_solution.sort()
	var potion_ing = potion.ingredients
	potion_ing.sort()
	
	var success = solution == potion_ing
	
	if success:
		$Door/Label.text = "WIN!"
	else:
		$Door/Label.text = "Try Again"
		if not "Fail" in dialogue_state:
			play_dialogue("Fail")
			await get_tree().create_timer(10).timeout
			hide_dialogue("Fail")
	
	await get_tree().create_timer(2).timeout
	$Door/Label.text = ""
	potion.queue_free()
	hide_dialogue("Success")
	if success:
		## TODO: increment level
		g.current_level = 2
		get_tree().reload_current_scene()

func fill_potion_shelf():
	# Fill shelf until there's no more room
	while get_next_free_potion_shelf_position() != -1:
		var new_potion = potion_scene.instantiate()
		var shelf_index = get_next_free_potion_shelf_position()
		var available_potion_effects = rubric.keys()
		available_potion_effects.erase('solution')
		var effect = available_potion_effects.pick_random()
		
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
	
func get_next_free_player_potion_shelf_position() -> int:
	for index in player_made_potion_shelf_state.keys():
		if player_made_potion_shelf_state[index] == null:
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
		new_ingredient.glyph = ingredient
		new_ingredient.shelf_index = shelf_index
		var shelf_position = new_ingredient.set_shelf_location(ingredient_shelf_node)
		new_ingredient.global_position = get_node("Distiller/IngredientExitMarker").global_position
		# Remove potion
		current_distill_potion.queue_free()
		$Distiller/Fill.hide()
		# Add Ingredient
		dragables_node.add_child(new_ingredient)
		
		# Animation ingredient to shelf
		var tween = create_tween()
		tween.tween_property(new_ingredient, 'global_position', shelf_position, .5)
		
	distill_counter += 1
	play_dialogue("Ingredients")
	if distill_counter == 2:
		play_dialogue("Notes")
	if distill_counter == 5:
		play_dialogue("Supplies")
	await get_tree().create_timer(10).timeout
	play_dialogue("Cauldron")
	
func get_cauldron_state_pos(ingredient):
	if cauldron_state.size() < 5:
		return $Cauldron/StateHolder.get_node("Pos"+str(cauldron_state.size()+1)).global_position
	return ingredient.shelf_position
	
func set_cauldron_ingredient(ingredient):
	g.play_random_sfx(self, 'Adding Ingredient', 1)
	cauldron_state.append(ingredient)
	ingredient_shelf_state[ingredient.shelf_index] = null
	# animate rune of ingredient
	var rune = get_node("Cauldron/Rune"+str(cauldron_state.size()))
	rune.texture = load(ingredient_sprite_dict[ingredient.glyph].rune)
	var tween = create_tween()
	tween.tween_property(rune, "modulate:a", 1.0, 2)
	
	if cauldron_state.size() >= 2:
		spoon_disabled = false
		toggle_highlight("Spoon", true)
		play_dialogue("Brew")
	
func toggle_highlight(object: String, toggle: bool):
	get_node(object+"/"+"Highlight").visible = toggle
	
func show_potion_effect():
	if current_test_potion:
		g.play_random_sfx(self, 'Drinking Potion', 6)
		$Player/Label.text = current_test_potion.effect
		await get_tree().create_timer(2).timeout
		play_dialogue("StudyLaws")
		await get_tree().create_timer(10).timeout
		play_dialogue("Distill")

func add_potion_to_distiller(potion):
	g.play_random_sfx(self, 'Distilling', 15)
	var color = g.level_dict[g.current_level].potion_colors[potion.effect]
	$Distiller/Fill.modulate = Color.html(color)
	$Distiller/Fill.show()
	await get_tree().create_timer(1).timeout 
	current_distill_potion = potion
	distill_potion()

func find_effect_by_ingredients(ingredients):
	var ingredient_glyphs = []
	for ing in ingredients:
		ingredient_glyphs.append(ing.glyph)
	ingredient_glyphs.sort()
	
	for effect in rubric.keys():
		var required_ingredients = rubric[effect]
		required_ingredients.sort()
		if ingredient_glyphs == required_ingredients:
			return effect
	
	var solution_check = solution
	solution_check.sort()
	if ingredient_glyphs == solution_check:
		return 'solution'
		
	return 'none'

func _on_Cauldron_button_up():
	if spoon_disabled or get_next_free_player_potion_shelf_position() == -1:
		return
		
	g.play_random_sfx(self, 'Cauldron Bubbles', 8)
	
	# Animate spoon
	var starting_pos = $Spoon.position
	var spoon_tween = create_tween()
	spoon_tween.tween_property($Spoon, 'position:x', starting_pos.x - 200, .4)
	spoon_tween.tween_property($Spoon, 'position:x', starting_pos.x, .4)
	spoon_tween.connect("finished", on_spoon_tween_finished)
	spoon_disabled = true
	
	for ing in $Dragables.get_children():
		if ing.in_cauldron:
			ing.queue_free()
			
	for rune in $Cauldron.get_children():
		if 'Rune' in rune.name:
			var tween = create_tween()
			tween.tween_property(rune, "modulate:a", 0, 2)
			
	# Create a new potion based on the ingredients given and the rubric
	var effect = find_effect_by_ingredients(cauldron_state)
	if effect == 'solution':
		play_dialogue("Success")
	if effect == 'none':
		# No potion can be created based on the ingredients, clear state
		cauldron_state = []
		play_dialogue("BadBrew")
		await get_tree().create_timer(10).timeout
		hide_dialogue("BadBrew")
		return
		
	var new_potion = potion_scene.instantiate()
	var shelf_index = get_next_free_player_potion_shelf_position()
	
	player_made_potion_shelf_state[shelf_index] = new_potion
	var player_potion_shelf_node = get_node("PlayerPotionShelf")
	var dragables_node = get_node('Dragables')
	
	new_potion.shelf_index = shelf_index
	new_potion.effect = effect
	new_potion.potion_shelf_position = player_potion_shelf_node.get_node('Pos'+str(shelf_index)).global_position
	new_potion.drop_location = new_potion.potion_shelf_position
	new_potion.player_made = true
	new_potion.global_position = $Cauldron.global_position
	
	dragables_node.add_child(new_potion)
	# Tween it to the top shelf
	var tween = create_tween()
	tween.tween_property(new_potion, 'global_position', new_potion.drop_location, 1)
	
	cauldron_state = []
	
	play_dialogue("Escape")
	await get_tree().create_timer(10).timeout
	hide_dialogue("Escape")
	
	
func on_spoon_tween_finished():
	spoon_disabled = false
	toggle_highlight('Spoon', false)

func _on_PotionRefill_button_up():
	fill_potion_shelf()
	hide_dialogue("Supplies")

func play_dialogue(type):
	if g.current_level != 1 or type in dialogue_state:
		return
	for dialogue in $Dialogues.get_children():
		hide_dialogue(dialogue.name)
	dialogue_state.append(type)
	get_node("Dialogues/" + type).show()
	
func hide_dialogue(type):
	if g.current_level != 1:
		return
	get_node("Dialogues/" + type).hide()
