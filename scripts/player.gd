extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var main = get_parent().get_parent().get_parent().get_parent()

const SPEED = 20
var spawn = position
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5
var color_cell = 1
@export var score = 0

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
	color_change()
	map.reset_floor.rpc()
	painter()
	score_counter.rpc()


func _exit_tree():
	get_tree().paused = true
	map.reset_floor()
	get_tree().paused = false

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
		painter()
	score_counter.rpc()

func painter():
	if get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
		paint.rpc(1)
		color_cell = 1
	if get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
		paint.rpc(2)
		color_cell = 2
	if get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
		paint.rpc(3)
		color_cell = 3
	
	
@rpc("any_peer","call_local")
func score_counter():
	score = 0
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == color_cell:
			score+=1
		

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
