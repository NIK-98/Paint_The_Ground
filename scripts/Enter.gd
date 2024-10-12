extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.trigger_host_focus = true
	grab_focus()
	Global.trigger_host_focus = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
