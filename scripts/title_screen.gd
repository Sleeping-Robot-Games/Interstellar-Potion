extends Control

var bus_idx


func _ready():
	g.play_bgm('Stage 2')
	bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, -10)
	if OS.get_name() == "Windows":
		# Set game window
		var window = get_window()
		var screen_size = DisplayServer.screen_get_size()
		var window_size = Vector2i(1280, 720)
		window.size = window_size
		window.position = (screen_size - window_size) / 2


func _on_texture_button_button_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_texture_button_2_button_up():
	g.current_level = 2
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_h_slider_value_changed(value):
	var mute = value == -20
	AudioServer.set_bus_mute(bus_idx, mute)
	AudioServer.set_bus_volume_db(bus_idx, value)
