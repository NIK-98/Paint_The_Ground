extends Control

@onready var joystick = $joy/Joy

@export var maxLength = 50

@onready var stick_center: Vector2 = $joy.texture_normal.get_size() / 2
@onready var joy_start_position = global_position

var is_touch: bool = false

func _ready():
	if OS.has_feature("dedicated_server"):
		return
	visible = false
	
	
func _input(event):
	if get_parent().get_parent().get_node("Level").get_child_count() > 0 and get_parent().get_parent().get_node("Level/level/CanvasLayer/Time").text.to_int() > 0 and not get_parent().get_parent().get_node("Level/level/loby").visible:
		if event is InputEventScreenTouch:
			if event.is_pressed():
				var entfernung_stick = abs(joy_start_position-get_global_mouse_position()).length()
				if entfernung_stick < 500:
					is_touch = true
					global_position = get_global_mouse_position()
				else:
					global_position = joy_start_position
			if event.is_released():
				is_touch = false
				joystick.position = stick_center
				global_position = joy_start_position
				

func _process(_delta):
	if get_parent().get_parent().get_node("Level").get_child_count() > 0:
		if get_parent().get_parent().get_node("Level/level/CanvasLayer/Time").text.to_int() > 0 and not get_parent().get_parent().get_node("Level/level/loby").visible:
			if OS.get_name() == "Android" or OS.get_name() == "IOS":
				visible = true
		elif visible:
			visible = false
			is_touch = false
			joystick.position = stick_center
			global_position = joy_start_position
	if is_touch:
		joystick.global_position = get_global_mouse_position()
		joystick.position = stick_center + (joystick.position - stick_center).limit_length(maxLength)
		
func get_joystick_dir() -> Vector2:
	if is_touch:
		var dir = joystick.position - stick_center
		dir = dir.normalized()
		return dir
	else:
		return Vector2()
