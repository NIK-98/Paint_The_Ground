extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

var current_dir = Vector2i(1,1)
var speed = 500.0
const cooldown_time_tp = 1
var tp_cool_down = cooldown_time_tp
@export var feld = 1
var portal_free = true


func _physics_process(_delta: float) -> void:
	velocity = current_dir*speed
	move_and_slide()
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		_direction(current_dir)
	if not map.array_floor.is_empty() and map.get_tp_feld(position) != null:
		feld = map.get_tp_feld(position)[1]
		

func _process(delta: float) -> void:
	if level.get_node("loby").tp_mode:
		tp_cool_down -= delta
		if round(tp_cool_down) <= 0:
			if portal_free and map.is_vaild_portal(position):
				portal_free = false
				tp_cool_down = cooldown_time_tp
				feld = map.get_next_field(feld)
				map.tp_to(self, feld)
				feld = map.get_tp_feld(position)[1]
			if not portal_free and not map.is_vaild_portal(position):
				portal_free = true


func _direction(old_dir: Vector2i):
	var dir_array = [Vector2i(1,1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1)]
	var rand_dir = dir_array.pick_random()
	if old_dir == rand_dir:
		dir_array.erase(rand_dir)
		current_dir = dir_array.pick_random()
		return
	current_dir = rand_dir
