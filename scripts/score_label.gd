extends Label

@onready var map = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Players")
@onready var loby = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("loby")

var is_npc = false


func wertung(id, score):
	if Players.has_node(str(id)):
		text = str(score)
