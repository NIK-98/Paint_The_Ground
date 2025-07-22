extends Button

var focus_allowed = false
@onready var loby = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	
func _process(_delta: float) -> void:
	if Global.akzept != "!!Coins Löschen!!" and Global.akzept != "!!Shop Zurücksetzen!!" and Global.akzept != "!!Shop und Coins Zurücksetzen!!":
		if OS.has_feature("dedicated_server") or multiplayer.is_server():
			if not Global.load_score_path.is_empty() or not loby.load_mode:
				Global.trigger_host_focus = true
				grab_focus()
				Global.trigger_host_focus = false
				set_process(false)
			if not Global.load_menu_showed and loby.load_mode and focus_allowed:
				Global.trigger_host_focus = true
				grab_focus()
				Global.trigger_host_focus = false
				set_process(false)
			if not focus_allowed and Global.load_menu_showed:
				focus_allowed = true
		else:
			Global.trigger_host_focus = true
			grab_focus()
			Global.trigger_host_focus = false
			set_process(false)
