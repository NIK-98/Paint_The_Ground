extends TouchScreenButton

@onready var joystick = $Joy
@onready var up = $"../Up"
@onready var down = $"../Down"
@onready var right = $"../Right"
@onready var left = $"../Left"


@export var maxLength = 50

var stick_center: Vector2 = texture_normal.get_size() / 2

var is_touch: bool = false

func _ready():
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		joystick.visible = true
		up.visible = true
		down.visible = true
		right.visible = true
		left.visible = true
	else:
		joystick.visible = false
		up.visible = false
		down.visible = false
		right.visible = false
		left.visible = false
	set_process(false)
	
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			set_process(true)
		elif not event.pressed:
			set_process(false)
			joystick.position = stick_center
				

func _process(_delta):
	joystick.global_position = get_global_mouse_position()
	joystick.position = stick_center + (joystick.position - stick_center).limit_length(maxLength)
	
func get_joystick_dir() -> Vector2:
	var dir = joystick.position - stick_center
	return dir.normalized()
