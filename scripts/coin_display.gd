extends PanelContainer
@onready var label = $Label

const max_coins = 9999999
var coins = 0


func _ready() -> void:
	label.text = str(coins)


func add_coin(value: int):
	if coins < 9999999:
		coins += 1
		label.text = str(coins)
	
	
func remove_coin(value: int):
	if coins > 0:
		coins -= 1
		label.text = str(coins)
