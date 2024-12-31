extends Node2D


@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
var coin_set_value = 5
var is_npc = false


var explode_pos = null
var id = 0
			
			
func _ready():
	set_process(false)
	

func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			change_size.rpc()
			if not $pickup.is_playing():
				queue_free()
			return
	
	
@rpc("any_peer","call_local")
func change_size():
	if not $Area2D/CollisionShape2D.disabled:
		$Area2D/CollisionShape2D.disabled = true
		$pickup.play("pickup")
		
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		id = area.get_parent().name.to_int()
		if not area.get_parent().is_in_group("npc") and id == multiplayer.get_unique_id():
			Global.coin_sound = true
			level.main.get_node("money/coin_display").set_money(coin_set_value)
		set_process(true)
