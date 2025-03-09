extends TileMapLayer

var bereit_count = 0
var portal_path = []
var tp_mode = true

@onready var wall = get_node("../wall")

var array_floor_with_portal_id = []
var max_portal_ids: int


@rpc("any_peer","call_local")
func reset_floor():
	if tp_mode:
		tp_floor()
	else:
		normal_floor()
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
	
	
	
func tp_floor(filds:= Vector2i(4,3)):
	var array_floor = []
	var teiler_x = 0
	var teiler_y = 0
	var portal_id_spalte = 1
	var portal_id = portal_id_spalte
	max_portal_ids = filds.x*filds.y
	array_floor_with_portal_id = []
	for x in range(Global.Spielfeld_Size.x):
		teiler_x += 1
		if teiler_x > floor(Global.Spielfeld_Size.x/filds.x):
			teiler_x = 0
			portal_id_spalte = portal_id+1
			for y in range(Global.Spielfeld_Size.y):	
				BetterTerrain.set_cell(wall,Vector2i(x,y),0)
			continue
		portal_id = portal_id_spalte
		for y in range(Global.Spielfeld_Size.y):
			teiler_y += 1
			if teiler_y == floor(Global.Spielfeld_Size.y/filds.y):
				teiler_y = 0
				if y < Global.Spielfeld_Size.y-1:
					portal_id += 1
					BetterTerrain.set_cell(wall,Vector2i(x,y),0)
					continue
			array_floor_with_portal_id.append([Vector2i(x,y),portal_id])
			array_floor.append(Vector2i(x,y))
	
	BetterTerrain.set_cells(self,array_floor,0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	
	#portal pfade:
	for port_in in range(1,max_portal_ids+1):
		for port_out in range(1,max_portal_ids+1):
			if port_in == port_out:
				continue
			portal_path.append([port_in,port_out])
			
	
	#create portall
	for ids in range(1,max_portal_ids+1):
		for teile in array_floor_with_portal_id:
			if teile[1] != ids:
				continue
			BetterTerrain.set_cell(self,teile[0],-1)#-1 durch portal zelle ersetzen
			break


func tp_to(pos: Vector2):
	var map_pos = local_to_map(pos)
	if BetterTerrain.get_cell(self,map_pos) != -1:
		return null
	var ziel_portal: Array
	for portal in array_floor_with_portal_id:
		if map_pos == portal[0]:
			var end_portal = randi_range(1,max_portal_ids)
			if [portal[1],end_portal] in portal_path:
				ziel_portal = [portal[1],end_portal]
				break
	for portal in array_floor_with_portal_id:
		if ziel_portal.is_empty():
			return map_to_local(Vector2i(0,0))
		if ziel_portal[1] == portal[1]:
			return map_to_local(portal[0])
			

func get_felder_summe(total_size: Vector2, tile_size: Vector2):
	return (total_size.x/tile_size.y)*(total_size.y/tile_size.y)
