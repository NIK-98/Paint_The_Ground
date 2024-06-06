extends Label

@onready var map = get_parent().get_parent().get_parent().get_node("floor")
@onready var Players = get_parent().get_parent().get_parent().get_node("Players")
var player_list = []
var score_list = []
var count_score = 0

func _process(delta):
	wertung.rpc()
	

@rpc("any_peer","call_local")
func wertung():
	player_list = []
	for i in get_parent().get_child_count():
		player_list.append(get_parent().get_child(i))
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == 1 and player_list[0]:
			player_list[0].text = str(Players.get_child(0).score)
		if check_cell == 2 and player_list[1]:
			player_list[1].text = str(Players.get_child(1).score)
		if check_cell == 3 and player_list[2]:
			player_list[2].text = str(Players.get_child(2).score)
