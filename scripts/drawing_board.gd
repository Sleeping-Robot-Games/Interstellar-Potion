extends Node2D

var current_line: Line2D = null
var is_over_board = false

var pointer = preload("res://assets/Cursors/Cursor_Pointer.png")
var pen = preload("res://assets/Cursors/Cursor_Pen.png")

func _input(event): 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and is_over_board:
			# Create a new Line2D node
			current_line = Line2D.new()
			current_line.width = 3  # Set the width of the line
			current_line.default_color = Color.BLACK  # Set the color of the line
			add_child(current_line)  # Add the new Line2D to the scene
			$Instructions.hide()
			get_parent().hide_dialogue("Notes")
		else:
			current_line = null
	
	elif event is InputEventMouseMotion and current_line != null and is_over_board:
		current_line.add_point(event.position)

func _on_area_2d_mouse_entered():
	is_over_board = true
	Input.set_custom_mouse_cursor(pen)

func _on_area_2d_mouse_exited():
	is_over_board = false
	Input.set_custom_mouse_cursor(pointer)

func _on_clear_button_button_up():
	$Instructions.show()
	for line in get_children():
		if line is Line2D:
			line.queue_free()
