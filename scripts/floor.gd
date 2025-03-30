extends TileMapLayer

signal npc_teleported(npc, target_pos)

var bereit_count = 0
var portal_path = []

@onready var wall = get_node("../wall")


var fields:= Vector2i(2,2)


var array_floor = []


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
		

func normal_floor():
	array_floor = []
	for x in range(get_map_size(get_parent().map_faktor).x):
		for y in range(get_map_size(get_parent().map_faktor).y):
			array_floor.append(Vector2i(x,y))
	BetterTerrain.set_cells(self, array_floor, 0)
	BetterTerrain.update_terrain_cells(self, array_floor)
	
	
func get_field_of_tile(tile: Vector2i):
	var anzahl_der_tiles_pro_feld_in_x_richtung = floor(get_map_size(get_parent().map_faktor).x/fields.x)
	var anzahl_der_tiles_pro_feld_in_y_richtung = floor(get_map_size(get_parent().map_faktor).y/fields.y)
	if not get_node("../loby").tp_mode:
		return 0
	var x_feld = floor(tile.x /anzahl_der_tiles_pro_feld_in_x_richtung)
	var y_feld = floor(tile.y /anzahl_der_tiles_pro_feld_in_y_richtung)
	
	var feld = x_feld * fields.y + y_feld
	return feld


func get_tile_coordinates_ralative_to_field(tile: Vector2i):
	var anzahl_der_tiles_pro_feld_in_x_richtung = floor(get_map_size(get_parent().map_faktor).x/fields.x)
	var anzahl_der_tiles_pro_feld_in_y_richtung = floor(get_map_size(get_parent().map_faktor).y/fields.y)
	if not get_node("../loby").tp_mode:
		return tile
	return Vector2i(tile.x % anzahl_der_tiles_pro_feld_in_x_richtung, tile.y % anzahl_der_tiles_pro_feld_in_y_richtung)
	
	
func get_number_of_fields():
	if not get_node("../loby").tp_mode:
		return 1
	return fields.x*fields.y
	
	
func tp_floor():
	array_floor = []
	max_portal_ids = get_number_of_fields()

	for x in range(get_map_size(get_parent().map_faktor).x):
		for y in range(get_map_size(get_parent().map_faktor).y):
			var coords = Vector2i(x,y)
			var in_field_coords = get_tile_coordinates_ralative_to_field(coords)
			if in_field_coords.x == 0 and x != 0 or in_field_coords.y == 0 and y != 0:
				BetterTerrain.set_cell(wall,coords,0) #trenn wall set
			else: 
				array_floor.append(coords)
				if in_field_coords.x in [1,2] and in_field_coords.y in [1,2]:
					BetterTerrain.set_cell(self,coords,5) #portal set
				else:
					BetterTerrain.set_cell(self,coords,0) #felder set

	
	#portal pfade:
	for port_in in range(0,max_portal_ids):
		for port_out in range(0,max_portal_ids):
			if port_in == port_out:
				continue
			portal_path.append([port_in,port_out])
			
	
	BetterTerrain.update_terrain_cells(self, array_floor)


# field is zero based
func field_number_to_field_coord(field: int):
	return Vector2i(field / fields.y, field % fields.y)

# field is zero based
func get_top_left_tile_of_field(field: int):
	var anzahl_der_tiles_pro_feld_in_x_richtung = floor(get_map_size(get_parent().map_faktor).x/fields.x)
	var anzahl_der_tiles_pro_feld_in_y_richtung = floor(get_map_size(get_parent().map_faktor).y/fields.y)
	var field_coord = field_number_to_field_coord(field)
	# plus one, because zero is the border
	return Vector2i(field_coord.x * anzahl_der_tiles_pro_feld_in_x_richtung + 1, field_coord.y * anzahl_der_tiles_pro_feld_in_y_richtung + 1)
	


func tp_to(pos: Vector2, current_feld: int):
	var map_pos = local_to_map(pos)
	if get_cell_source_id(map_pos) != 5:
		return []
	var ziel_portal = null
	if get_field_of_tile(map_pos) == current_feld:
		var valid_fields = []
		for f in range(0, max_portal_ids):
			if f != current_feld:
				valid_fields.append(f)
		var end_portal = valid_fields.pick_random()
		if [current_feld, end_portal] in portal_path:
			ziel_portal = end_portal
	if ziel_portal == null:
		return [map_to_local(Vector2i(0, 0)), 0]
		
	return [map_to_local(get_top_left_tile_of_field(ziel_portal)), current_feld]
	return []
	

func tp_to_signal(npc: CharacterBody2D, pos: Vector2, current_feld: int):
	var result = tp_to(pos,current_feld)
	if not result.is_empty():
		emit_signal("npc_teleported", npc, result[0])
		return result
	else:
		return result
	

func get_felder_summe():
	return array_floor.size()


func get_map_size(factor):
	return Global.Standard_Spielfeld_Size*factor
	

func _on_npc_teleported(npc: Variant, target_pos: Variant) -> void:
	npc.global_position = target_pos
