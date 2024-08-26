extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()


var score = 0
var last_score = score
var color_cell = 0
var loaded = false
var npc_spawn_grenze = 200
var Gametriggerstart = false
var ende = false
var time_last_change = 0
var direction_change_interval = 0.5  # Intervall in Sekunden
var curent_direction = Vector2() # für warloses folgen
var random = 1
var SPEED = 15
var current_direktion = 0
var curent_bomb = null
@export var paint_radius = 2
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	color_change()
	var npc_count = 1
	for i in get_parent().get_children():
		if i.is_in_group("npc"):
			i.get_node("Name").text = str("NPC",npc_count)
			npc_count += 1

func _physics_process(delta):
	if not loaded:
		loaded = true
		position = Vector2(randi_range(npc_spawn_grenze,Global.Spielfeld_Size.x-npc_spawn_grenze-$Color.size.x),randi_range(npc_spawn_grenze,Global.Spielfeld_Size.y-npc_spawn_grenze-$Color.size.y))
		set_random_direction()
		paint()
		score_counter()
	
	if get_parent().get_parent().starting:
		if not Gametriggerstart:
			Gametriggerstart = true
			map.reset_floor()
			paint()
			score_counter()
			Check_Time_Visible()
			level.get_node("Timer").start()
			level.get_node("Timerbomb").start()
		if level.get_node("CanvasLayer/Time").visible and not level.Time_out:
			time_last_change += delta
			if time_last_change >= direction_change_interval:
				time_last_change = 0
				if curent_bomb == null:
					set_random_direction()
			if time_last_change == 0 and curent_bomb:
				random = 2
				
			paint()
			score_counter()
			velocity = move_npc()
				
			if position.x < get_node("Color").size.x:
				velocity.x = 5
					
			if position.x+get_node("Color").size.x > Global.Spielfeld_Size.x-get_node("Color").size.x:
				velocity.x = -5
					
			if position.y < get_node("Color").size.y:
				velocity.y = 5
					
			if position.y+get_node("Color").size.y > Global.Spielfeld_Size.y-get_node("Color").size.y:
				velocity.y = -5
				
			move_and_collide(velocity)
		elif level.Time_out and not ende:
			ende = true
			level.get_node("Timerende").start()
			

func color_change():
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(str(name)) != null and i == 1:
			color_cell = 7
			get_node("Color").set_color(Color.SADDLE_BROWN)
			get_node("Name").set("theme_override_colors/font_color",Color.SADDLE_BROWN)
		if get_parent().get_node(str(name)) != null and i == 2:
			color_cell = 8
			get_node("Color").set_color(Color.ORANGE)
			get_node("Name").set("theme_override_colors/font_color",Color.ORANGE)
		if get_parent().get_node(str(name)) != null and i == 3:
			color_cell = 9
			get_node("Color").set_color(Color.HOT_PINK)
			get_node("Name").set("theme_override_colors/font_color",Color.HOT_PINK)
		
								
func change_paint_rad():
	var radius_varscheinlichkeit = [2,2,2,2,2,4] #1/6 chance auf grösseren radius
	paint_radius = radius_varscheinlichkeit.pick_random()
	
	

func paint():
	var tile_position = map.local_to_map(position)
	for x in range(paint_radius):
		for y in range(paint_radius):
			var pos = Vector2i(x,y) + tile_position
			if map.get_cell_source_id(pos) != -1:
				map.set_cell(pos,color_cell,Vector2i(0,0),0)
				
				

func score_counter():
	last_score = score
	score = len(map.get_used_cells_by_id(color_cell))
	if level.get_node("Werten/PanelContainer/Wertung").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer/Wertung").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).wertung_npc(name)
		

func Check_Time_Visible():
	for i in level.get_node("CanvasLayer").get_children():
		if i.is_in_group("time"):
			if not i.visible:
				i.visible = true


func move_npc():
	var dir = Vector2()
	if curent_bomb == null:
		random = 1
		
	if random == 1:
		#direction_wahrlos
		dir = curent_direction * SPEED
	elif random == 2:
		#direction_bombe
		dir = (curent_bomb.position - position).normalized() * SPEED

	return dir
		
		
func set_random_direction():
	# Zufällige Richtung generieren
	if level.get_node("Bomben").get_child_count() > 0:
		curent_bomb = level.get_node("Bomben").get_children().pick_random()
		return
	random = 1
	var angle = position.direction_to(get_parent().get_child(0).position)
	var new_angle = position.angle_to(angle)
	curent_direction = Vector2(cos(new_angle), sin(new_angle)).normalized()
	
		
func reset_player_vars():
	ende = false
	loaded = false
	Gametriggerstart = false
	score = 0
	paint_radius = 2
