extends Node2D

@onready var map = $floor

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		wertung()
		get_tree().change_scene_to_file("res://sceens/main.tscn")
		
	var fps = Engine.get_frames_per_second()
	$"Control/CanvasLayer/fps".text = str("FPS: ", fps)
	

func wertung():
	var player1_cells = 0
	var player2_cells = 0
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == 1:
			player1_cells += 1
		if check_cell == 2:
			player2_cells += 1
	prints(str("Player1: ", player1_cells))
	prints(str("Player2: ", player2_cells))
