extends Label

@onready var map = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Players")
@onready var loby = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("loby")

var is_npc = false

@rpc("any_peer","call_local")
func wertung(id, color_vs: String):
	if not loby.vs_mode:
		get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
	else:
		get_parent().get_node(str(color_vs)).text = str(Players.get_node(str(id)).score)
		

func wertung_npc(id, color_vs: Color):
	if not loby.vs_mode:
		get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
	else:
		get_parent().get_node(str(color_vs)).text = str(Players.get_node(str(id)).score)
