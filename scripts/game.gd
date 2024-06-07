extends Node2D

@export var solution = ['red', 'green', 'green', 'green', 'blue']

var rubric_row_scene = preload("res://scenes/rubric_row.tscn")

var rubric = {
	'sparkle': ['red', 'green'],
	'smoke': ['green', 'blue'],
	'shrink': ['blue', 'blue']
}

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

func _process(delta):
	pass
