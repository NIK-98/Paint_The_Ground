extends Node2D


@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
var coin_set_value = 5


var explode_pos = null
var id = 0
			
			
func _ready():
	set_physics_process(false)
	

func _physics_process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			queue_free()
			return
		

func add_coin(player_id: int):
	level.main.get_node("money/coin_display").set_money(coin_set_value)
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		id = area.get_parent().name.to_int()
		level.main.get_node("money/coin_display").set_money(coin_set_value)
		set_physics_process(true)
