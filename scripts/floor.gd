extends TileMapLayer

@onready var main = get_parent().get_parent().get_parent()

var bereit_count = 0


@rpc("any_peer","call_local")
func reset_floor():
	var array_floor = []
	for x in range(Global.Spielfeld_Size.x):
		for y in range(Global.Spielfeld_Size.y):
			array_floor.append(Vector2i(x,y))
	BetterTerrain.set_cells(self,array_floor,0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	level_bereit_check.rpc_id(1)
			

@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0
	
			
func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
	
	
	
