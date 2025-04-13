extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
@onready var Players = get_parent().get_parent().get_node("Players")


var explode_pos = null
var id = 0
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
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_powerup.rpc(id)
			queue_free()
			return
	
@rpc("call_local")
func aktivate_powerup(player_id: int):
	if Players.get_node(str(player_id)).get_node("powertimers").get_child_count() == 3:
		return
	if Players.get_node(str(player_id)).name.to_int() == multiplayer.get_unique_id() or Players.get_node(str(player_id)).name.to_int() == 2 or Players.get_node(str(player_id)).name.to_int() == 3 or Players.get_node(str(player_id)).name.to_int() == 4:
		if powerupid == 0: # doppelter grundspeed
			if not Players.get_node(str(player_id)).powerups[powerupid][0] == powerupid:
				Players.get_node(str(player_id)).SPEED = Players.get_node(str(player_id)).first_speed
				Players.get_node(str(player_id)).SPEED *= 1.5
				Players.get_node(str(player_id)).powerups[powerupid][0] = powerupid
				Players.get_node(str(player_id)).powerups[powerupid][1] = true
		if powerupid == 1: # größerer färbradius
			if not Players.get_node(str(player_id)).powerups[powerupid][0] == powerupid:
				Players.get_node(str(player_id)).paint_radius = Global.painting_rad
				Players.get_node(str(player_id)).paint_radius = 4
				Players.get_node(str(player_id)).powerups[powerupid][0] = powerupid
				Players.get_node(str(player_id)).powerups[powerupid][1] = true
		if powerupid == 2: # unübermalbares färben
			if not Players.get_node(str(player_id)).powerups[powerupid][0] == powerupid:
				level.cell_blocker.rpc(true, Players.get_node(str(player_id)).color_cell)
				Players.get_node(str(player_id)).powerups[powerupid][0] = powerupid
				Players.get_node(str(player_id)).powerups[powerupid][1] = true
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		id = area.get_parent().name.to_int()
		if not area.get_parent().is_in_group("npc") and id == multiplayer.get_unique_id():
			Global.powerup_sound = true
		set_process(true)
