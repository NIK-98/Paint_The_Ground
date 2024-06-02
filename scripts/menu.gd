extends Control

@onready var map = get_parent().get_node("floor")

@export var ip = "localhost"
@export var port = 11111
@export var player_sceen: PackedScene
var old_spawn: Vector2

var peer = ENetMultiplayerPeer.new()

	
func _on_host_pressed():
	peer.create_server(port,2)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func _add_player(id = 1):
	var player = player_sceen.instantiate()
	var randpos = Vector2(randi_range(0,Global.Spielfeld_Size.x-player.get_node("Color").size.x),randi_range(0,Global.Spielfeld_Size.y-player.get_node("Color").size.y))
	
	player.position = randpos
	if randpos == old_spawn:
		multiplayer.peer_disconnected.connect(_del_player)
		_del_player(id)
		_add_player(id)
		return
		
	player.name = str(id)
	call_deferred("add_child",player)
	old_spawn = randpos
		

func _del_player(id):
	get_node(str(id)).queue_free()
	

func _on_join_pressed():
	peer.create_client(ip,port)
	multiplayer.multiplayer_peer = peer
	
