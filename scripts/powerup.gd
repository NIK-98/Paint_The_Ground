extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
@onready var Players = get_parent().get_parent().get_node("Players")


var explode_pos = null
var id = 0
var is_npc = false
@export var powerupid = 0

				

func _ready():
	if powerupid == 0: # doppelter grundspeed
		$Sprite2D.texture = load("res://assets/powerups/speedup.png")
	if powerupid == 1: # größerer färbradius
		$Sprite2D.texture = load("res://assets/powerups/bigrad.png")
	if powerupid == 2: # unübermalbares färben
		$Sprite2D.texture = load("res://assets/powerups/protect.png")
	set_process(false)
		

func _process(_delta):
	if explode_pos != null:
		if not $Area2D/CollisionShape2D.disabled:
			$Area2D/CollisionShape2D.disabled = true
		if scale > Vector2.ZERO and not is_npc:
			scale.x -= 0.01
			scale.y -= 0.01
		elif multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_powerup.rpc(id)
			queue_free()
			return
		

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
			if multiplayer.is_server() or OS.has_feature("dedicated_server"):
				level.cell_blocker.rpc(true, Players.get_node(str(player_id)).color_cell)
			Players.get_node(str(player_id)).powerups[ist_da_index][0] = powerupid
			Players.get_node(str(player_id)).powerups[ist_da_index][1] = true
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		id = area.get_parent().name.to_int()
		if not area.get_parent().is_in_group("npc"):
			Global.powerup_sound = true
		else:
			is_npc = true
		set_process(true)
