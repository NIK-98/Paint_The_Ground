extends CharacterBody2D

@onready var map = $"/root/main/floor"

const SPEED = 20
var spawn = position
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5
var ID = 0

func _ready():
	color_change(ID)

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
			if ID == 1:
				paint.rpc(1)
			else:
				paint.rpc(2)

@rpc("any_peer","call_local")
func paint(tile: int):
	for x in range(tile_size*tile_size_multipl):
		for y in range(tile_size*tile_size_multipl):
			var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
			map.set_cell(0,tile_position,tile,Vector2i(0,0))
		
func color_change(ID):
	if ID == 1:
		get_node("Color").set_color(Color(255,0,0))
	else:
		get_node("Color").set_color(Color(0,0,255))
