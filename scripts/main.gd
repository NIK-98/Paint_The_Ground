extends Node

var block_host = false


func _ready():
	OS.request_permissions()
	multiplayer.server_relay = false
	
	
	Global.Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Global.Max_clients = 7
		print("Startet Dedicated Server.")
		_on_host_pressed.call_deferred()
		

func _process(delta):
	if Input.is_action_just_pressed("cancel"):
		block_host = false
		$UI/Panel/CenterContainer/Net/Connecting.text = ""
	if Input.is_action_just_pressed("exit") and $UI.visible:
		get_tree().quit()


func _on_host_pressed():
	if block_host:
		return
	var peer = ENetMultiplayerPeer.new()
	var port = $UI/Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	port = port.to_int()
	var check = peer.create_server(port, Global.Max_clients)
	if check != OK:
		OS.alert("Server kann nicht erstellt werden!")
		if port < 1024:
			OS.alert("Versuchen sie einen port über 1024!")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
		
		
func _on_connect_pressed():
	if block_host:
		return
	block_host = true
	var txt = $UI/Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	var port = $UI/Panel/CenterContainer/Net/Options/Option2/o4/port.text
	if not txt.is_valid_ip_address() and not txt == "localhost":
		OS.alert("Ist keine richtiege ip adresse.")
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	var peer = ENetMultiplayerPeer.new()
	port = port.to_int()
	peer.create_client(txt, port)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		return
	var i = 0
	while peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING and block_host:
		i += 1
		$UI/Panel/CenterContainer/Net/Connecting.text = str("Verbindung wird aufgebaut...", i)
		await get_tree().create_timer(1).timeout
		if i >= 20:
			block_host = false
			OS.alert("Verbindung fehlgeschlagen!")
			$UI/Panel/CenterContainer/Net/Connecting.text = ""
	if not block_host:
		multiplayer.disconnect_peer(peer.get_unique_id())
		return
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


func _on_back_pressed():
	Input.action_press("cancel")
	Input.action_release("cancel")
