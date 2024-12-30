class_name shop
extends Control

@onready var powerup: TextureRect = $powerup
@onready var label: Label = $Label
@onready var buy: Button = $buy
@onready var main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

@export var powerup_icon: Resource = load("res://assets/powerups/speedup.png")
@export var shop_text: String = "+2 Sec. --> 400"
@export var aktuel: int = 10
var aktuel_text: String = str(aktuel," Sec.")

@export var shop_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	powerup.texture = powerup_icon
	buy.text = shop_text
	aktuel_text = str(aktuel," Sec.")
	label.text = aktuel_text


func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_buy_pressed() -> void:
	if not main.has_node("Level/level"):
		return
	if main.get_node("Level/level/loby").visible:
		return
	Global.ui_sound = true
	if shop_id == 0: #Speed shop
		if main.get_node("money/coin_display").remove_money(400):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 2
			aktuel += 2
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
	elif shop_id == 1: #Big Radius shop
		if main.get_node("money/coin_display").remove_money(600):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 3
			aktuel += 3
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
	elif shop_id == 2: #Unbesiegbarkeits Shop
		if main.get_node("money/coin_display").remove_money(1000):
			main.get_node("Level/level/Players").get_node(str(multiplayer.get_unique_id())).power_time[shop_id] += 4
			aktuel += 4
			aktuel_text = str(aktuel," Sec.")
			label.text = aktuel_text
