extends Control

@onready var powerup: TextureRect = $powerup
@onready var label: Label = $Label
@onready var buy: Button = $buy
@onready var main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var shop: Control = $"../../../../../../.."

var powerup_icon: Resource = load("res://assets/powerups/speedup.png")
@export var shop_text: String = "+2 Sec. --> 200"
@export var aktuel: int = 10
var aktuel_text: String = str(aktuel," Sec.")

@export var shop_id: int = 0


var save_shop_path = "user://saveshop.save"
var loaded = false


func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"aktuel" : aktuel,
		"shop_id" : shop_id,
		"powerup.texture" : powerup.texture,
		"shop_text" : shop_text
	}
	return save_dict


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists(save_shop_path):
		return
	set_icon()
	buy.text = str("\n",shop_text)
	aktuel_text = str(aktuel," Sec.")
	label.text = aktuel_text
	

func set_icon():
	match shop_id:
		0:
			powerup.texture = load("res://assets/powerups/speedup.png")
		1:
			powerup.texture = load("res://assets/powerups/bigrad.png")
		2:
			powerup.texture = load("res://assets/powerups/protect.png")


func _process(_delta):
	if not loaded:
		_restore_shop()
	
	if shop.reseted:
		_reset()

func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_buy_pressed() -> void:
	if not main.has_node("Level/level"):
		return
	Global.ui_sound = true
	if shop_id == 0: #Speed shop
		if main.get_node("money/coin_display").remove_money(200):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 2
			aktuel += 2
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
	elif shop_id == 1: #Big Radius shop
		if main.get_node("money/coin_display").remove_money(300):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 3
			aktuel += 3
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
	elif shop_id == 2: #Unbesiegbarkeits Shop
		if main.get_node("money/coin_display").remove_money(500):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 4
			aktuel += 2
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
			

func _restore_shop() -> void:
	if not main.has_node("Level/level"):
		return
	if not main.get_node("Level/level/Players").has_node(str(multiplayer.get_unique_id())):
		return
	name = "shop_pruduct"
	main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] = aktuel
	aktuel_text = str(aktuel," Sec.")
	buy.text = str("\n",shop_text)
	set_icon()
	label.text = aktuel_text
	loaded = true
	set_process(false)


func _reset():
	if not main.has_node("Level/level"):
		return
	if not main.get_node("Level/level/Players").has_node(str(multiplayer.get_unique_id())):
		return
	set_icon()
	buy.text = str("\n",shop_text)
	aktuel = main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).standard_power_time[shop_id]
	main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] = aktuel
	aktuel_text = str(aktuel," Sec.")
	label.text = aktuel_text
	set_process(false)
