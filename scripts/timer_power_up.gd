extends Timer

@onready var level = get_parent().get_parent().get_parent().get_parent()
@onready var Player = get_parent().get_parent()

var create_id = 0


func _on_timeout():
	queue_free()


func _exit_tree():
	name = str(create_id)
	if multiplayer.multiplayer_peer != null and Player.name.to_int() == multiplayer.get_unique_id():
		if Player.powerups[name.to_int()][0] == 0:
			Player.SPEED = Player.first_speed
			Player.powerups[name.to_int()][1] = false
			Player.powerups[name.to_int()][0] = -1
			Player.powerups[name.to_int()][2] = false
			queue_free()
		if Player.powerups[name.to_int()][0] == 1:
			Player.paint_radius = Global.painting_rad
			Player.powerups[name.to_int()][1] = false
			Player.powerups[name.to_int()][0] = -1
			Player.powerups[name.to_int()][2] = false
			queue_free()
		if Player.powerups[name.to_int()][0] == 2:
			level.cell_blocker.rpc(false, Player.color_cell)
			Player.powerups[name.to_int()][1] = false
			Player.powerups[name.to_int()][0] = -1
			Player.powerups[name.to_int()][2] = false
			queue_free()
		level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(Player.name)).update_icon.rpc(Player.powerups)
		if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
			if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(Player.name)):
				return
			if multiplayer.has_multiplayer_peer():
				level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(Player.name)).clear_icon.rpc(Player.powerups)
			
		if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
			if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(Player.name)) and Player.get_parent().has_node("2"):
				return
			level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(Player.name)).clear_icon_npc(Player.powerups)
