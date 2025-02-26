extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	sounds(Global.hit_sound, Global.powerup_sound, Global.bombe_sound, Global.ui_sound, Global.ui_hover_sound, Global.coin_sound)
	if Global.music1_sound:
		if $Music1.playing:
			$Music1.stop()
		$Music1.play()
		Global.music1_sound = false
	if Global.stop_main_theama:
		Global.stop_main_theama = false
		if $Music1.playing:
			$Music1.stop()
	

func sounds(hit_sound: bool, powerup_sound: bool, bombe_sound: bool, ui_sound: bool, ui_hover_sound: bool, coin_sound: bool):
	if get_parent().is_node_ready():
		return
	if hit_sound:
		if $hit_sound.playing:
			$hit_sound.stop()
		$hit_sound.play()
		Global.hit_sound = false
	if powerup_sound:
		if $powerup_sound.playing:
			$powerup_sound.stop()
		$powerup_sound.play()
		Global.powerup_sound = false
	if bombe_sound:
		if $bombe_sound.playing:
			$bombe_sound.stop()
		$bombe_sound.play()
		Global.bombe_sound = false
	if ui_sound:
		if $ui_sound.playing:
			$ui_sound.stop()
		$ui_sound.play()
		Global.ui_sound = false
	if ui_hover_sound:
		if $ui_hover_sound.playing:
			$ui_hover_sound.stop()
		$ui_hover_sound.play()
		Global.ui_hover_sound = false
	if coin_sound:
		if $Coin.playing:
			$Coin.stop()
		$Coin.play()
		Global.coin_sound = false
	
