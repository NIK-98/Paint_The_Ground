extends Node2D


@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
@onready var Players = get_parent().get_parent().get_node("Players")


var id = 0
@export var powerupid = 0
@export var distroy = null
		

func _ready():
	if powerupid == 0: # doppelter grundspeed
		$Sprite2D.texture = load("res://assets/powerups/speedup.png")
	if powerupid == 1: # größerer färbradius
		$Sprite2D.texture = load("res://assets/powerups/bigrad.png")
	if powerupid == 2: # unübermalbares färben
		$Sprite2D.texture = load("res://assets/powerups/protect.png")
	set_process(false)
	
	
func _process(_delta: float) -> void:
	if distroy != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			clean_power.rpc(distroy)
	

@rpc("any_peer","call_local")
func clean_power(node_path: NodePath):
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		var object = get_node(node_path)
		if object:
			object.queue_free()
			
			
@rpc("any_peer","call_local")
func aktivate_powerup(player_id: int):
	if powerupid == 0: # doppelter grundspeed
		var ist_da_index = 0
		var ist_da = false
		for aktive in range(len(Players.get_node(str(player_id)).powerups)):
			if Players.get_node(str(player_id)).powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			Players.get_node(str(player_id)).SPEED = Players.get_node(str(player_id)).first_speed
			Players.get_node(str(player_id)).SPEED *= 1.5
			Players.get_node(str(player_id)).powerups[ist_da_index][0] = powerupid
			Players.get_node(str(player_id)).powerups[ist_da_index][1] = true
	if powerupid == 1: # größerer färbradius
		var ist_da_index = 1
		var ist_da = false
		for aktive in range(len(Players.get_node(str(player_id)).powerups)):
			if Players.get_node(str(player_id)).powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			Players.get_node(str(player_id)).paint_radius = Global.painting_rad
			Players.get_node(str(player_id)).paint_radius = 4
			Players.get_node(str(player_id)).powerups[ist_da_index][0] = powerupid
			Players.get_node(str(player_id)).powerups[ist_da_index][1] = true
	if powerupid == 2: # unübermalbares färben
		var ist_da_index = 2
		var ist_da = false
		for aktive in range(len(Players.get_node(str(player_id)).powerups)):
			if Players.get_node(str(player_id)).powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			level.cell_blocker(true, Players.get_node(str(player_id)).name.to_int())
			Players.get_node(str(player_id)).powerups[ist_da_index][0] = powerupid
			Players.get_node(str(player_id)).powerups[ist_da_index][1] = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		id = area.get_parent().name.to_int()
		aktivate_powerup(id)
		distroy = get_path()
		set_process(true)
		return
