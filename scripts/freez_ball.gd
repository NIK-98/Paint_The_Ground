extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var wall = get_parent().get_parent().get_node("wall")
@onready var level = get_parent().get_parent()

var current_dir = Vector2i(1,1)
var speed = 500.0

func _physics_process(_delta: float) -> void:
	velocity = current_dir*speed
	move_and_slide()
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		_direction(current_dir)


func _direction(old_dir: Vector2i):
	var dir_array = [Vector2i(1,1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1)]
	var rand_dir = dir_array.pick_random()
	if old_dir == rand_dir:
		dir_array.erase(rand_dir)
		current_dir = dir_array.pick_random()
		return
	current_dir = rand_dir
