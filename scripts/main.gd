extends Node

var block_host = false
var Max_clients = 6
var port = "11111"


func _ready():
	var args = OS.get_cmdline_args()
	if args.has("-p"):
		var argument_wert = args[args.find("-p") + 1] # Wert des spezifischen Arguments
		port = argument_wert
	if not port.is_valid_int():
		prints("Das Argument '-p' wurde nicht uebergeben, ist der standard Port oder ist fehlerhaft. Port ist der standard port 11111!")
		port = "11111"
	prints("Port wurde auf ", port, " gesetzt! achtung ports unter 1024 gehen vermutlich nicht!")
			
	OS.request_permissions()
	multiplayer.server_relay = false
	
	
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
		print("Startet Dedicated Server.")
		_on_host_pressed.call_deferred()
		

func _process(_delta):
	if Input.is_action_just_pressed("cancel"):
		block_host = false
		$UI/Panel/CenterContainer/Net/Connecting.text = ""
	if Input.is_action_just_pressed("exit") and $UI.visible:
		get_tree().quit()


func _on_host_pressed():
	if block_host:
		return
	var peer = ENetMultiplayerPeer.new()
	if OS.get_cmdline_args().size() <= 1:
		port = $UI/Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	port = port.to_int()
	var check = peer.create_server(port, Max_clients)
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
	if OS.get_cmdline_args().size() <= 1:
		port = $UI/Panel/CenterContainer/Net/Options/Option2/o4/port.text
	if not txt.is_valid_ip_address() and not txt == "localhost":
		OS.alert("Ist keine richtiege ip adresse.")
		block_host = false
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		block_host = false
		return
	var peer = ENetMultiplayerPeer.new()
	port = port.to_int()
	peer.create_client(txt, port)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		block_host = false
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


func _on_tap_pressed():
	Input.action_press("Info")
	


func _on_tap_released():
	Input.action_release("Info")


func _on_up_left_pressed():
	Input.action_press("up")
	Input.action_press("left")


func _on_up_left_released():
	Input.action_release("up")
	Input.action_release("left")


func _on_up_right_pressed():
	Input.action_press("up")
	Input.action_press("right")


func _on_up_right_released():
	Input.action_release("up")
	Input.action_release("right")


func _on_down_left_pressed():
	Input.action_press("down")
	Input.action_press("left")


func _on_down_left_released():
	Input.action_release("down")
	Input.action_release("left")


func _on_down_right_pressed():
	Input.action_press("down")
	Input.action_press("right")
	
	
func _on_down_right_released():
	Input.action_release("down")
	Input.action_release("right")
