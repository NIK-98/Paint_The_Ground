extends TileMapLayer

var bereit_count = 0
var portal_path = []

@onready var wall = get_node("../wall")

var array_floor = []
var dict_floor_with_portal_id = {
	1: {
		
	},
	2: {
		
	},
	3: {
		
	},
	4: {
		
	}
}

var max_portal_ids: int


@rpc("any_peer","call_local")
func reset_floor():
	if get_node("../loby").tp_mode:
		tp_floor()
	else:
		normal_floor()
	wall.add_wall()
	level_bereit_check.rpc_id(1)
			

@rpc("any_peer","call_local")
func level_bereit_check():
	bereit_count += 1
	if bereit_count == len(get_parent().playerlist):
		get_parent().start_button_gedrückt.rpc()
		bereit_count = 0


func normal_floor(filds:= Vector2i(2,2)):
	var teiler_x = 0
	var teiler_y = 0
	var portal_id_spalte = 1
	var portal_id = portal_id_spalte
	max_portal_ids = filds.x*filds.y
	array_floor = []
	dict_floor_with_portal_id = {
		1: {
			
		},
		2: {
			
		},
		3: {
			
		},
		4: {
			
		}
	}
	for x in range(Global.Spielfeld_Size.x):
		teiler_x += 1
		if teiler_x > floor(Global.Spielfeld_Size.x/filds.x):
			teiler_x = 0
			portal_id_spalte = portal_id+1
		portal_id = portal_id_spalte
		for y in range(Global.Spielfeld_Size.y):
			teiler_y += 1
			if teiler_y == floor(Global.Spielfeld_Size.y/filds.y):
				teiler_y = 0
				if y < Global.Spielfeld_Size.y-1:
					portal_id += 1
			
			if portal_id == 1:
				dict_floor_with_portal_id[1][Vector2i(x,y)] = portal_id
			if portal_id == 2:
				dict_floor_with_portal_id[2][Vector2i(x,y)] = portal_id
			if portal_id == 3:
				dict_floor_with_portal_id[3][Vector2i(x,y)] = portal_id
			if portal_id == 4:
				dict_floor_with_portal_id[4][Vector2i(x,y)] = portal_id
			array_floor.append(Vector2i(x,y))
	BetterTerrain.set_cells(self, array_floor, 0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	
	
func tp_floor(filds:= Vector2i(2,2)):
	array_floor = []
	var teiler_x = 0
	var teiler_y = 0
	var portal_id_spalte = 1
	var portal_id = portal_id_spalte
	max_portal_ids = filds.x*filds.y
	dict_floor_with_portal_id = {
		1: {
			
		},
		2: {
			
		},
		3: {
			
		},
		4: {
			
		}
	}
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
					
			if portal_id == 1:
				dict_floor_with_portal_id[1][Vector2i(x,y)] = portal_id
			if portal_id == 2:
				dict_floor_with_portal_id[2][Vector2i(x,y)] = portal_id
			if portal_id == 3:
				dict_floor_with_portal_id[3][Vector2i(x,y)] = portal_id
			if portal_id == 4:
				dict_floor_with_portal_id[4][Vector2i(x,y)] = portal_id
			array_floor.append(Vector2i(x,y))
	
	BetterTerrain.set_cells(self,array_floor,0)
	
	#portal pfade:
	for port_in in range(1,max_portal_ids+1):
		for port_out in range(1,max_portal_ids+1):
			if port_in == port_out:
				continue
			portal_path.append([port_in,port_out])
			
	
	#create portall
	for ids in range(1,max_portal_ids+1):
		for teile in dict_floor_with_portal_id[ids]:
			if dict_floor_with_portal_id[ids].get(teile) != ids:
				continue
			BetterTerrain.set_cell(self,Vector2i(teile.x+0,teile.y+0),5)
			BetterTerrain.set_cell(self,Vector2i(teile.x+1,teile.y+0),5)
			BetterTerrain.set_cell(self,Vector2i(teile.x+0,teile.y+1),5)
			BetterTerrain.set_cell(self,Vector2i(teile.x+1,teile.y+1),5)
			break
	
	BetterTerrain.update_terrain_cells(self, array_floor)
				
			
			
func get_next_field(current_feld: int):
	var next_fields = []
	for fields in range(1,max_portal_ids+1):
		if fields == current_feld:
			continue
		next_fields.append(fields)
	if next_fields.is_empty():
		return null
	return next_fields.pick_random()
	

func tp_to(player: CharacterBody2D, next_feld: int):
	player.position = map_to_local(dict_floor_with_portal_id[next_feld].keys()[0])


func is_vaild_portal(pos: Vector2):
	var map_pos = local_to_map(pos)
	if get_cell_source_id(map_pos) == 5:
		return true
	else:
		return false
		

func is_portal_id_ok(map_pos: Vector2i,feld: int):
	if not get_parent().get_node("loby").tp_mode:
		return true
	if map_pos in dict_floor_with_portal_id[feld]:
		return true
	else:
		return false
		

func get_tp_feld(pos: Vector2):
	var map_pos = local_to_map(pos)
	if map_pos in dict_floor_with_portal_id[1]:
		return [map_pos,1]
	elif map_pos in dict_floor_with_portal_id[2]:
		return [map_pos,2]
	elif map_pos in dict_floor_with_portal_id[3]:
		return [map_pos,3]
	elif map_pos in dict_floor_with_portal_id[4]:
		return [map_pos,4]
	else:
		return null
				
			

func get_felder_summe():
	return array_floor.size()
