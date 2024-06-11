extends Node2D

func _on_visibility_changed():
	for stat_node in $VBoxContainer.get_children():
		stat_node.get_node('Data').text = str(g.stats[stat_node.name])
