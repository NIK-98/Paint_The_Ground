extends Node2D

@onready var Player1 = get_child(0)
@onready var Player2 = get_child(1)
@onready var map = $floor

var player = preload("res://sceens/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_player()


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
	
	
func add_player():
	var old_spawn: Vector2
	for p in range(2):
		var new_player = player.instantiate()
		var randpos = Vector2(randi_range(0,Global.Spielfeld_Size.x-new_player.get_node("Color").size.x),randi_range(0,Global.Spielfeld_Size.y-new_player.get_node("Color").size.y))
		if p == 0:
			new_player.ID = 1
			new_player.get_node("Color").set_color(Color(255,255,0))
			new_player.position = randpos
			old_spawn = randpos
		if p == 1:
			new_player.ID = 2
			new_player.get_node("Color").set_color(Color(255,0,255))
			new_player.position = randpos
			if randpos == old_spawn:
				add_player()
				return		
		
		add_child(new_player)
		new_player.name = "Player"
