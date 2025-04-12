extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var wall = get_parent().get_parent().get_node("wall")
@onready var level = get_parent().get_parent()

const bomb_radius: int = 6
var explode_pos = null
var celle: int = 0
var feld: int = 0

var bomb_array = []
var bomb_radius_sqr = bomb_radius * bomb_radius
var new_pos: Vector2i
var offset_x: int
var offset_y: int
var distance_sqr: int
var clean = false

var id: int = 0


func _ready():
	set_process(false)
	
		
func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			if not $Area2D/CollisionShape2D.disabled:
				$Area2D/CollisionShape2D.disabled = true
				$bum.play("bum")
			if not $bum.is_playing():
				aktivate_bombe.rpc(celle,explode_pos,feld,id)
				queue_free()
				return
		

@rpc("any_peer", "call_local")
func aktivate_bombe(cell: int, pos: Vector2, feld_id: int, player_id: int):
	var tile_position: Vector2i = map.local_to_map(pos)
	var block_cells = level.block_cells
		
	for x in range(-bomb_radius, bomb_radius):
		offset_x = x + tile_position.x
		for y in range(-bomb_radius, bomb_radius):
			offset_y = y + tile_position.y
			distance_sqr = x*x+y*y
			if distance_sqr < bomb_radius_sqr:
				new_pos = Vector2i(offset_x, offset_y)
				var cell_source_id = BetterTerrain.get_cell(map,new_pos)
				var wall_cell_source_id = BetterTerrain.get_cell(wall,new_pos)
				if cell_source_id != -1 and cell_source_id != 5 and wall_cell_source_id != 0 and cell_source_id not in block_cells and cell_source_id != cell:
					if cell_source_id == -1 and wall_cell_source_id == -1:
						continue
					if not map.is_portal_id_ok(new_pos, feld_id):
						continue
					
					if cell_source_id != 0:
						level.get_node("Players").get_node(str(player_id)).count_gegner_cellen[cell_source_id] += 1
					level.get_node("Players").get_node(str(player_id)).count_cellen += 1
						
					bomb_array.push_back(new_pos)
	BetterTerrain.call_deferred("set_cells",map,bomb_array,cell)
	BetterTerrain.call_deferred("update_terrain_cells",map,bomb_array)
	explode_pos = null
		
		
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		celle = area.get_parent().color_cell
		clean = true
		feld = area.get_parent().feld
		id = area.get_parent().name.to_int() 
		if not area.get_parent().is_in_group("npc") and area.get_parent().name.to_int() == multiplayer.get_unique_id():
			Global.bombe_sound = true
		set_process(true)
