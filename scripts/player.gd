extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var level = get_parent().get_parent()

const SPEED = 20
var spawn = position
var last_position = position
var is_moving = true
var tile_size = 64
var tile_size_multipl = 1.5
var color_cell = 0
var loaded = false
var Gametriggerstart = false
var score = 0
var last_score = score
var move = Input.get_vector("left","right","up","down")
var player_spawn_grenze = 200
var ende = false

@onready var camera = $Camera2D

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	position = Vector2(randi_range(player_spawn_grenze,Global.Spielfeld_Size.x-player_spawn_grenze-$Color.size.x),randi_range(player_spawn_grenze,Global.Spielfeld_Size.y-player_spawn_grenze-$Color.size.y))
	
func _ready():
	$CanvasLayer/Winner.visible = false
	$CanvasLayer/Los.visible = false
	$Camera2D.limit_right = Global.Spielfeld_Size.x
	$Camera2D.limit_bottom = Global.Spielfeld_Size.y
	color_change()
	map.reset_floor()

func _physics_process(_delta):		
	if not loaded:
		loaded = true
		if is_multiplayer_authority():
			camera.make_current()
		paint.rpc()
		score_counter()
	
	if not get_parent().get_parent().get_node("CanvasLayer/Start").visible and get_parent().get_parent().starting:
		if not Gametriggerstart:
			Gametriggerstart = true
			map.reset_floor()
			paint.rpc()
			score_counter()
			Check_Time_Visible.rpc()
			level.get_node("Timer").start()
			level.get_node("Timerbomb").start()
		if level.get_node("CanvasLayer/Time").visible and not level.Time_out:
			if is_multiplayer_authority():
				moving()
				if position.x < get_node("Color").size.x:
					Input.action_release("left")
					
				if position.x+get_node("Color").size.x > Global.Spielfeld_Size.x-get_node("Color").size.x:
					Input.action_release("right")
					
				if position.y < get_node("Color").size.y:
					Input.action_release("up")
					
				if position.y+get_node("Color").size.y > Global.Spielfeld_Size.y-get_node("Color").size.y:
					Input.action_release("down")
				move = Input.get_vector("left","right","up","down")
				velocity = move*SPEED
			move_and_collide(velocity)
			if (velocity.x != 0 or velocity.y != 0):
				paint.rpc()
			boom.rpc()
			score_counter()
		elif level.Time_out and not ende:
			ende = true
			if name.to_int() == multiplayer.get_unique_id():
				for i in level.get_node("Werten/PanelContainer/Wertung").get_children():
					if i.text.to_int() > level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).text.to_int():
						get_node("CanvasLayer/Los").visible = true
						break
				if not get_node("CanvasLayer/Los").visible:
					get_node("CanvasLayer/Winner").visible = true
	

func moving():
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		if main.get_node("CanvasLayer/joy").get_joystick_dir().x == 1:
			Input.action_press("right")
		else:
			Input.action_release("right")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().x == -1:
			Input.action_press("left")
		else:
			Input.action_release("left")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().y == 1:
			Input.action_press("down")
		else:
			Input.action_release("down")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().y == -1:
			Input.action_press("up")
		else:
			Input.action_release("up")
			
	
@rpc("any_peer","call_local")
func Check_Time_Visible():
	for i in level.get_node("CanvasLayer").get_children():
		if i.is_in_group("time"):
			if not i.visible:
				i.visible = true
	

func score_counter():
	last_score = score
	score = 0
	for i in len(map.get_used_cells_by_id(0,color_cell)):
		score+=1
	if last_score != score and level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)) != null:
		level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).wertung(name.to_int())
		

@rpc("any_peer","call_local")
func paint():
	var tile_position = map.local_to_map(position)
	for x in range(2):
		for y in range(2):
			var pos = Vector2i(x,y) + tile_position
			map.set_cell(0,pos,color_cell,Vector2i(0,0))
		
		
func color_change():
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(str(name)) != null and i == 0:
			color_cell = 1
			get_node("Color").set_color(Color.GREEN)
			get_node("Name").set("theme_override_colors/font_color",Color.GREEN)
			get_node("CanvasLayer/Winner").set_color(Color.GREEN)
			get_node("CanvasLayer/Los").set_color(Color.GREEN)
		if get_parent().get_node(str(name)) != null and i == 1:
			color_cell = 2
			get_node("Color").set_color(Color.DARK_RED)
			get_node("Name").set("theme_override_colors/font_color",Color.DARK_RED)
			get_node("CanvasLayer/Winner").set_color(Color.DARK_RED)
			get_node("CanvasLayer/Los").set_color(Color.DARK_RED)
		if get_parent().get_node(str(name)) != null and i == 2:
			color_cell = 3
			get_node("Color").set_color(Color.DARK_BLUE)
			get_node("Name").set("theme_override_colors/font_color",Color.DARK_BLUE)
			get_node("CanvasLayer/Winner").set_color(Color.DARK_BLUE)
			get_node("CanvasLayer/Los").set_color(Color.DARK_BLUE)
		if get_parent().get_node(str(name)) != null and i == 3:
			color_cell = 4
			get_node("Color").set_color(Color.DEEP_SKY_BLUE)
			get_node("Name").set("theme_override_colors/font_color",Color.DEEP_SKY_BLUE)
			get_node("CanvasLayer/Winner").set_color(Color.DEEP_SKY_BLUE)
			get_node("CanvasLayer/Los").set_color(Color.DEEP_SKY_BLUE)
		if get_parent().get_node(str(name)) != null and i == 4:
			color_cell = 5
			get_node("Color").set_color(Color.VIOLET)
			get_node("Name").set("theme_override_colors/font_color",Color.VIOLET)
			get_node("CanvasLayer/Winner").set_color(Color.VIOLET)
			get_node("CanvasLayer/Los").set_color(Color.VIOLET)
		if get_parent().get_node(str(name)) != null and i == 5:
			color_cell = 6
			get_node("Color").set_color(Color.YELLOW)
			get_node("Name").set("theme_override_colors/font_color",Color.YELLOW)
			get_node("CanvasLayer/Winner").set_color(Color.YELLOW)
			get_node("CanvasLayer/Los").set_color(Color.YELLOW)
		
	
@rpc("any_peer","call_local")	
func boom():
	for area in $Area2D.get_overlapping_areas():
		if area.get_parent().is_in_group("boom"):
			area.get_parent().aktivate_bombe(color_cell)
			area.get_parent().queue_free()
				
				
func _exit_tree():
	Global.Gameover = false
