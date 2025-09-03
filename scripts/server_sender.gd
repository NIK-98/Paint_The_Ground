extends Node

@export var broadcast_interval = 1.0
var server_info = {"name" : "LAN Game", "port" : 11111}

var socket_udp
var broadcast_timer = Timer.new()
var broadcast_port = 6969


func _enter_tree() -> void:
	broadcast_timer.wait_time = broadcast_interval
	broadcast_timer.one_shot = false
	broadcast_timer.autostart = true
	
	if multiplayer.is_server():
		add_child(broadcast_timer)
		broadcast_timer.connect("timeout", broadcast)
		
		socket_udp = PacketPeerUDP.new()
		socket_udp.set_broadcast_enabled(true)
		socket_udp.set_dest_address("255.255.255.255", broadcast_port)
		

func broadcast():
	server_info.name = get_parent().get_parent().get_node("UI").server_namen
	server_info.port = get_parent().get_parent().get_node("UI").port
	var packetmsg = JSON.stringify(server_info)
	var packet = packetmsg.to_ascii_buffer()
	socket_udp.put_packet(packet)


func _exit_tree() -> void:
	broadcast_timer.stop()
	if socket_udp != null:
		socket_udp.close()
