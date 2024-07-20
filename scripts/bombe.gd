extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 4
	

@rpc("any_peer","call_local", "unreliable")
func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			map.set_cell(0, pos, cell, Vector2i(0,0))
	if is_multiplayer_authority():
		queue_free()
	


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		aktivate_bombe.rpc(area.get_parent().color_cell)
		
		
