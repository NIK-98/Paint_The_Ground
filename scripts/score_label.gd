extends Label

@onready var map = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Players")

var is_npc = false

@rpc("any_peer","call_local")
func wertung(id):
	get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
		

func wertung_npc(id):
	get_parent().get_node(str(id)).text = str(Players.get_node(str(id)).score)
