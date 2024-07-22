extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 4


func _ready():
	if OS.has_feature("dedicated_server"):
		return
			

func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			map.set_cell(0, pos, cell, Vector2i(0,0))
		
		
