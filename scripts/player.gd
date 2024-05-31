extends CharacterBody2D

@onready var map = $"/root/main/floor"

const SPEED = 20
var spawn = position
var ID = 0
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5

func _physics_process(delta):	
	var up_down = Input.get_axis(str("up",ID),str("down",ID))
	var left_right = Input.get_axis(str("left",ID),str("right",ID))
	if position.x < 0:
		velocity.x += 10
	elif position.x+$Color.size.x > Global.Spielfeld_Size.x:
		velocity.x -= 10
	else:
		velocity.x = left_right*SPEED
		
	if position.y < 0:
		velocity.y += 10
	elif position.y+$Color.size.y > Global.Spielfeld_Size.y:
		velocity.y -= 10
	else:
		velocity.y = up_down*SPEED
	
	
	move_and_collide(velocity)
	$Camera2D.limit_right = Global.Spielfeld_Size.x
	$Camera2D.limit_bottom = Global.Spielfeld_Size.y
	
	#for i in map.get_used_cells(0):
	if ID == 1:
		for x in range(tile_size*tile_size_multipl):
			for y in range(tile_size*tile_size_multipl):
				var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
				map.set_cell(0,tile_position,1,Vector2i(0,0))
	if ID == 2:
		for x in range(tile_size*tile_size_multipl):
			for y in range(tile_size*tile_size_multipl):
				var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
				map.set_cell(0,tile_position,2,Vector2i(0,0))
