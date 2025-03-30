extends TileMapLayer

signal npc_teleported(npc, target_pos)

var bereit_count = 0
var portal_path = []

@onready var wall = get_node("../wall")

var array_floor = []
var array_floor_with_portal_id = []
var dict_floor_with_portal_id = {
	"1": {
		
	},
	"2": {
		
	},
	"3": {
		
	},
	"4": {
		
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
	array_floor_with_portal_id = []
	dict_floor_with_portal_id = {
		"1": {
			
		},
		"2": {
			
		},
		"3": {
			
		},
		"4": {
			
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
				dict_floor_with_portal_id["1"][Vector2i(x,y)] = portal_id
			if portal_id == 2:
				dict_floor_with_portal_id["2"][Vector2i(x,y)] = portal_id
			if portal_id == 3:
				dict_floor_with_portal_id["3"][Vector2i(x,y)] = portal_id
			if portal_id == 4:
				dict_floor_with_portal_id["4"][Vector2i(x,y)] = portal_id
			array_floor_with_portal_id.append([Vector2i(x,y),portal_id])
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
	array_floor_with_portal_id = []
	dict_floor_with_portal_id = {
		"1": {
			
		},
		"2": {
			
		},
		"3": {
			
		},
		"4": {
			
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
				dict_floor_with_portal_id["1"][Vector2i(x,y)] = portal_id
			if portal_id == 2:
				dict_floor_with_portal_id["2"][Vector2i(x,y)] = portal_id
			if portal_id == 3:
				dict_floor_with_portal_id["3"][Vector2i(x,y)] = portal_id
			if portal_id == 4:
				dict_floor_with_portal_id["4"][Vector2i(x,y)] = portal_id
			array_floor_with_portal_id.append([Vector2i(x,y),portal_id])
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
		for teile in array_floor_with_portal_id:
			if teile[1] != ids:
				continue
			BetterTerrain.set_cell(self,Vector2i(teile[0].x+0,teile[0].y+0),5)
			BetterTerrain.set_cell(self,Vector2i(teile[0].x+1,teile[0].y+0),5)
			BetterTerrain.set_cell(self,Vector2i(teile[0].x+0,teile[0].y+1),5)
			BetterTerrain.set_cell(self,Vector2i(teile[0].x+1,teile[0].y+1),5)
			break
	
	BetterTerrain.update_terrain_cells(self, array_floor)
				
			
			
func get_next_field(current_feld: int):
	var next_fields = []
	for fields in range(1,max_portal_ids+1):
		if fields == current_feld:
			continue
		next_fields.append(fields)
	return next_fields.pick_random()
	
			
func tp_to(pos: Vector2, current_feld: int):
	var map_pos = local_to_map(pos)
	if get_cell_source_id(map_pos) != 5:
		return []
	var feld_pos = -1
	var ziel_portal = null
	for portal in dict_floor_with_portal_id[str(current_feld)]:
		if map_pos == portal:
			feld_pos = current_feld
			var valid_fields = []
			for f in range(1, max_portal_ids + 1):
				if f != feld_pos:
					valid_fields.append(f)	
			var end_portal = valid_fields.pick_random()
			if [feld_pos, end_portal] in portal_path:
				ziel_portal = [feld_pos, end_portal]
				break
	if ziel_portal == null:
		return [map_to_local(Vector2i(0, 0)), feld_pos]
	for portal in dict_floor_with_portal_id[str(ziel_portal[1])]:
		return [map_to_local(portal), feld_pos]
	return []
	

func tp_to_signal(npc: CharacterBody2D, pos: Vector2, current_feld: int):
	var result = tp_to(pos,current_feld)
	if not result.is_empty():
		emit_signal("npc_teleported", npc, result[0])
		return result
	else:
		return result


func is_portal_id_ok(map_pos: Vector2i,feld: int):
	if not get_parent().get_node("loby").tp_mode:
		return true
	if [map_pos,feld] in array_floor_with_portal_id:
		return true
	else:
		return false
		

func get_tp_feld(pos: Vector2):
	var map_pos = local_to_map(pos)
	if map_pos in dict_floor_with_portal_id["1"]:
		return [map_pos,1]
	elif map_pos in dict_floor_with_portal_id["2"]:
		return [map_pos,2]
	elif map_pos in dict_floor_with_portal_id["3"]:
		return [map_pos,3]
	elif map_pos in dict_floor_with_portal_id["4"]:
		return [map_pos,4]
				
			

func get_felder_summe():
	return array_floor.size()


func _on_npc_teleported(npc: Variant, target_pos: Variant) -> void:
	npc.global_position = target_pos
