extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var button: Button = $Button
@onready var ui = get_parent().get_parent().get_node("CanvasLayer2/Control/UI")

func _ready() -> void:
	name = "trailer"
	button.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not video_stream_player.is_playing():
		ui.trailer_on = false
		queue_free()


func _on_button_pressed() -> void:
	ui.trailer_on = false
	queue_free()
