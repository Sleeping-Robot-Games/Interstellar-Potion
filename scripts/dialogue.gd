extends Control

@onready var game = get_tree().root.get_node('Game')

@export var text = ''
@export var show_arm = false
@export var laugh = false

var sfx_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.points[4] = $Line2D.to_local(game.get_node('IntercomMarker').global_position)
	$Arm.visible = show_arm

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func animate_text():
	var current_text = ''
	var timer = Timer.new()
	timer.wait_time = 0.02  # Adjust the time interval as needed
	timer.one_shot = false
	add_child(timer)
	timer.start()

	var i = 0
	while i < text.length():
		if text[i] == '[':  # Detect the start of a BBCode tag
			var end_index = text.find(']', i)
			if end_index != -1:  # Ensure there's a closing bracket
				while text.find('[', end_index + 1) == end_index + 1:
					end_index = text.find(']', end_index + 1)
				current_text += text.substr(i, end_index - i + 1)
				$RichTextLabel.text = current_text
				i = end_index + 1  # Move past the BBCode tag
			else:
				current_text += text[i]
				$RichTextLabel.text = current_text
				i += 1
		else:
			current_text += text[i]
			$RichTextLabel.text = current_text
			i += 1

		await get_tree().create_timer(timer.wait_time).timeout

	timer.queue_free()  # Remove the timer when done

func _on_visibility_changed():
	if visible:
		animate_text()
		sfx_player = g.play_dialogue_sfx(self, laugh)
	else:
		if is_instance_valid(sfx_player):
			sfx_player.queue_free()
