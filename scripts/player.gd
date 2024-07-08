extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var main = get_parent().get_parent().get_parent().get_parent()

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

@onready var camera = $Camera2D

@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		
@onready var input = $PlayerInput
	
	
func _ready():
	$CanvasLayer/Winner.visible = false
	$CanvasLayer/Los.visible = false
	main.get_node("UI").hide()
	if player == multiplayer.get_unique_id():
		camera.make_current()
		
	$Camera2D.limit_right = Global.Spielfeld_Size.x
	$Camera2D.limit_bottom = Global.Spielfeld_Size.y
	color_change()
	map.reset_floor()

func _physics_process(_delta):		
	if not loaded:
		loaded = true
		paint.rpc()
		score_counter()
	
	if not get_parent().get_parent().get_node("CanvasLayer/Start").visible and get_parent().get_parent().starting:
		if not Gametriggerstart:
			Gametriggerstart = true
			map.reset_floor()
			paint.rpc()
			score_counter()
			Check_Time_Visible.rpc()
			get_parent().get_parent().get_node("Timer").start()
			get_parent().get_parent().get_node("Timerbomb").start()
		if get_parent().get_parent().get_node("CanvasLayer/Time").visible and not get_parent().get_parent().Time_out:
			if position.x < 0:
				velocity.x += 10
			elif position.x+$Color.size.x > Global.Spielfeld_Size.x:
				velocity.x -= 10
			elif position.y < 0:
				velocity.y += 10
			elif position.y+$Color.size.y > Global.Spielfeld_Size.y:
				velocity.y -= 10
			else:
				velocity = input.move*SPEED

			move_and_collide(velocity)
			if (velocity.x != 0 or velocity.y != 0):
				paint.rpc()
			score_counter()
		if get_parent().get_parent().Time_out:
			ende()
		
	
	
@rpc("any_peer","call_local")
func Check_Time_Visible():
	for i in get_parent().get_parent().get_node("CanvasLayer").get_children():
		if i.is_in_group("time"):
			if not i.visible:
				i.visible = true
	

func ende():
	if input.aktueller_spieler:
		Global.Gameover = false
		for i in get_parent().get_parent().get_node("Werten/PanelContainer/Wertung").get_children():
			if i.text.to_int() > score:
				$CanvasLayer/Los.visible = true
		if not $CanvasLayer/Los.visible:
			$CanvasLayer/Winner.visible = true
	

func score_counter():
	last_score = score
	score = 0
	for i in len(map.get_used_cells_by_id(0,color_cell)):
		score+=1
	if last_score != score and get_parent().get_parent().get_node("Werten/PanelContainer/Wertung").get_node(str(name)) != null:
		get_parent().get_parent().get_node("Werten/PanelContainer/Wertung").get_node(str(name)).wertung(name.to_int())
		

@rpc("any_peer","call_local")
func paint():
	var radius = Vector2i($Color.size.x,$Color.size.y)
	var tile_position_top_left = map.local_to_map(Vector2(position.x,position.y))
	var tile_position_down_right = map.local_to_map(Vector2(position.x+radius.x,position.y+radius.y))
	if tile_position_down_right not in map.get_used_cells(0):
		return
	if tile_position_top_left not in map.get_used_cells(0):
		return
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
			


func _on_area_2d_area_entered(area):
	if Gametriggerstart:
		if area.is_in_group("boom") and DisplayServer.get_name() != "headless":
			area.get_parent().aktivate_bombe(color_cell, area.get_parent())
