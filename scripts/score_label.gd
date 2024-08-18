extends Label

@onready var map = get_parent().get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_parent().get_node("Players")


@rpc("any_peer","call_local")
func wertung(id):
	for i in map.get_used_cells_by_id(Players.get_node(str(id)).color_cell):
		get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
