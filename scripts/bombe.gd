extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 6
var clean = ""
	
	
func _process(_delta):
	for area in $Area2D.get_overlapping_areas():
		if area.get_parent().is_in_group("player"):
			area.get_parent().change_paint_rad()
			aktivate_bombe.rpc(area.get_parent().color_cell)
	level.del_boom.rpc(clean)
	clean = ""
	
@rpc("any_peer","call_local")
func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			if map.get_cell_source_id(0,pos) != -1:
				map.set_cell(0, pos, cell, Vector2i(0,0))
	clean = name
