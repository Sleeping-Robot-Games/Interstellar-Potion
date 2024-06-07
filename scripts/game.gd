extends Node2D

var requirements = ['red', 'green', 'green', 'green', 'blue']

func _ready():
	var requirement_nodes = $DoorPlaceholder/Label2/Requirements.get_children()
	for i in range(requirement_nodes.size()):
		requirement_nodes[i].color = Color.html(g.hex_conversion[requirements[i]])

func _process(delta):
	pass
