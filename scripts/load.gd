extends Button

var load_folder = "user://load_folder"
var first_save = false
@onready var load_menue_canvas = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var scoreboard = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Scoreboard")
		

func _process(_delta: float) -> void:
	if first_save:
		first_save = false
		grab_focus()
		

func _on_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_del_pressed() -> void:
	var load_folder = "user://load_folder"
	DirAccess.remove_absolute(str(load_folder,"/",text))
	queue_free()


func _on_pressed() -> void:
	var load_folder = "user://load_folder"
	Global.load_score_path = str(load_folder,"/",text)
	load_menue_canvas.visible = false
	
	
