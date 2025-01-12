extends Label


func _physics_process(_delta):
	var fps = Engine.get_frames_per_second()
	text = str("FPS: ", fps)
