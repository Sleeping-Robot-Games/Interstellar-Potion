extends Node

var dragging_ingredient = false
var dragging_potion = false
var volume_control = 0

# Game level state
var current_level = 1
var level_dict = {
	1: {
		'solution': [1, 3, 3, 3, 4],
		'rubric': {
			'sparkle': [1, 3],
			'smoke': [3, 4],
			'shrink': [4, 4],
			'solution': [1, 3, 3, 3, 4]
		},
		'potion_colors': {
			'sparkle': '#eca7aa',
			'smoke': "#2d9789",
			'shrink': "#a1ca48",
			'solution': "#a867b2"
		}
	},
	2: {
		'solution': [1, 2, 3, 4, 4],
		'rubric': {
			'glow': [4, 4],
			'shimmer': [1, 4],
			'flash': [1, 2],
			'sparkle': [3, 2],
			'solution': [1, 2, 3, 4, 4]
		},
		'potion_colors': {
			'glow': "#e6bc73",
			'shimmer': "#80cdf4",
			'flash': "#ffd21d",
			'sparkle': "#f28e3d",
			'solution': "#ed4d41"
		}
	}
}

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
		sfx_player.finished.connect(play_dialogue_laugh_sfx.bind(sfx_player))
	else:
		sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()
	return sfx_player
	
func play_dialogue_laugh_sfx(sfx_player):
	randomize()
	var track_num = randi_range(1, 2)
	sfx_player.volume_db = -5
	sfx_player.stream = load("res://sfx/Dialogue/Dialogue - Villain Laugh "+str(track_num)+".ogg")
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()
	
