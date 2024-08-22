extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 6
var count_aktivate = 0


func _ready():
	if OS.has_feature("dedicated_server"):
		count_aktivate = -1
		
		
func _process(_delta):
	if count_aktivate == len(level.playerlist):
		if is_multiplayer_authority() and not OS.has_feature("dedicated_server"):
			queue_free()
			return
		if OS.has_feature("dedicated_server"):
			queue_free()
			

func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var pos = Vector2i(x, y) + tile_position
			if map.get_cell_source_id(pos) != -1:
				map.set_cell(pos,cell,Vector2i(0, 0),0)
	if multiplayer.get_peers().is_empty():
		queue_free()
		return
	sync_aktive.rpc()


@rpc("any_peer","call_local")
func sync_aktive():
	count_aktivate += 1
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().change_paint_rad()
		aktivate_bombe(area.get_parent().color_cell)
