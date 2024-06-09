extends Control

var effect: String

@onready var game = get_tree().root.get_node('Game')

# Called when the node enters the scene tree for the first time.
func _ready():
	$FirstGlyph.texture = load("res://assets/Glyphs/Glyph"+str(game.rubric[effect][0])+".png")
	$SecondGlyph.texture = load("res://assets/Glyphs/Glyph"+str(game.rubric[effect][1])+".png")
	$Label.text = effect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
