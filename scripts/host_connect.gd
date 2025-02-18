extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.trigger_host_focus = true
	grab_focus()
	Global.trigger_host_focus = false
