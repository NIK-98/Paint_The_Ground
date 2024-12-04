extends Node

signal new_server
signal remove_server

var clean_up_timer = Timer.new()
var socket_udp = PacketPeerUDP.new()
var listen_port = 6969
var servers = {}

@export var server_clean_time = 3

func _init() -> void:
	clean_up_timer.wait_time = server_clean_time
	clean_up_timer.one_shot = false
	clean_up_timer.autostart = true
	clean_up_timer.connect("timeout", clean_up)


func _ready() -> void:
	servers.clear()
	
	if socket_udp.bind(listen_port) != OK:
		prints("Lan Server Browser Error: Port",listen_port,"wird berits verwendet!")
	else:
		prints("Lan Server Browser erstellt auf: Port",listen_port)


func _process(_delta: float) -> void:
	if socket_udp.get_available_packet_count() > 0:
		var server_ip = socket_udp.get_packet_ip()
		var server_port = socket_udp.get_packet_port()
		var array_bytes = socket_udp.get_packet()
		
		if server_ip != "" and server_port > 0:
			if not servers.has(server_ip):
				var servermsg = array_bytes.get_string_from_ascii()
				var gameInfo = JSON.parse_string(servermsg)
				gameInfo.ip = server_ip
				gameInfo.ping = Time.get_unix_time_from_system()
				servers[server_ip] = gameInfo
				emit_signal("new_server", gameInfo)
				prints(socket_udp.get_packet_ip())
			else:
				var gameInfo = servers[server_ip]
				gameInfo.ping = Time.get_unix_time_from_system()
				
	

func clean_up():
	var now = Time.get_unix_time_from_system()
	for server_ip in servers:
		var serverInfo = servers[server_ip]
		if (now - serverInfo.ping) > server_clean_time:
			servers.erase(server_ip)
			prints("Server",server_ip,"entfernt!")
			emit_signal("remove_server", server_ip)
	

func _exit_tree() -> void:
	socket_udp.close()
