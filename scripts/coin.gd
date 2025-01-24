extends CharacterBody2D


@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
var coin_set_value = 5
var is_npc = false

const ROW_SPEED = 750
var SPEED = ROW_SPEED


var explode_pos = null
var id = 0

var magnet_id = 0
const row_magnet_craft = 350
var magnet_craft = row_magnet_craft
			
			
func _ready():
	set_process(false)
	


func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			if not $Area2D/CollisionShape2D.disabled:
				$Area2D/CollisionShape2D.disabled = true
				$pickup.play("pickup")
			if not $pickup.is_playing():
				queue_free()
				return
				
				
func _physics_process(delta: float) -> void:
	if magnet_id == 0 or magnet_id == -1:
		return
	if level.get_node("Players").has_node(str(magnet_id)) and level.get_node("Players").get_node(str(magnet_id)).magnet:
		if position.distance_to(level.get_node("Players").get_node(str(magnet_id)).position) > magnet_craft:
			magnet_id = 0
			return
		velocity = position.direction_to(level.get_node("Players").get_node(str(magnet_id)).position)*SPEED
		move_and_slide()
		
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		id = area.get_parent().name.to_int()
		magnet_id = -1
		if not area.get_parent().is_in_group("npc") and id == multiplayer.get_unique_id():
			Global.coin_sound = true
			level.main.get_node("money/coin_display").set_money(coin_set_value)
		set_process(true)
