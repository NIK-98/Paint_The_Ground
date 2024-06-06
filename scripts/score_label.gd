extends Label

@onready var map = get_parent().get_parent().get_parent().get_node("floor")
@export var player_list = []
@export var score_list = []
@export var count_score = 0
	

@rpc("any_peer","call_local")
func wertung():
	player_list = []
	score_list = []
	count_score = 0
	for i in get_parent().get_child_count():
		player_list.append(get_parent().get_child(i))
		score_list.append(count_score)
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == 1 and len(score_list) == 1 and player_list[0]:
			score_list[0]+=1
			player_list[0].text = str(score_list[0])
		if check_cell == 2 and len(score_list) == 2 and player_list[1]:
			score_list[1]+=1
			player_list[1].text = str(score_list[1])
		if check_cell == 3 and len(score_list) == 3 and player_list[2]:
			score_list[2]+=1
			player_list[2].text = str(score_list[2])
