extends Control

@export var Scoreboard_List = []
var first_select_button = false
var load_folder = "user://load_folder"
const passw = "ffw49w3rwhfrw8"
		

func save_scoreboard(save_path: String):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(load_folder):
		dir.make_dir(load_folder)
	var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, passw)
	var data = {
		"Scoreboard_List":Scoreboard_List
	}
	file.store_string(JSON.stringify(data))
	file.close()


func load_scoreboard(load_path: String):
	var file = FileAccess.open_encrypted_with_pass(load_path, FileAccess.READ, passw)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	if result == OK:
		var data = json.data
		Scoreboard_List = data["Scoreboard_List"]
		for i in range(len(Scoreboard_List)):
			Scoreboard_List[i][0] = int(Scoreboard_List[i][0])
			Scoreboard_List[i].append("OLD_VALUES_IN_LIST")
	file.close()
	update_scorboard_load.rpc(Scoreboard_List)
	
	
@rpc("any_peer","call_local")
func update_scorboard_load(list: Array):
	Scoreboard_List = list
	
	
func _ready():
	$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart.connect("pressed", _on_restart_pressed)	


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
		get_node(name_feld).set("theme_override_colors/font_color",Color.WHITE)
		get_node(score_feld).text = str(Scoreboard_List[eintrag][0])
		get_node(name_feld).text = Scoreboard_List[eintrag][1]
	update_eigene_anzeige()
				
	
@rpc("any_peer","call_local")
func sync_name_color_eintrag():
	for eintrag in range(len(Scoreboard_List)):
		if Scoreboard_List[eintrag].has("OLD_VALUES_IN_LIST"):
			continue
		for n in get_parent().get_node("Players").get_children():
			if not get_parent().get_node("loby").vs_mode:
				if n.get_node("Name").text == Scoreboard_List[eintrag][1]:
					get_node(str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)).set("theme_override_colors/font_color",n.get_node("Color").color)
			else:
				if get_node(str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)).text == "Red":
					get_node(str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)).set("theme_override_colors/font_color",Color.DARK_RED)
				elif get_node(str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)).text == "Blue":
					get_node(str("CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer",eintrag,"/name",eintrag)).set("theme_override_colors/font_color",Color.DEEP_SKY_BLUE)
					

func update_scoreboard():
	var team_wertung = false
	if not Global.load_score_path.is_empty():
		load_scoreboard(Global.load_score_path)
		Global.load_score_path = ""
	for n in get_parent().get_node("Players").get_children():
		if not get_parent().get_node("loby").vs_mode:
			sync_list.rpc([get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node(str(n.name)).text.to_int(), n.get_node("Name").text])
		elif not team_wertung:
			team_wertung = true
			sync_list.rpc([get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node(str("Red")).text.to_int(), "Red"])
			sync_list.rpc([get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node(str("Blue")).text.to_int(), "Blue"])
		get_parent().get_node("Players").get_node(str(n.name)).reset_player_vars.rpc()
	sync_name_color_eintrag.rpc()

		
func update_eigene_anzeige():
	if not get_parent().get_node("loby").vs_mode:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.text = str(get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node(str(multiplayer.get_unique_id())).text)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.text = str("Spieler: ",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Name").text)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
	else:
		if get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).team == "Red":
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.text = str(get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node("Red").text)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.text = str("Spieler: ",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Name").text)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
		elif get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).team == "Blue":
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.text = str(get_parent().get_node("Werten/PanelContainer/Wertung/werte").get_node("Blue").text)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.text = str("Spieler: ",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Name").text)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/score.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Spieler.set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("Color").color)
			
			
func _process(_delta):
	if Input.is_action_pressed("right") and $CanvasLayer.visible:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical -= 5
	if Input.is_action_pressed("left") and $CanvasLayer.visible:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical += 5


func _on_restart_pressed():
	Global.ui_sound = true
	if get_parent().get_node("loby").player_conect_count <= 1 and not get_parent().get_node("Players").has_node("2") and not OS.has_feature("dedicated_server"):
		get_parent().get_node("loby").exit("Kein Mitspieler auf dem Server Gefunden!", true)
		return
	if get_parent().get_node("loby").player_conect_count <= 1 and OS.has_feature("dedicated_server"):
		get_parent().get_node("loby").exit("Kein Mitspieler auf dem Server Gefunden!", true)
		return
	$"../loby".set_wait_rady.rpc(multiplayer.get_unique_id(), true)
	$"../loby".set_wait.rpc(multiplayer.get_unique_id(), true)
	$"../loby".update_player_counter(true,true,false,true)
	get_parent().reset_vars_level.rpc_id(1)
	set_visiblety.rpc_id(1,"../loby", true)
	$CanvasLayer.visible = false
	
	
	
@rpc("any_peer","call_local")
func set_visiblety(nodepath: String, mode: bool):
	var obj = get_node(nodepath)
	if obj:
		if mode:
			obj.visible = mode
		else:	
			obj.visible = mode


func _input(_event):
	if (Input.is_action_just_pressed("scrolldown") or Input.is_action_just_pressed("scrolldown_con")) and $CanvasLayer.visible and not get_parent().main.get_node("Control/CanvasLayer").visible:
		if $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical < max(0, $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.size.y - $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.size.y):
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical += 100
			return
	if (Input.is_action_just_pressed("scrollup") or Input.is_action_just_pressed("scrollup_con")) and $CanvasLayer.visible and not get_parent().main.get_node("Control/CanvasLayer").visible:
		if $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical >= min(0, $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.size.y - $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.size.y):
			$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer.scroll_vertical -= 100
			return
	

func _on_restart_mouse_entered():
	Global.ui_hover_sound = true


func _on_restart_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound= true
