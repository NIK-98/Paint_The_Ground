extends Button


func _ready():
	Global.trigger_host_focus = true
	grab_focus()
	Global.trigger_host_focus = false
