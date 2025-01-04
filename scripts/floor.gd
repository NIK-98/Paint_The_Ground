extends TileMapLayer

@onready var main = get_parent().get_parent().get_parent()

var bereit_count = 0


@rpc("any_peer","call_local")
func reset_floor():
	var floor_array = []
	var tile_position = local_to_map(Global.Spielfeld_Size)
	for x in range(tile_position.x):
		for y in range(tile_position.y):
			floor_array.append(Vector2i(x,y))
	set_cells_terrain_connect(floor_array,0,0)
	level_bereit_check.rpc_id(1)
			

@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0
	
			
func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
	
