extends TileMapLayer

var bereit_count = 0

@rpc("any_peer","call_local")
func add_wall():
	var rand_cells = []
	for ou in range(-1,Global.Spielfeld_Size.x+1):
		rand_cells.append(Vector2i(ou,-1))
		rand_cells.append(Vector2i(ou,Global.Spielfeld_Size.y))
	
	for rl in range(-1,Global.Spielfeld_Size.y+1):
		rand_cells.append(Vector2i(-1,rl))
		rand_cells.append(Vector2i(Global.Spielfeld_Size.x,rl))
			
	BetterTerrain.set_cells(self, rand_cells, 0)
	BetterTerrain.update_terrain_cells(self, rand_cells)
	level_bereit_check.rpc_id(1)


@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0
