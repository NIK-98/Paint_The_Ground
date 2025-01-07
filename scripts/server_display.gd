extends Label


var ip_addr = ""
var port: int = 11111


func _on_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_join_pressed() -> void:
	if get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI").block_host:
		return
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI").ip = ip_addr
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI/Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote").text = str(ip_addr)
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI").connectport = str(port)
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI/Panel/CenterContainer/Net/Options/Option2/o4/port").text = str(port)
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("UI")._on_connect_pressed()
