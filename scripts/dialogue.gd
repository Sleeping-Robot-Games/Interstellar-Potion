extends Control

@onready var game = get_tree().root.get_node('Game')

@export var text = ''
@export var show_arm = false
@export var laugh = false

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
	timer.wait_time = 0.05  # Adjust the time interval as needed
	timer.one_shot = false
	add_child(timer)
	timer.start()

	for i in range(text.length()):
		current_text += text[i]
		$RichTextLabel.text = current_text
		await timer.timeout

	timer.queue_free()  # Remove the timer when done

func _on_visibility_changed():
	if visible:
		animate_text()
		# TODO: Play sound and laugh after if true
