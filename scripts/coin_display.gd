extends PanelContainer
@onready var label = $Label

const max_coins = 9999999
const factor = 0.5
var coins = 0

var playersave_path = "user://playersave.save"
@onready var main = get_parent().get_parent()

var loaded = false
var saved = false

func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"coins" : coins
	}
	return save_dict
	

func _ready() -> void:
	label.text = str(int(coins))
	

func _process(_delta: float) -> void:
	if not loaded:
		loaded = true
		name = "coin_display"
		label.text = str(int(coins))
		set_process(false)
		

func  _physics_process(delta: float) -> void:
	if not main.has_node("Level/level"):
		return
	if main.get_node("Level/level/Scoreboard/CanvasLayer").visible and not saved:
		saved = true
		saveplayer(false)
	elif not main.get_node("Level/level/Scoreboard/CanvasLayer").visible and saved:
		saved = false
		$Label/save.visible = false
		$Timer.stop()


func kehrwert(value: int):
	return value/-1


func set_money(value: int):# ab value 100 ist set_money >= die eingegebene value
	coins += value * factor
	coins = int(coins)
	if coins%1 > 0:
		coins = abs(floor(kehrwert(coins)))
	elif coins > 0:
		coins = floor(coins)
	if coins < max_coins:
		coins = coins
		label.text = str(int(coins))
	else:
		coins = max_coins
		label.text = str(int(coins))
	return int(coins)
		

func remove_money(value: int):
	var removed = false
	if coins >= value:
		coins -= value
		removed = true
	label.text = str(int(coins))
	return removed
		

func saveplayer(reset: bool):
	if reset:
		reset = false
		if FileAccess.file_exists(playersave_path):
			DirAccess.remove_absolute(playersave_path)
		coins = 0
		label.text = str(int(coins))
		return
	if not FileAccess.file_exists(playersave_path):
		main.save_game("playersave", playersave_path)
	else:
		DirAccess.remove_absolute(playersave_path)
		main.save_game("playersave", playersave_path)
	$Label/save.visible = true
	$Timer.start()


func _on_timer_timeout() -> void:
	$Label/save.visible = false
	$Timer.stop()
