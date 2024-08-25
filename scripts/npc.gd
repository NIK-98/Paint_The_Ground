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
var vorhersage_zeit = 50
var direction = [1]
var random = 1
var new_direction: Vector2
var direction_sehen: Vector2
var direction_volgen: Vector2
var direction_flucht: Vector2
var direction_bomb: Vector2
var SPEED = 20
var dir: Vector2
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
	$Timer.connect("timeout", _on_timer_timeout.rpc)

func _physics_process(_delta):
	if not loaded:
		loaded = true
		position = Vector2(randi_range(npc_spawn_grenze,Global.Spielfeld_Size.x-npc_spawn_grenze-$Color.size.x),randi_range(npc_spawn_grenze,Global.Spielfeld_Size.y-npc_spawn_grenze-$Color.size.y))
		_on_timer_timeout()
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
			$Timer.start()
		if level.get_node("CanvasLayer/Time").visible and not level.Time_out:
			paint()
			score_counter()
			velocity += move_npc()*SPEED
				
			if position.x < get_node("Color").size.x:
				velocity.x = 1
					
			if position.x+get_node("Color").size.x > Global.Spielfeld_Size.x-get_node("Color").size.x:
				velocity.x = -1
					
			if position.y < get_node("Color").size.y:
				velocity.y = 1
					
			if position.y+get_node("Color").size.y > Global.Spielfeld_Size.y-get_node("Color").size.y:
				velocity.y = -1
				
			move_and_collide(velocity)
		elif level.Time_out and not ende:
			ende = true
			$Timer.stop()
			level.get_node("Timerende").start()
			

func color_change():
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(str(name)) != null and i == 1:
			color_cell = 7
			get_node("Color").set_color(Color.SADDLE_BROWN)
			get_node("Name").set("theme_override_colors/font_color",Color.SADDLE_BROWN)
			SPEED = 2
		if get_parent().get_node(str(name)) != null and i == 2:
			color_cell = 8
			get_node("Color").set_color(Color.ORANGE)
			get_node("Name").set("theme_override_colors/font_color",Color.ORANGE)
			SPEED = 2.5
		if get_parent().get_node(str(name)) != null and i == 3:
			color_cell = 9
			get_node("Color").set_color(Color.HOT_PINK)
			get_node("Name").set("theme_override_colors/font_color",Color.HOT_PINK)
			SPEED = 3
		
								
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
	if random == 1:
		direction_volgen = (get_parent().get_child(0).position - position)
		dir = direction_volgen
	elif random == 2:
		direction_sehen = ((get_parent().get_child(0).position + get_parent().get_child(0).velocity * vorhersage_zeit) - position)
		dir = direction_sehen
	elif random == 3:
		direction_flucht = (position - get_parent().get_child(0).position)
		dir = -direction_flucht
	elif random == 4:
		if curent_bomb == null:
			random = 1
			direction_volgen = (get_parent().get_child(0).position - position)
			dir = direction_volgen
			return dir.normalized()
		direction_bomb = (curent_bomb.position - position)
		dir = direction_bomb
	
	return dir.normalized()

		
		
func reset_player_vars():
	ende = false
	loaded = false
	Gametriggerstart = false
	score = 0
	paint_radius = 2


@rpc("any_peer","call_local")
func _on_timer_timeout():
	random = direction.pick_random()
	if level.get_node("Bomben").get_child_count() > 0 and random == 4:
		curent_bomb = level.get_node("Bomben").get_children().pick_random()
	if level.get_node("Bomben").get_child_count() == 0 and random == 4:
		random = 1
