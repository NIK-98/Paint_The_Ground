extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.trigger_host_focus = true
	grab_focus()
	Global.trigger_host_focus = false


func _process(_delta: float) -> void:
	if Global.ui_focus:
		Global.ui_focus = false
		Global.trigger_host_focus = true
		grab_focus()
		Global.trigger_host_focus = false
	if not get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().visible:
		set_process(false)
