extends TextureButton


func _on_pressed() -> void:
	Global.ui_sound = true
	Input.action_press("exit")
	Input.action_release("exit")
