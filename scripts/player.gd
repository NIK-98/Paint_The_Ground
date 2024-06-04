extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")

const SPEED = 20
var spawn = position
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5

@onready var camera = $Camera2D

@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
@onready var input = $PlayerInput

func _ready():
	if player == multiplayer.get_unique_id():
		camera.make_current()
	reste_score.rpc()
	color_change()
	map.reset_floor.rpc()
	

func _physics_process(delta):
	if position.x < 0:
		velocity.x += 10
	elif position.x+$Color.size.x > Global.Spielfeld_Size.x:
		velocity.x -= 10
	elif position.y < 0:
		velocity.y += 10
	elif position.y+$Color.size.y > Global.Spielfeld_Size.y:
		velocity.y -= 10
	else:
		velocity = input.move*SPEED

	$Camera2D.limit_right = Global.Spielfeld_Size.x
	$Camera2D.limit_bottom = Global.Spielfeld_Size.y
	move_and_collide(velocity)
	if (velocity.x != 0 or velocity.y != 0):
		if get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
			paint.rpc(1)
		if get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
			paint.rpc(2)
		if get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
			paint.rpc(3)

@rpc("any_peer","call_local")
func paint(tile: int):
	for x in range(tile_size*tile_size_multipl):
		for y in range(tile_size*tile_size_multipl):
			var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
			map.set_cell(0,tile_position,tile,Vector2i(0,0))
		
func color_change():
	if get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
		get_node("Color").set_color(Color(255,0,0))
	if get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
		get_node("Color").set_color(Color(0,0,255))
	if get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
		get_node("Color").set_color(Color(0,255,0))
		
		
@rpc("any_peer","call_local")
func reste_score():
	if len(Global.score_list) == 1 and get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
		get_parent().get_parent().get_node("Control/CanvasLayer/Wertung").get_child(0).queue_free()
	if len(Global.score_list) == 2 and get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
		get_parent().get_parent().get_node("Control/CanvasLayer/Wertung").get_child(1).queue_free()
	if len(Global.score_list) == 3 and get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
		get_parent().get_parent().get_node("Control/CanvasLayer/Wertung").get_child(2).queue_free()
