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
var Gametriggerstart = false
@export var is_starting = false
@export var score = 0

@onready var camera = $Camera2D

@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
@onready var input = $PlayerInput
	
	
func _ready():
	$CanvasLayer/Winner.visible = false
	$CanvasLayer/Los.visible = false
	main.get_node("UI").hide()
	if player == multiplayer.get_unique_id():
		camera.make_current()
	color_change(name)

func _physics_process(delta):
	if not loaded:
		loaded = true
		painter(name)
		score_counter()
	
	if not get_parent().get_parent().get_node("CanvasLayer/Start").visible:
		if not Gametriggerstart:
			Gametriggerstart = true
			map.reset_floor()
			Check_Time_Visible.rpc()
			get_parent().get_parent().get_node("Timer").start()
		if get_parent().get_parent().get_node("CanvasLayer/Time").visible and not get_parent().get_parent().Time_out:
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
				painter(name)
			score_counter()
			if get_parent().get_parent().get_node("CanvasLayer/Wertung").get_node(str(name)) != null:
				get_parent().get_parent().get_node("CanvasLayer/Wertung").get_node(str(name)).wertung(name.to_int())
			bombe_attack()
		if get_parent().get_parent().Time_out:
			ende.rpc_id(name.to_int())
			

@rpc("any_peer","call_local")
func Check_Time_Visible():
	for i in get_parent().get_parent().get_node("CanvasLayer").get_children():
		if i.is_in_group("time"):
			if not i.visible:
				i.visible = true
	

@rpc("call_local")
func ende():
	Global.Gameover = false
	for i in get_parent().get_parent().get_node("CanvasLayer/Wertung").get_children():
		if i.text.to_int() > score:
			$CanvasLayer/Los.visible = true
	if not $CanvasLayer/Los.visible:
		$CanvasLayer/Winner.visible = true
			
			
func _input(event):
	if Input.is_action_just_pressed("exit"):
		if multiplayer.is_server():
			multiplayer.multiplayer_peer.disconnect_peer(name.to_int())
			multiplayer.multiplayer_peer = null
			emit_signal("add_player")			
			emit_signal("del_player")
			emit_signal("del_score")
			get_tree().get_nodes_in_group("Level")[0].queue_free()
			get_tree().change_scene_to_file("res://sceens/main.tscn")
			return
		get_parent().get_parent().get_node("CanvasLayer/Wertung").get_node(str(name)).rpc("remove_node",name.to_int())
		kicked(name.to_int(), "Verbindung Selber beendet!")
		get_tree().change_scene_to_file("res://sceens/main.tscn")
		

@rpc("any_peer","call_local")
func kicked(id, antwort):
	multiplayer.multiplayer_peer.disconnect_peer(id)
	multiplayer.multiplayer_peer = null
	OS.alert("Verbindung verloren!", antwort)


func bombe_attack():
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("boom"):
			area.get_parent().aktivate_bombe.rpc(name.to_int(), color_cell, area.get_parent())
			get_parent().get_parent().spawn_new_bombe.rpc()


func painter(name: String):
	for i in get_parent().get_child_count():
		if get_parent().get_child(i).name == name:
			color_cell = i+1
	paint.rpc(color_cell)
	
	
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
	var tile_position = map.local_to_map(Vector2i(position.x,position.y))
	for x in range(0,2):
		for y in range(0,2):
			map.set_cell(0,Vector2i(tile_position.x+x,tile_position.y+y),tile,Vector2i(0,0))
		
		
func color_change(name: String):
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(name) != null and i == 0:
			get_node("Color").set_color(Color.GREEN)
		if get_parent().get_node(name) != null and i == 1:
			get_node("Color").set_color(Color.DARK_RED)
		if get_parent().get_node(name) != null and i == 2:
			get_node("Color").set_color(Color.DARK_BLUE)
		if get_parent().get_node(name) != null and i == 3:
			get_node("Color").set_color(Color.DEEP_SKY_BLUE)
		if get_parent().get_node(name) != null and i == 4:
			get_node("Color").set_color(Color.VIOLET)
		if get_parent().get_node(name) != null and i == 5:
			get_node("Color").set_color(Color.YELLOW)
