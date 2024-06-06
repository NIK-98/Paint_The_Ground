extends Node
	
const PORT = 11111

func _ready():
	get_tree().paused = true
	multiplayer.server_relay = false

	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()
	

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT,2)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_connect_pressed():
	var txt : String = $UI/Net/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_game():
	$UI.hide()
	get_tree().paused = false
	if multiplayer.is_server():
		change_level.call_deferred(load("res://sceens/level.tscn"))
	


func change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())


# Der Server kann Das Level mit R Restarten
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("reset") and Input.is_action_just_pressed("reset"):
		change_level.call_deferred(load("res://sceens/level.tscn"))

