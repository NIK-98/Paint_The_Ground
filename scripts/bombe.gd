extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 8
var explode_pos = null
var celle = 0

func _ready():
	set_physics_process(false)
				
		
func _physics_process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_bombe.rpc(celle, explode_pos)
			queue_free()
			return
			

@rpc("any_peer","call_local")
func aktivate_bombe(cell: int, pos: Vector2):
	var tile_position = map.local_to_map(pos)
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var new_pos = Vector2i(x, y) + tile_position
			var distance = new_pos.distance_to(tile_position)
			if map.get_cell_source_id(new_pos) != -1 and map.get_cell_source_id(new_pos) not in level.block_cells and distance < bomb_radius:
				map.set_cell(new_pos,cell,Vector2i(0, 0),0)
	#var used_cells = map.get_used_cells()
	#var area_radius = $Area2Daktiv/CollisionShape2D.scale.x*10/2
	#
	#for cellen in used_cells:
		#var cell_world_pos = map.local_to_map(cellen)
		#var cell_center = tile_position + map.tile_set.tile_size / 2
		#var distance = tile_position.distance_to(cell_center)
		#prints(distance,area_radius)
		#if distance <= area_radius:
			#map.set_cell(cell_center,cell,Vector2i(0, 0),0)
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		set_physics_process(true)
		explode_pos = area.get_parent().position
		celle = area.get_parent().color_cell
		if not area.get_parent().is_in_group("npc"):
			Global.bombe_sound = true
