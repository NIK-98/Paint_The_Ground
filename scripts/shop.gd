extends Control


@onready var back: Button = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/back


func _physics_process(_delta):
	if Global.trigger_shop_menu:
		back.grab_focus()
		Global.trigger_shop_menu = false
		$CanvasLayer.visible = true


func _on_back_pressed() -> void:
	Global.ui_sound = true
	$CanvasLayer.visible = false
	get_parent().get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false


func _on_back_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_back_mouse_entered() -> void:
	Global.ui_hover_sound = true
