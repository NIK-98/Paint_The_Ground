extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
var attack_bombe = null

const  bomb_radius = 64*2
	

func aktivate_bombe(cell: int, clean: Node2D):
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var tile_position = map.local_to_map(Vector2(clean.position.x+x,clean.position.y+y))
			map.set_cell(0,tile_position,cell,Vector2i(0,0))
	clean.queue_free()
