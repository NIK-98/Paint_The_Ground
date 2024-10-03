extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	sounds(Global.hit_sound, Global.powerup_sound, Global.bombe_sound)
	if Global.music1_sound:
		if $Music1.playing:
			$Music1.stop()
		$Music1.play()
		Global.music1_sound = false
	

func sounds(hit_sound: bool, powerup_sound: bool, bombe_sound: bool):
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
	
