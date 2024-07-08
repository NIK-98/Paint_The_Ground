extends TileMap

@onready var main = get_parent().get_parent().get_parent()


func reset_floor():
	for x in range(Global.Spielfeld_Size.x):
		for y in range(Global.Spielfeld_Size.y):
			var tile_position = local_to_map(Vector2i(x,y))
			set_cell(0,tile_position,0,Vector2i(0,0))

