extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const  bomb_radius = 4
var clean = false
var cleaners_count = 0


func _ready():
	if OS.has_feature("dedicated_server"):
		return
		
		
func _process(_delta):
	clean_boom.rpc()
			

func aktivate_bombe(cell: int, aktivierer):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			map.set_cell(0, pos, cell, Vector2i(0,0))
	cleaners_count += 1
	clean = true
	

@rpc("any_peer","call_local")
func clean_boom():
	if clean:	
		if not OS.has_feature("dedicated_server") and cleaners_count-1 == len(multiplayer.get_peers()):
			queue_free()
		if OS.has_feature("dedicated_server") and cleaners_count == len(multiplayer.get_peers()):
			queue_free()
		
