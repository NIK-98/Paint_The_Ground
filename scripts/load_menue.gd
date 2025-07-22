extends Control

@onready var loby = get_parent()
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var load_path = "user://load_folder/save.save"
var load_folder = "user://load_folder"
var files: PackedStringArray
var added_saves = false
var loaded = false
var first_button_name = ""
var load_sceen = preload("res://sceens/load.tscn")
@onready var v_box_container = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var timer: Timer = $Timer
@onready var no_load: Label = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/no_load


func _ready() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(load_folder):
		dir.make_dir(load_folder)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.akzept != "!!Coins Löschen!!" and Global.akzept != "!!Shop Zurücksetzen!!" and Global.akzept != "!!Shop und Coins Zurücksetzen!!":
		if OS.has_feature("dedicated_server") or multiplayer.is_server():
			if not loaded and loby.load_mode and not canvas_layer.visible:
				loaded = true
				canvas_layer.visible = true
				Global.load_menu_showed = true
				
			
			if canvas_layer.visible:
				if not added_saves:
					added_saves = true
					for f in DirAccess.get_files_at(load_folder):
						var new_load = load_sceen.instantiate()
						new_load.text = f
						v_box_container.add_child(new_load)
					if v_box_container.get_child_count() == 0:
						no_load.visible = true
						scroll_container.visible = false
						timer.start()
						
					if v_box_container.get_child_count() > 0:
						v_box_container.get_child(0).first_save = true
						first_button_name = v_box_container.get_child(0).name
			else:
				Global.load_menu_showed = false
				queue_free()
			no_load.text = str("Keine daten!\nFenster schließt in ",int(round(timer.time_left))," Sec.")
				
		else:
			Global.load_menu_showed = false
			queue_free()
		
		


func _on_timer_timeout() -> void:
	canvas_layer.visible = false
