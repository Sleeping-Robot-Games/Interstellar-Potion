extends Node2D

var current_line: Line2D = null
var is_over_board = false

func _input(event): 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and is_over_board:
			# Create a new Line2D node
			current_line = Line2D.new()
			current_line.width = 3  # Set the width of the line
			current_line.default_color = Color.BLACK  # Set the color of the line
			add_child(current_line)  # Add the new Line2D to the scene
		else:
			current_line = null
	
	elif event is InputEventMouseMotion and current_line != null and is_over_board:
		current_line.add_point(event.position)



func _on_area_2d_mouse_entered():
	is_over_board = true


func _on_area_2d_mouse_exited():
	is_over_board = false


func _on_button_button_up():
	for line in get_children():
		if line is Line2D:
			line.queue_free()
