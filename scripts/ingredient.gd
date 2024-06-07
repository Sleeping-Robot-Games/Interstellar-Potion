extends Sprite2D

@export var color = 'blue'

var sprite_dict = {
	'blue': ['res://assets/arcane_rune.png'],
	'green': ['res://assets/ice_rune.png'],
	'red': ['res://assets/earth_rune.png'],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = load(sprite_dict[color].pick_random())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
