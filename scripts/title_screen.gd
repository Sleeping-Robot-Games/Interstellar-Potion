extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Windows":
		# Set game window
		var window = get_window()
		var screen_size = DisplayServer.screen_get_size()
		var window_size = Vector2i(1280, 720)
		window.size = window_size
		window.position = (screen_size - window_size) / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_button_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_texture_button_2_button_up():
	g.current_level = 2
	get_tree().change_scene_to_file("res://scenes/game.tscn")
