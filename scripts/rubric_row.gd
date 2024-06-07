extends Control

@export var combination = ['red', 'blue', 'test']

# Called when the node enters the scene tree for the first time.
func _ready():
	$Element0.color = Color.html(g.hex_conversion[combination[0]])
	$Element1.color = Color.html(g.hex_conversion[combination[1]])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
