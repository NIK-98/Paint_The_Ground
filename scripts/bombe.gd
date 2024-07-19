extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 4
	

func aktivate_bombe(cell: int, clean: Node2D):	
	var tile_position = map.local_to_map(clean.position)
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			map.set_cell(0, pos, cell, Vector2i(0,0))
	if not OS.has_feature("dedicated_server"):
		if multiplayer.is_server():
			clean.queue_free()
	else:
		print(1)
		clean.queue_free()
