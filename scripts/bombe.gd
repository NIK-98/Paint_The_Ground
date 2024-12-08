extends Node2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()

const bomb_radius = 8
var celle = 0
@export var distroy = null
	
	
func _ready() -> void:
	set_process(false)
	
	
func _process(_delta: float) -> void:
	if distroy != null:
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			clean_boom.rpc(distroy)
			

@rpc("any_peer","call_local")
func clean_boom(node_path: NodePath):
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		var object = get_node(node_path)
		if object:
			object.queue_free()
			
			
@rpc("any_peer","call_local")
func aktivate_bombe(cell: int):
	var tile_position = map.local_to_map(position)
	for x in range(-bomb_radius, bomb_radius):
		for y in range(-bomb_radius, bomb_radius):
			var new_pos = Vector2i(x, y) + tile_position
			var distance = new_pos.distance_to(tile_position)
			if map.get_cell_source_id(new_pos) != -1 and map.get_cell_source_id(new_pos) not in level.block_cells and distance < bomb_radius:
				map.set_cell(new_pos,cell,Vector2i(0, 0),0)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		celle = area.get_parent().color_cell
		if not self.is_in_group("npc"):
			Global.bombe_sound = true
		aktivate_bombe(celle)
		distroy = get_path()
		set_process(true)
		return
