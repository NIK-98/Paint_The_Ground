extends Control

@onready var main = $"/root/main/"

@export var Scoreboard_List = []
var first_select_button = false
var loaded = false
	
	
	
func _ready():
	if OS.has_feature("dedicated_server"):
		return
		
	
func sort_scoreboard(a,b):
	if a[0] > b[0]:
		return true
	return false
	

@rpc("any_peer","call_local")
func sync_list(NewScoreEintrag: Array):
	Scoreboard_List.append(NewScoreEintrag)
	Scoreboard_List.sort_custom(sort_scoreboard)
	for eintrag in range(len(Scoreboard_List)):
		if not get_node("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer").has_node(str("HBoxContainer",eintrag)):
			var newnode = get_node("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer0").duplicate()
			$"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/".add_child(newnode)
			newnode.name = str("HBoxContainer",eintrag)
			newnode.get_node("Platz0").text = str("Platz ",eintrag+1,":")
			newnode.get_node("Platz0").name = str("Platz",eintrag)
			newnode.get_node("name0").name = str("name",eintrag)
			newnode.get_node("Score0").name = str("Score",eintrag)
		var score_feld = str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/Score",eintrag)
		var name_feld = str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)
		get_node(score_feld).text = str(Scoreboard_List[eintrag][0])
		get_node(name_feld).text = Scoreboard_List[eintrag][1]


	
func update_scoreboard():
	if loaded:
		if get_parent().get_node("loby").player_conect_count == 1 and get_parent().get_node("loby").count_players_wait == 1:
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.text = str(get_parent().get_node("Werten/PanelContainer/Wertung").get_node("npc").text)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.text = str("Spieler: ",get_parent().get_node("Players").get_node("npc").get_node("Name").text)
			sync_list.rpc([get_parent().get_node("Werten/PanelContainer/Wertung").get_node("npc").text.to_int(), get_parent().get_node("Players").get_node("npc").get_node("Name").text])
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node("npc").get_node("Color").color)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node("npc").get_node("Color").color)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.text = str(get_parent().get_node("Werten/PanelContainer/Wertung").get_node(str(multiplayer.get_unique_id())).text)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.text = str("Spieler: ",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Name").text)
		sync_list.rpc([get_parent().get_node("Werten/PanelContainer/Wertung").get_node(str(multiplayer.get_unique_id())).text.to_int(), get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Name").text])
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not loaded:
		update_scoreboard()
		loaded = true
	
	if Input.is_action_pressed("right") and $CanvasLayer.visible:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical -= 5
	if Input.is_action_pressed("left") and $CanvasLayer.visible:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical += 5


func _on_restart_pressed():
	get_parent().get_node("loby").restart_game()
