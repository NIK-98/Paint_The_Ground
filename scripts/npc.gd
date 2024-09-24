extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
@export var timer_power_up: PackedScene


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
var first_speed = Global.speed_npcs
var SPEED = first_speed
var current_direktion = 0
var curent_bomb = null
@export var paint_radius = Global.painting_rad

var powerups = [[-1,false,false],[-1,false,false],[-1,false,false]] #[0] = id,[1] = aktive,[2] = timer created
var power_time = [10,8,5]
	
	
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
				curent_direction.x = 1
					
			if position.x+get_node("Color").size.x > Global.Spielfeld_Size.x-get_node("Color").size.x:
				curent_direction.x = -1
					
			if position.y < get_node("Color").size.y:
				curent_direction.y = 1
					
			if position.y+get_node("Color").size.y > Global.Spielfeld_Size.y-get_node("Color").size.y:
				curent_direction.y = -1
				
			move_and_collide(velocity)
			for p in range(len(powerups)):
				if not powerups[p][2] and powerups[p][0] != -1:
					powerups[p][2] = true
					var new_timer_power_up = timer_power_up.instantiate()
					new_timer_power_up.connect("timeout", _on_timer_power_up_timeout)
					new_timer_power_up.create_id = powerups[p][0]
					$powertimers.add_child(new_timer_power_up)
					new_timer_power_up.name = str(powerups[p][0])
					if powerups[p][0] == 0:
						new_timer_power_up.wait_time = power_time[0]
					if powerups[p][0] == 1:
						new_timer_power_up.wait_time = power_time[1]
					if powerups[p][0] == 2:
						new_timer_power_up.wait_time = power_time[2]
					new_timer_power_up.start()
					
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
	if $powertimers.has_node("1"):
		return
	var radius_varscheinlichkeit = [2,2,2,2,2,4] #1/6 chance auf grösseren radius
	paint_radius = radius_varscheinlichkeit.pick_random()
	
	

func paint():
	var tile_position = map.local_to_map(position)
	for x in range(paint_radius):
		for y in range(paint_radius):
			var pos = Vector2i(x,y) + tile_position
			if map.get_cell_source_id(pos) != -1 and map.get_cell_source_id(pos) not in level.block_cells:
				map.set_cell(pos,color_cell,Vector2i(0,0),0)
			

func score_counter():
	last_score = score
	score = len(map.get_used_cells_by_id(color_cell))
	if level.get_node("Werten/PanelContainer/Wertung").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer/Wertung").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).wertung_npc(name)
	
	if level.get_node("Werten/PanelContainer2/visual").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer2/visual").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer2/visual").get_node(str(name)).update_var_npc(score, 1000)
		

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
	curent_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
		
func reset_player_vars():
	ende = false
	loaded = false
	Gametriggerstart = false
	score = 0
	paint_radius = Global.painting_rad
	

func _on_area_2d_area_entered(area: Area2D):
	if area.get_parent().is_in_group("npc") or area.get_parent().is_in_group("player"):
		if $powertimers.has_node("0"):
			return
		SPEED = first_speed
		SPEED = SPEED / 2
		$TimerresetSPEED.stop()
		$TimerresetSPEED.start()
		
		
func _on_timerreset_speed_timeout():
	if SPEED < first_speed:
		SPEED += 1
	if SPEED == first_speed:
		$TimerresetSPEED.stop()
	
	
func _on_timer_power_up_timeout():
	for p in range(len(powerups)):
		if powerups[p][1] == true:
			if $powertimers.has_node(str(powerups[p][0])) and powerups[p][0] == 0:
				$powertimers.get_node(str(powerups[p][0])).queue_free()
				SPEED = first_speed
				powerups[p][1] = false
				powerups[p][0] = -1
				powerups[p][2] = false
				return
			if $powertimers.has_node(str(powerups[p][0])) and powerups[p][0] == 1:
				$powertimers.get_node(str(powerups[p][0])).queue_free()
				paint_radius = Global.painting_rad
				powerups[p][1] = false
				powerups[p][0] = -1
				powerups[p][2] = false
				return
			if $powertimers.has_node(str(powerups[p][0])) and powerups[p][0] == 2:
				$powertimers.get_node(str(powerups[p][0])).queue_free()
				level.cell_blocker.rpc(false, name.to_int())
				powerups[p][1] = false
				powerups[p][0] = -1
				powerups[p][2] = false
				return
