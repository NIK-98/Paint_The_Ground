extends TileMapLayer

@onready var main = get_parent().get_parent().get_parent()


@rpc("any_peer","call_local")
func reset_floor():
	for x in range(Global.Spielfeld_Size.x):
		for y in range(Global.Spielfeld_Size.y):
			var tile_position = local_to_map(Vector2i(x,y))
			set_cell(tile_position,0,Vector2i(0,0),0)
			
			
func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
	
