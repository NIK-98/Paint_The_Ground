extends Control


@onready var back: Button = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/back
@onready var v_box_container: VBoxContainer = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer

var save_shop_path = "user://saveshop.save"
var reseted = false


func _on_back_pressed() -> void:
	Global.ui_sound = true
	$CanvasLayer.visible = false
	get_parent().get_node("money/coin_display").saveplayer(false)
	if not FileAccess.file_exists(save_shop_path):
		get_parent().save_game("saveshop", save_shop_path)
	else:
		DirAccess.remove_absolute(save_shop_path)
		get_parent().save_game("saveshop", save_shop_path)
	get_parent().get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false
	if reseted and FileAccess.file_exists(save_shop_path):
		DirAccess.remove_absolute(save_shop_path)


func _on_back_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_back_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_reset_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_reset_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_reset_pressed() -> void:
	if Global.akzept.is_empty():
		Global.ui_sound = true
		Global.akzept = "Shop Zurücksetzen"
		$CanvasLayer.visible = false
		get_parent().get_node("CanvasLayer/akzeptieren").visible = true
		get_parent().get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
		return
	reseted = true
	for i in v_box_container.get_children():
		if i.is_in_group("saveshop"):
			i.set_process(true)	
	Global.akzept = ""	
