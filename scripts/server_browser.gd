extends VBoxContainer

@onready var servers_lisener = $Servers_Lisener
@onready var v_box_container = $VBoxContainer/ScrollContainer


func _on_servers_lisener_new_server(serverInfo) -> void:
	var server_node = preload("res://sceens/server_display.tscn").instantiate()
	server_node.text = str(serverInfo.ip," : ",serverInfo.name)
	v_box_container.add_child(server_node)
	server_node.ip_addr = str(serverInfo.ip)


func _on_servers_lisener_remove_server(serverIp) -> void:
	for serverNode in v_box_container.get_children():
		if serverNode.is_in_group("server_display"):
			if serverNode.ip_addr == serverIp:
				serverNode.queue_free()
				break
