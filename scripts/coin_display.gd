extends PanelContainer
@onready var label = $Label

var max_coins = 9999999
var coins = 0


func _ready() -> void:
	label.text = str(coins)


func kehrwert(value: int):
	return value/-1


func factor(value: int):
	return (value + 100) / 100


func set_money(value: int):# ab value 100 ist add_money >= die eingegebene value
	coins += value * factor(value)
	if coins%1 > 0:
		coins = abs(floor(kehrwert(coins)))
	elif coins > 0:
		coins = floor(coins)
	if coins < max_coins:
		coins = coins
		label.text = str(coins)
	else:
		coins = max_coins
		label.text = str(coins)
	return coins
			

func remove_money(value: int):# ab value 60 ist die live_money >= die eingegebene value
	if coins > value:
		coins -= value
	else:
		coins = 0
		
