extends Node

var dragging_ingredient = false
var dragging_potion = false
var volume_control = 0

const effects = [
	"AstralProjection",
	"Cloning",
	"Combustion",
	"Elasticity",
	"Glowing",
	"Invisibility",
	"Shapeshifting",
	"Sleeping",
	"Strength",
	"Youthfulness"
]

# Game level state
var current_level = 1
var level_dict = {
	1: {
		'solution': [1, 3, 3, 3, 4],
		'rubric': {
			'AstralProjection': [1, 3],
			'Combustion': [3, 4],
			'Shapeshifting': [4, 4],
			'solution': [1, 3, 3, 3, 4]
		},
		'potion_colors': {
			'AstralProjection': '#eca7aa',
			'Combustion': "#2d9789",
			'Shapeshifting': "#a1ca48",
			'solution': "#a867b2"
		},
		'glyphs': [1, 2, 3, 4]
	},
	2: {
		'solution': [5, 6, 7, 8, 8],
		'rubric': {
			'Strength': [8, 8],
			'Elasticity': [5, 8],
			'Cloning': [5, 6],
			'Glowing': [6, 7],
			'solution': [5, 6, 7, 8, 8]
		},
		'potion_colors': {
			'Strength': "#e6bc73",
			'Elasticity': "#80cdf4",
			'Cloning': "#ffd21d",
			'Glowing': "#f28e3d",
			'solution': "#ed4d41"
		},
		'glyphs': [5, 6, 7, 8]
	},
	3: {
		'solution': [1, 3, 5, 8, 8],
		'rubric': {
			'AstralProjection': [8, 8],
			'Youthfulness': [3, 5],
			'Invisible': [1, 5],
			'Combustion': [3, 8],
			'Cloning': [5, 8],
			'solution': [1, 3, 5, 7, 8]
		},
		'potion_colors': {
			'AstralProjection': "#426bc7",
			'Youthfulness': "#fdffe0",
			'Invisible': "#f1ef3e",
			'Combustion': "#6fb143",
			'Cloning': "#343d46",
			'solution': "#9ea08d"
		},
		'glyphs': [1, 3, 5, 8]
	}
}

var stats = {
	'PotionsDrank': 0,
	'IngredientsDistilled': 0,
	'PotionsCreated': 0,
	'FailedBrews': 0,
	'FailedDoors': 0,
	'Refills': 0,
}

func track_stat(type: String):
	stats[type] += 1

func bgm_is_playing():
	return get_child(0).name

func play_bgm(fname, db_override=0, ext='.ogg'):
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.volume_db = db_override
	sfx_player.name = fname
	sfx_player.stream = load('res://sfx/BGM/BGM - '+fname+ext)
	add_child(sfx_player)
	sfx_player.play()
	
func stop_bgm(fname):
	var sfx_player = get_node_or_null(fname)
	if sfx_player:
		sfx_player.stop()
		sfx_player.queue_free()
		
func play_random_sfx(parent, fname, custom_range=2, db_override=0, ext='.ogg'):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_override
	print(sfx_player.volume_db)
	randomize()
	var track_num = randi_range(1, custom_range)
	print(fname+str(track_num))
	sfx_player.stream = load('res://sfx/SFX/'+fname+' '+str(track_num)+ext)
	sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()

func play_dialogue_sfx(parent, laugh = false):
	var sfx_player = AudioStreamPlayer.new()
	randomize()
	var track_num = randi_range(1, 10)
	sfx_player.volume_db = -5
	sfx_player.stream = load("res://sfx/Dialogue/Dialogue - Villain Expo "+str(track_num)+".ogg")
	if laugh:
		sfx_player.finished.connect(play_dialogue_laugh_sfx.bind(parent, sfx_player))
	else:
		sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()
	return sfx_player
	
func play_dialogue_laugh_sfx(parent, old_sfx_player):
	old_sfx_player.queue_free()
	await get_tree().create_timer(.5).timeout
	randomize()
	var track_num = randi_range(1, 2)
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -5
	sfx_player.stream = load("res://sfx/Dialogue/Dialogue - Villain Laugh "+str(track_num)+".ogg")
	sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()
	
