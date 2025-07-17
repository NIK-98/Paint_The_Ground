extends Control

var licenses = Engine.get_copyright_info()
@onready var text_edit: TextEdit = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/TextEdit
@onready var main = get_parent()
var lic_copy_path_mobile = "/storage/emulated/0/Android/data/de.niklas.nrw.pth/files/LICENSE_INFO.txt"
var lic_copy_path_pc = "user://LICENSE_INFO.txt"
var credits_path = "user://CREDITS.txt"
var loaded = false
var ende_text = "#################ENDE#################"


func _process(_delta: float) -> void:
	if not loaded:
		loaded = true
		write_credits_file()
		if OS.get_name() == "Android" or OS.get_name() == "iOS":
			copy_licens(lic_copy_path_mobile)
		if OS.get_name() == "Windows" or OS.get_name() == "Linux":
			copy_licens(lic_copy_path_pc)
	if $CanvasLayer.visible:
		if OS.get_name() == "Windows" or OS.get_name() == "Linux":
			text_edit.scroll_vertical += 0.0005
		else:
			text_edit.scroll_vertical += 0.005
		if text_edit.scroll_vertical >= text_edit.get_v_scroll_bar().max_value-10 or not $CanvasLayer.visible:
			text_edit.scroll_vertical = 0.0
		
			

func copy_licens(file_path: String):
	var file = FileAccess.open("res://LICENSE_INFO.txt", FileAccess.READ)
	var file2 = FileAccess.open(credits_path, FileAccess.READ)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	var copy_file = FileAccess.open(file_path, FileAccess.WRITE)
	copy_file.store_string(file.get_as_text() + "\n" + file2.get_as_text())
	text_edit.text =(file.get_as_text() + "\n" + file2.get_as_text())
	copy_file.close()
	file.close()
	file2.close()
	

func _on_back_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true
		

func _on_back_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_back_pressed() -> void:
	Global.ui_sound = true
	get_node("CanvasLayer").visible = false
	main.get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	main.get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false


func write_credits_file() -> void:
	if FileAccess.file_exists(credits_path):
		DirAccess.remove_absolute(credits_path)
	var file = FileAccess.open(credits_path, FileAccess.WRITE)

	if file:
		file.store_string("=== CREDITS ===\n\n")
		file.store_string("Created by NIK-DEV!\n")
		file.store_string("Powered by Godot Engine\n\n")
		
		# Lizenzinformationen abrufen und speichern
		var licenses = Engine.get_license_info()
		for license in licenses:
			file.store_string("License: " + licenses[license] + "\n")
			file.store_string("URL: " + license + "\n\n")

		
		# Copyright-Informationen abrufen und speichern
		var copyright_entries = Engine.get_copyright_info()
		for entry in copyright_entries:
			file.store_string("Copyright: " + entry["parts"][0].copyright[0] + "\n")
			file.store_string("License: " + entry["parts"][0].license + "\n\n")
			
			if "files" in entry:
				file.store_string("Affected files:\n")
				for path in entry.files:
					file.store_string("  - " + path + "\n")
			file.store_string("\n")
			
		
		# Godot Lizenztexte abrufen und speichern
		var license_texts = Engine.get_license_text()
		file.store_string("License Text:\n" + license_texts + "\n\n")
			
		
		file.store_string("Thank you to all contributors and open-source projects!\n"+ende_text)
		file.close()
		print("CREDITS file successfully written to: " + credits_path)
	else:
		print("Error: Unable to create CREDITS file.")


func _on_canvas_layer_visibility_changed() -> void:
	text_edit.scroll_vertical = 0.0
