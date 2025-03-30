extends TileMapLayer

func add_wall():
	var rand_cells = []
	for ou in range(-1,(Global.Standard_Spielfeld_Size*get_parent().map_faktor).x+1):
		rand_cells.append(Vector2i(ou,-1))
		rand_cells.append(Vector2i(ou,(Global.Standard_Spielfeld_Size*get_parent().map_faktor).y))
	
	for rl in range(-1,(Global.Standard_Spielfeld_Size*get_parent().map_faktor).y+1):
		rand_cells.append(Vector2i(-1,rl))
		rand_cells.append(Vector2i((Global.Standard_Spielfeld_Size*get_parent().map_faktor).x,rl))
			
	BetterTerrain.set_cells(self, rand_cells, 0)
	BetterTerrain.update_terrain_cells(self, rand_cells)
