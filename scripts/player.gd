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
var loaded = false
@export var score = 0

@onready var camera = $Camera2D

@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
@onready var input = $PlayerInput

func _ready():
	main.get_node("UI").hide()
	map.reset_floor()
	get_parent().get_parent().reset_bomben(name.to_int(), 4)
	get_tree().paused = false
	if player == multiplayer.get_unique_id():
		camera.make_current()
	color_change()

	
func _exit_tree():
	get_tree().paused = true
	map.reset_floor()
	get_parent().get_parent().reset_bomben(name.to_int(), 4)
	get_tree().paused = false
		

func _physics_process(delta):
	if not loaded:
		loaded = true
		painter()
		score_counter.rpc()
	
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
	get_parent().get_parent().get_node("CanvasLayer/Wertung").get_node(str(name)).call_deferred("wertung",name.to_int())
	bombe_attack()


func bombe_attack():
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("boom"):
			area.get_parent().aktivate_bombe.rpc(name.to_int(), color_cell, area.get_parent())


func painter():
	if get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
		color_cell = 1
		paint.rpc(1)
	if get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
		color_cell = 2
		paint.rpc(2)
	if get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
		color_cell = 3
		paint.rpc(3)
	if get_parent().get_child(3) != null and get_parent().get_child(3).name == name:
		color_cell = 4
		paint.rpc(4)
	if get_parent().get_child(4) != null and get_parent().get_child(4).name == name:
		color_cell = 5
		paint.rpc(5)
	if get_parent().get_child(5) != null and get_parent().get_child(5).name == name:
		color_cell = 6
		paint.rpc(6)
	
	
@rpc("any_peer","call_local")
func score_counter():
	score = 0
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == color_cell:
			score+=1
		

@rpc("any_peer","call_local")
func paint(tile: int):
	var radius = Vector2i($Color.size.x,$Color.size.y)
	var tile_position_top_left = map.local_to_map(Vector2i(position.x,position.y))
	var tile_position_down_right = map.local_to_map(Vector2i(position.x+radius.x,position.y+radius.y))
	if tile_position_down_right not in map.get_used_cells(0):
		return
	if tile_position_top_left not in map.get_used_cells(0):
		return
	for x in range(0, radius.x):
		for y in range(0, radius.y):
			var tile_position = map.local_to_map(Vector2i(position.x+x,position.y+y))
			map.set_cell(0,tile_position,tile,Vector2i(0,0))
		
func color_change():
	if get_parent().get_child(0) != null and get_parent().get_child(0).name == name:
		get_node("Color").set_color(Color.GREEN)
	if get_parent().get_child(1) != null and get_parent().get_child(1).name == name:
		get_node("Color").set_color(Color.DARK_RED)
	if get_parent().get_child(2) != null and get_parent().get_child(2).name == name:
		get_node("Color").set_color(Color.DARK_BLUE)
	if get_parent().get_child(3) != null and get_parent().get_child(3).name == name:
		get_node("Color").set_color(Color.DEEP_SKY_BLUE)
	if get_parent().get_child(4) != null and get_parent().get_child(4).name == name:
		get_node("Color").set_color(Color.VIOLET)
	if get_parent().get_child(5) != null and get_parent().get_child(5).name == name:
		get_node("Color").set_color(Color.YELLOW)
