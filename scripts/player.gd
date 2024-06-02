extends CharacterBody2D

@onready var map = $"/root/main/floor"

const SPEED = 20
var spawn = position
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5

func _ready():
	color_change()

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _physics_process(delta):
	if is_multiplayer_authority():
		var move = Input.get_vector("left","right","up","down")
		if position.x < 0:
			velocity.x += 10
		elif position.x+$Color.size.x > Global.Spielfeld_Size.x:
			velocity.x -= 10
		elif position.y < 0:
			velocity.y += 10
		elif position.y+$Color.size.y > Global.Spielfeld_Size.y:
			velocity.y -= 10
		else:
			velocity = move*SPEED

		move_and_collide(velocity)
		$Camera2D.limit_right = Global.Spielfeld_Size.x
		$Camera2D.limit_bottom = Global.Spielfeld_Size.y
		if (velocity.x != 0 or velocity.y != 0):
			if get_parent().get_child(3) != null and get_parent().get_child(3).name == name:
				paint.rpc(1)
			if get_parent().get_child(4) != null and get_parent().get_child(4).name == name:
				paint.rpc(2)
			if get_parent().get_child(5) != null and get_parent().get_child(5).name == name:
				paint.rpc(3)

@rpc("any_peer","call_local")
func paint(tile: int):
	for x in range(tile_size*tile_size_multipl):
		for y in range(tile_size*tile_size_multipl):
			var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
			map.set_cell(0,tile_position,tile,Vector2i(0,0))
		
func color_change():
	if get_parent().get_child(3) != null and get_parent().get_child(3).name == name:
		get_node("Color").set_color(Color(255,0,0))
	if get_parent().get_child(4) != null and get_parent().get_child(4).name == name:
		get_node("Color").set_color(Color(0,0,255))
	if get_parent().get_child(5) != null and get_parent().get_child(5).name == name:
		get_node("Color").set_color(Color(0,255,0))
