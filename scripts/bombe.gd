extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 8
var celle = 0
	

@rpc("any_peer","call_local")
func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var new_pos = Vector2i(x, y) + tile_position
			var distance = new_pos.distance_to(tile_position)
			if map.get_cell_source_id(new_pos) != -1 and map.get_cell_source_id(new_pos) not in level.block_cells and distance < bomb_radius:
				map.set_cell(new_pos,cell,Vector2i(0, 0),0)
