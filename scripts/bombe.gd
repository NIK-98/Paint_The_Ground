extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 4
var cleaners_count = 0
			

func aktivate_bombe(cell: int):
	if not OS.has_feature("dedicated_server"):
		var tile_position = map.local_to_map(position)
		for x in range(-bomb_radius,bomb_radius):
			for y in range(-bomb_radius,bomb_radius):
				var pos = Vector2i(x, y) + tile_position
				if map.get_cell_source_id(0,pos) != -1:
					map.set_cell(0, pos, cell, Vector2i(0,0))
		cleaners_count += 1
	clean_boom()
	

func clean_boom():
	if OS.has_feature("dedicated_server"):
		if cleaners_count+1 == len(multiplayer.get_peers()):
			queue_free()
	if is_multiplayer_authority():
		if not OS.has_feature("dedicated_server") and cleaners_count-1 == len(multiplayer.get_peers()):
			queue_free()
		
