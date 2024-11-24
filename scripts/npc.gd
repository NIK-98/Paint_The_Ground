extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()
@export var timer_power_up: PackedScene


var score = 0
var color_cell = 0
var loaded = false
var npc_spawn_grenze = 200
var Gametriggerstart = false
var ende = false
var time_last_change = 0
var direction_change_interval = 1  # Intervall in Sekunden
var curent_direction = Vector2() # für warloses folgen
var random = 1
var first_speed = Global.speed_npcs
var SPEED = first_speed
var current_direktion = 0
var curent_bomb = null
var curent_powerup = null
var curent_tarrget = null
@export var paint_radius = Global.painting_rad

var team = "Blue"

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
	
	
func _process(delta):
	if not loaded:
		loaded = true
		set_random_direction()
		score_counter()
	
	if level.get_node("loby/CenterContainer/HBoxContainer/VBoxContainer/Warten").text == "Alle Player bereit!":
		if not Gametriggerstart:
			Gametriggerstart = true
			position = Vector2(randi_range(npc_spawn_grenze,Global.Spielfeld_Size.x-npc_spawn_grenze-$Color.size.x),randi_range(npc_spawn_grenze,Global.Spielfeld_Size.y-npc_spawn_grenze-$Color.size.y))
	if level.get_node("CanvasLayer/Time").visible:
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			time_last_change += delta
			if time_last_change >= direction_change_interval:
				time_last_change = 0
				if curent_tarrget == null:
					set_random_direction()
			if time_last_change == 0 and curent_tarrget:
				random = 2
				
			if velocity.x != 0 or velocity.y != 0:
				paint()
			score_counter()
			velocity = move_npc()*SPEED
				
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
					if not $TimerresetSPEED.is_stopped():
						$TimerresetSPEED.stop()
					$slow_color.visible = false
					
		elif level.get_node("CanvasLayer/Time").text.to_int() == 0 and not ende:
			ende = true
			for c in $powertimers.get_children():
				c.stop()
				c.queue_free()
			if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
				if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(name)):
					return
				level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).clear_icon_npc(powerups)
			

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
	

func paint():
	var tile_position = map.local_to_map(Vector2(position.x+($Color.size.x/2),position.y+($Color.size.y/2)))
	for x in range(-paint_radius,paint_radius):
		for y in range(-paint_radius,paint_radius):
			var pos = Vector2i(x,y) + tile_position
			var distance = pos.distance_to(tile_position)
			if map.get_cell_source_id(pos) != -1 and map.get_cell_source_id(pos) not in level.block_cells and distance < paint_radius:
				map.set_cell(pos,color_cell,Vector2i(0,0),0)
			

func score_counter():
	score = len(map.get_used_cells_by_id(color_cell))
	
	if level.get_node("Werten/PanelContainer/Wertung/werte").get_child_count() > 0 and not level.get_node("loby").vs_mode:
		if not level.get_node("Werten/PanelContainer/Wertung/werte").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(name)).wertung_npc(name)
	elif level.get_node("Werten/PanelContainer/Wertung/werte").get_child_count() > 0 and level.get_node("loby").vs_mode:
		if not level.get_node("Werten/PanelContainer/Wertung/werte").has_node(str(team)):
			return
		level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(team)).wertung.rpc(name.to_int())
	
	if level.get_node("Werten/PanelContainer2/visual").get_child_count() > 0 and not level.get_node("loby").vs_mode:
		if not level.get_node("Werten/PanelContainer2/visual").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer2/visual").get_node(str(name)).update_var_npc(name.to_int(), map.get_felder_summe(Global.Spielfeld_Size, Vector2i(64,64)))
	elif level.get_node("Werten/PanelContainer2/visual").get_child_count() > 0 and level.get_node("loby").vs_mode:
		if not level.get_node("Werten/PanelContainer2/visual").has_node(str(team)):
			return
		level.get_node("Werten/PanelContainer2/visual").get_node(str(team)).update_var_npc(name.to_int(), map.get_felder_summe(Global.Spielfeld_Size, Vector2i(64,64)))
	
	if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
		if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).update_icon_npc(powerups)
	
	
func move_npc():
	var dir = Vector2()
	if curent_tarrget == null:
		random = 1
		
	if random == 1:
		#direction_wahrlos
		dir = curent_direction
	elif random == 2:
		#direction_tarrget
		dir = (curent_tarrget.position - position).normalized()

	return dir
		
		
func set_random_direction():
	# Zufällige Richtung generieren
	if level.get_node("Bomben").get_child_count() > 0:
		curent_bomb = level.get_node("Bomben").get_children().pick_random()
	if level.get_node("PowerUP").get_child_count() > 0:
		curent_powerup = level.get_node("PowerUP").get_children().pick_random()
	if level.get_node("Bomben").get_child_count() > 0 and level.get_node("PowerUP").get_child_count() > 0:
		curent_tarrget = [curent_bomb,curent_powerup].pick_random()
		random = randi_range(1,2)
		if random == 1:
			curent_tarrget = null
			curent_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		return
	elif level.get_node("PowerUP").get_child_count() > 0:
		curent_tarrget = curent_powerup
		random = randi_range(1,2)
		if random == 1:
			curent_tarrget = null
			curent_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		return
	elif level.get_node("Bomben").get_child_count() > 0:
		curent_tarrget = curent_bomb
		random = randi_range(1,2)
		if random == 1:
			curent_tarrget = null
			curent_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		return
		
	random = 1
	curent_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
		
@rpc("any_peer","call_local")
func reset_player_vars():
	ende = false
	score = 0
	powerups = [[-1,false,false],[-1,false,false],[-1,false,false]]
	paint_radius = Global.painting_rad
	loaded = false
	Gametriggerstart = false
	

func _on_area_2d_area_entered(area: Area2D):
	if area.get_parent().is_in_group("npc") or area.get_parent().is_in_group("player"):
		if $powertimers.has_node("0"):
			return
		SPEED = first_speed
		SPEED = SPEED / 2
		$TimerresetSPEED.stop()
		$TimerresetSPEED.start()
		$slow_color.visible = true
		
		
func _on_timerreset_speed_timeout():
	if SPEED < first_speed:
		SPEED += 0.1
	if SPEED >= first_speed:
		SPEED = first_speed
		$TimerresetSPEED.stop()
		$slow_color.visible = false
