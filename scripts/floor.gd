extends TileMap

@onready var main = get_parent().get_parent().get_parent()
@onready var bombe = preload("res://sceens/bombe.tscn")

var with_tiles = 1280*2
var hight_tiles = 800*2
var old_spawn_bomb: Vector2
const  bomb_radius = 64*3
const bomb_spawn_genzen = 64


	
func reset_floor():
	for x in range(with_tiles):
		for y in range(hight_tiles):
			var tile_position = local_to_map(Vector2i(x,y))
			set_cell(0,tile_position,0,Vector2i(0,0))
			Global.Spielfeld_Size = Vector2(x,y)
			

@rpc("any_peer","call_local")
func reset_bomb():
	for c in get_child_count()-1:
		if get_child(c).is_in_group("boom"):
			print(get_child(c))
			get_child(c).queue_free()
	start_bomben.rpc(4)
			
			
@rpc("any_peer","call_local")
func start_bomben(anzahl: int):
	for i in range(anzahl):
		spawn_new_bombe(4)
		
@rpc("any_peer","call_local")		
func spawn_new_bombe(abstand: int):
	var new_bombe = bombe.instantiate()
	var randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))
	if randpos == old_spawn_bomb*4:
		old_spawn_bomb = randpos
		spawn_new_bombe.rpc(abstand)
		return
	new_bombe.position = randpos
	add_child(new_bombe)
	
@rpc("any_peer","call_local")
func aktivate_bombe(cell: int, clean:Node2D):
	for x in range(-bomb_radius,bomb_radius):
		for y in range(-bomb_radius,bomb_radius):
			var tile_position = local_to_map(Vector2i(clean.position.x+x,clean.position.y+y))
			set_cell(0,tile_position,cell,Vector2i(0,0))
	clean.queue_free()
	spawn_new_bombe.rpc(4)
