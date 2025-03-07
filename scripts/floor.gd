extends TileMapLayer

var bereit_count = 0


@rpc("any_peer","call_local")
func reset_floor():
	tp_floor()
	level_bereit_check.rpc_id(1)
			

@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0
		

func normal_floor():
	var array_floor = []
	for x in range(Global.Spielfeld_Size.x):
		for y in range(Global.Spielfeld_Size.y):
			array_floor.append(Vector2i(x,y))
	BetterTerrain.set_cells(self,array_floor,0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	
	
func tp_floor(portalfeld_factor: int = 4, portal_seed: int = 0):
	var array_floor = []
	var array_floor_with_portal_id = []
	var teiler_x = 0
	var teiler_y = 0
	var portal_id = 0
	var field_counter = 0
	var tp_filds_number = floor(Global.Spielfeld_Size.x/portalfeld_factor) * floor(Global.Spielfeld_Size.y/(portalfeld_factor-1))
	print(tp_filds_number)
	for x in range(Global.Spielfeld_Size.x):
		teiler_x += 1
		field_counter += 1
		if teiler_x > floor(Global.Spielfeld_Size.x/portalfeld_factor):
			teiler_x = 0
			continue
		for y in range(Global.Spielfeld_Size.y):
			teiler_y += 1
			field_counter += 1
			if teiler_y == floor(Global.Spielfeld_Size.y/(portalfeld_factor-1)):
				teiler_y = 0
				if y != Global.Spielfeld_Size.y-1:
					continue
			array_floor_with_portal_id.append([Vector2i(x,y),portal_id])
			array_floor.append(Vector2i(x,y))
			if field_counter >= tp_filds_number:
				field_counter = 0
				portal_id += 1
	var count = 0
	for id in array_floor_with_portal_id:
		if id[1] == 0:
			count += 1
			print(count)
		if id[1] == 9:
			count += 1
			print(count)
		
			
	BetterTerrain.set_cells(self,array_floor,0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	
	
func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
