extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	sounds(Global.hit_sound, Global.powerup_sound, Global.bombe_sound, Global.ui_sound, Global.ui_hover_sound, Global.coin_sound, Global.tp_sound)
	if Global.music1_sound:
		if $Music1.playing or $game1.playing or $game2.playing:
			$Music1.stop()
			$game1.stop()
			$game2.stop()
		if Global.selected_music_sound == Global.tracks[0]:
			$Music1.play()
		if Global.selected_music_sound == Global.tracks[1]:
			$game1.play()
		if Global.selected_music_sound == Global.tracks[2]:
			$game2.play()
		Global.music1_sound = false
	if Global.stop_main_theama:
		Global.stop_main_theama = false
		if $Music1.playing or $game1.playing or $game2.playing:
			$Music1.stop()
			$game1.stop()
			$game2.stop()
		

func sounds(hit_sound: bool, powerup_sound: bool, bombe_sound: bool, ui_sound: bool, ui_hover_sound: bool, coin_sound: bool, tp_sound: bool):
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
	if tp_sound:
		if $Tp.playing:
			$Tp.stop()
		$Tp.play()
		Global.tp_sound = false
	


func _on_music_1_finished() -> void:
	Global.music1_replay = true


func _on_game_1_finished() -> void:
	Global.music1_replay = true
