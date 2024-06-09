extends TileMap

@onready var main = get_parent().get_parent().get_parent()

var with_tiles = 1280*2
var hight_tiles = 800*2
	
	
func reset_floor():
	for x in range(with_tiles):
		for y in range(hight_tiles):
			var tile_position = local_to_map(Vector2i(x,y))
			set_cell(0,tile_position,0,Vector2i(0,0))
			Global.Spielfeld_Size = Vector2(x,y)
		
