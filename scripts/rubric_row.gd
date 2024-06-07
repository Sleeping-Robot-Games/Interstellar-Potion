extends Control

var effect: String

@onready var game = get_tree().root.get_node('Game')

# Called when the node enters the scene tree for the first time.
func _ready():
	$Element0.color = Color.html(g.hex_conversion[game.rubric[effect][0]])
	$Element1.color = Color.html(g.hex_conversion[game.rubric[effect][1]])
	$Label.text = effect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
