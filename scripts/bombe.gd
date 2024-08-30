extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 6
var explode_pos = null
var celle = 0
		
		
func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_bombe.rpc(celle, explode_pos)
			queue_free()
			return
			

@rpc("any_peer","call_local")
func aktivate_bombe(cell: int, pos: Vector2):
	var tile_position = map.local_to_map(pos)
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var new_pos = Vector2i(x, y) + tile_position
			if map.get_cell_source_id(new_pos) != -1:
				map.set_cell(new_pos,cell,Vector2i(0, 0),0)
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().change_paint_rad()
		explode_pos = area.get_parent().position
		celle = area.get_parent().color_cell
