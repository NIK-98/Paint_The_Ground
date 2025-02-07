extends Control


func _on_leave_pressed() -> void:
	Global.ui_sound = true


func _on_leave_button_up() -> void:
	Input.action_release("exit")


func _on_leave_button_down() -> void:
	Input.action_press("exit")
