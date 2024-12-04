extends Label


var ip_addr = ""


func _on_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_join_pressed() -> void:
	get_parent().get_parent().get_parent().get_parent().get_node("UI").ip = ip_addr
	get_parent().get_parent().get_parent().get_parent().get_node("UI")._on_connect_pressed()
