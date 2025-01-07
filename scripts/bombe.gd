extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 8
var explode_pos = null
var celle = 0

func _ready():
	set_process(false)
				
		
func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_bombe.rpc(celle, explode_pos)
			queue_free()
			return
			

@rpc("any_peer","call_local")
func aktivate_bombe(cell: int, pos: Vector2):
	var tile_position = map.local_to_map(pos)
	var bomb_array = []
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			if map.get_cell_source_id((Vector2i(x,y)+tile_position)) != -1 and map.get_cell_source_id((Vector2i(x,y)+tile_position)) not in level.block_cells and (Vector2i(x,y)+tile_position).distance_to(tile_position) < bomb_radius:
				if map.get_cell_source_id((Vector2i(x,y)+tile_position)) == cell:
					continue
				bomb_array.push_back((Vector2i(x,y)+tile_position))
	print(bomb_array.size())
	map.set_cells_terrain_connect(bomb_array,0,cell)
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		celle = area.get_parent().color_cell
		if not area.get_parent().is_in_group("npc") and area.get_parent().name.to_int() == multiplayer.get_unique_id():
			Global.bombe_sound = true
		set_process(true)
