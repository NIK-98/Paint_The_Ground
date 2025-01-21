extends LineEdit

@onready var ui = get_parent()

var old_hight = position.y
var selected = false
var selected_node = null
var old_max_length = 35
var parent_fild_length = 0


func _ready() -> void:
	visible = false


func _process(delta: float) -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		if selected and not visible and DisplayServer.virtual_keyboard_get_height() != 0:
			grab_focus()
			max_length = parent_fild_length
			await get_tree().create_timer(0.7).timeout
			visible = true
			position.y = get_viewport_rect().size.y - DisplayServer.virtual_keyboard_get_height()
			position.x = (get_viewport_rect().size.x-size.x)/2
	if ui.get_parent().get_parent().get_parent().has_node("Level/level/loby") and not ui.get_parent().get_parent().get_parent().get_node("Level/level/loby").visible:
		set_process(false)


func _on_button_pressed() -> void:
	position.y = old_hight
	visible = false
	ui.get_node("Panel/CenterContainer/Net/Options/Host_Connect").grab_focus()
	selected = false
	selected_node = null
	max_length = old_max_length


func _on_text_changed(new_text: String) -> void:
	if selected_node != null:
		selected_node.text = new_text
