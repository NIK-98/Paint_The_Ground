extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius: int = 8
var explode_pos: Vector2
var celle: int = 0

var thread1 = Thread.new()


func _ready():
	set_process(false)
	
		
func _process(_delta):
	if explode_pos != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			aktivate_bombe.rpc(celle, explode_pos)
			queue_free()
			return
			

@rpc("any_peer","call_local")
func aktivate_bombe(cell: int, pos: Vector2):
	var tile_position: Vector2i = map.local_to_map(pos)
	var bomb_array1 = []
	var bomb_array2 = []
	thread1.start(t1.bind(bomb_array1,cell,tile_position))
	thread1.wait_to_finish()
		
		
func t1(cellen: Array, cell: int, pos: Vector2i):
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var new_pos: Vector2i = Vector2i(x,y)+pos
			if BetterTerrain.get_cell(map,new_pos) != -1 and BetterTerrain.get_cell(map,new_pos) not in level.block_cells and new_pos.distance_to(pos) < bomb_radius:
				if BetterTerrain.get_cell(map,new_pos) == cell:
					continue
				cellen.append(new_pos)
	BetterTerrain.call_deferred("set_cells",map,cellen,cell)
	BetterTerrain.call_deferred("update_terrain_cells",map,cellen,cell)
		
		
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		explode_pos = area.get_parent().position
		celle = area.get_parent().color_cell
		if not area.get_parent().is_in_group("npc") and area.get_parent().name.to_int() == multiplayer.get_unique_id():
			Global.bombe_sound = true
		set_process(true)


func _exit_tree() -> void:
	if thread1.is_alive():
		thread1.wait_to_finish()
