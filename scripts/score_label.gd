extends Label

@onready var map = get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_node("Players")
	

func wertung(id: int):
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == 1:
			get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
		if check_cell == 2:
			get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
		if check_cell == 3:
			get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
