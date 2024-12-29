extends CenterContainer

@onready var main = get_parent().get_parent()
@onready var label: Label = $PanelContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if label.text.is_empty() and visible:
		label.text = Global.akzept


func _on_ja_pressed() -> void:
	Global.ui_sound = true
	if Global.akzept == "Beenden":
		main._on_beenden_pressed()
		get_parent().get_node("Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		visible = false
		label.text = ""
	if Global.akzept == "Coins Löschen":
		main._on_deleteuser_pressed()
		get_parent().get_node("Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		get_parent().get_node("Menu").visible = true
		visible = false
		label.text = ""
	if Global.akzept == "Standard Grafik":
		main.get_node("Grafik")._on_reset_pressed()
		main.get_node("Grafik/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Grafik/CanvasLayer").visible = true
		visible = false
		label.text = ""
	if Global.akzept == "Standard Audio":
		main.get_node("Audio_menu")._on_reset_pressed()
		main.get_node("Audio_menu/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Audio_menu/CanvasLayer").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
	if Global.akzept == "Standard Eingabe":
		main.get_node("Control")._on_reset_pressed()
		main.get_node("Control/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Control/CanvasLayer").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""


func _on_nein_pressed() -> void:
	Global.ui_sound = true
	if Global.akzept == "Beenden":
		get_parent().get_node("Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		get_parent().get_node("Menu").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
	if Global.akzept == "Coins Löschen":
		get_parent().get_node("Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		get_parent().get_node("Menu").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
	if Global.akzept == "Standard Grafik":
		main.get_node("Grafik/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Grafik/CanvasLayer").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
	if Global.akzept == "Standard Audio":
		main.get_node("Audio_menu/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Audio_menu/CanvasLayer").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
	if Global.akzept == "Standard Eingabe":
		main.get_node("Control/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset").grab_focus()
		main.get_node("Control/CanvasLayer").visible = true
		visible = false
		Global.akzept = ""
		label.text = ""
		

func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true
