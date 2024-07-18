extends Control

@onready var joystick = $Control/Joy
@onready var up = $"Control/Up"
@onready var down = $"Control/Down"
@onready var right = $"Control/Right"
@onready var left = $"Control/Left"
@onready var layer = $"Control"


@export var maxLength = 50

@onready var stick_center: Vector2 = get_parent().get_node("joy/Control/joy").texture_normal.get_size() / 2
@onready var joy_start_position = get_parent().get_node("joy/Control/joy").global_position

var is_touch: bool = false

func _ready():
	layer.visible = false
	set_process(false)
	
	
func _input(event):
	if event is InputEventScreenTouch:
		if get_parent().get_parent().get_node("Level/level") != null:
			if event.pressed:
				set_process(true)
				var entfernung_stick = abs(joy_start_position-get_global_mouse_position()).length()
				if entfernung_stick < 500:
					layer.visible = true
					is_touch = true
					global_position = get_global_mouse_position()
				else:
					global_position = joy_start_position
			elif not event.pressed:
				set_process(false)
				layer.visible = false
				is_touch = false
				joystick.position = stick_center
				global_position = joy_start_position
				

func _process(_delta):
	if is_touch:
		joystick.global_position = get_global_mouse_position()
		joystick.position = stick_center + (joystick.position - stick_center).limit_length(maxLength)
	
func get_joystick_dir() -> Vector2:
	var dir = joystick.position - stick_center
	dir = dir.normalized()
	dir = round(dir)
	return dir
