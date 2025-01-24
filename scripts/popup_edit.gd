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
	if OS.get_name() == "Android" or OS.get_name() == "IOS":
		if selected and not visible:
			await get_tree().create_timer(0.5).timeout
			visible = true
			grab_focus()
			max_length = parent_fild_length
			position.y = DisplayServer.get_display_safe_area().size.y/2-20
			position.x = ui.size.x/8
	if visible and Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()
	if ui.get_parent().get_parent().get_parent().has_node("Level/level/loby") and not ui.get_parent().get_parent().get_parent().get_node("Level/level/loby").visible:
		set_process(false)


func _on_button_pressed() -> void:
	text = ""
	position.y = old_hight
	visible = false
	ui.get_node("Panel/CenterContainer/Net/Options/Host_Connect").grab_focus()
	selected = false
	selected_node = null
	max_length = old_max_length


func _on_text_changed(new_text: String) -> void:
	if selected_node != null:
		selected_node.text = new_text


func _on_focus_exited() -> void:
	_on_button_pressed()
