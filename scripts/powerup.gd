extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()


var explode_pos = null
@export var powerupid = 0

				

func _ready():
	if powerupid == 0: # doppelter grundspeed
		$Sprite2D.texture = load("res://assets/powerups/speedup.png")
	if powerupid == 1: # größerer färbradius
		$Sprite2D.texture = load("res://assets/powerups/bigrad.png")
	if powerupid == 2: # unübermalbares färben
		$Sprite2D.texture = load("res://assets/powerups/protect.png")
		

func _physics_process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			queue_free()
			return
		

@rpc("any_peer","call_local")
func aktivate_powerup(player: CharacterBody2D):
	if powerupid == 0: # doppelter grundspeed
		var ist_da_index = 0
		var ist_da = false
		for aktive in range(len(player.powerups)):
			if player.powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			player.SPEED = player.first_speed
			player.SPEED *= 2
			player.powerups[ist_da_index][0] = powerupid
			player.powerups[ist_da_index][1] = true
	if powerupid == 1: # größerer färbradius
		var ist_da_index = 1
		var ist_da = false
		for aktive in range(len(player.powerups)):
			if player.powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			player.paint_radius = Global.painting_rad
			player.paint_radius = 6
			player.powerups[ist_da_index][0] = powerupid
			player.powerups[ist_da_index][1] = true
	if powerupid == 2: # unübermalbares färben
		var ist_da_index = 2
		var ist_da = false
		for aktive in range(len(player.powerups)):
			if player.powerups[aktive][0] == powerupid:
				ist_da_index = aktive
				ist_da = true
		if not ist_da:
			level.cell_blocker.rpc(true, player.name.to_int())
			player.powerups[ist_da_index][0] = powerupid
			player.powerups[ist_da_index][1] = true
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		aktivate_powerup.rpc(area.get_parent())
