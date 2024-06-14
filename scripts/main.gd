extends Node


func _ready():
	OS.request_permissions()
	get_tree().paused = true
	multiplayer.server_relay = false
	
	
	Global.Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Global.Max_clients = 7
		print("Startet Dedicated Server.")
		_on_host_pressed.call_deferred()
		

func _process(delta):
	if get_node("Level/level") == null:
		OS.alert("Multiplayer Server wurde beendet.")
		get_tree().change_scene_to_file("res://sceens/main.tscn")
	

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	var txt : String = $UI/Panel/CenterContainer/Net/Options/o3/remote1/Remote.text
	var port : String = $UI/Panel/CenterContainer/Net/Options/o4/port.text
	if not txt.is_valid_ip_address():
		OS.alert("Ist keine richtiege ip adresse.")
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	var check = peer.create_server(port.to_int(), Global.Max_clients)
	if check != OK:
		OS.alert("Multiplayer Server läuft bereits.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
		
		
func _on_connect_pressed():
	var txt : String = $UI/Panel/CenterContainer/Net/Options/o3/remote1/Remote.text
	var port : String = $UI/Panel/CenterContainer/Net/Options/o4/port.text
	if not txt.is_valid_ip_address():
		OS.alert("Ist keine richtiege ip adresse.")
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, port.to_int())
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		return
	var udp_server = UDPServer.new()
	if udp_server.listen(port.to_int()) == 0:
		OS.alert("Kein Multiplayer Server gefunden.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	await get_tree().create_timer(2).timeout


func start_game():
	$UI.hide()
	if multiplayer.is_server():
		change_level(preload("res://sceens/level.tscn"))


func change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())



func _on_up_pressed():
	Input.action_press("up")


func _on_down_pressed():
	Input.action_press("down")


func _on_right_pressed():
	Input.action_press("right")


func _on_left_pressed():
	Input.action_press("left")



func _on_left_released():
	Input.action_release("left")


func _on_right_released():
	Input.action_release("right")


func _on_down_released():
	Input.action_release("down")


func _on_up_released():
	Input.action_release("up")



func _on_leave_pressed():
	Input.action_press("exit")
	Input.action_release("exit")
