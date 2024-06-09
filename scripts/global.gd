extends Node

var dragging_ingredient = false
var dragging_potion = false

# Game level state
var current_level = 1
var level_dict = {
	1: {
		'solution': [1, 3, 3, 3, 4],
		'rubric': {
			'sparkle': [1, 3],
			'smoke': [3, 4],
			'shrink': [4, 4],
			'solution': [1, 3, 3, 3, 4]
		},
		'potion_colors': {
			'sparkle': '#eca7aa',
			'smoke': "#2d9789",
			'shrink': "#a1ca48",
			'solution': "#a867b2"
		}
	}
}
