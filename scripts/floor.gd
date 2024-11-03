extends TileMapLayer

@onready var main = get_parent().get_parent().get_parent()

var bereit_count = 0


@rpc("any_peer","call_local")
func reset_floor():
	var tile_position = local_to_map(Vector2i(Global.Spielfeld_Size))
	for x in range(tile_position.x):
		for y in range(tile_position.y):
			set_cell(Vector2i(x,y),0,Vector2i(0,0),0)	
	level_bereit_check.rpc_id(1)
			

@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0
	
			
func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
	
