extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var wall = get_parent().get_parent().get_node("wall")
@onready var level = get_parent().get_parent()
@onready var player = get_parent().get_node("1")
@onready var coins = get_parent().get_parent().get_node("Coins")
@export var timer_power_up: PackedScene


var color_cell = 0
var loaded = false
var npc_spawn_grenze = 200
var Gametriggerstart = false
var ende = false
var map_enden = Vector2.ZERO
var curent_direction = Vector2.ZERO
var random = 1
var first_speed  = Global.speed_npcs
var SPEED = first_speed
var curent_bomb = null
var curent_powerup = null
var curent_tarrget = null
const cooldown_time_tp = 10
var feld = 1
var tp_cool_down = cooldown_time_tp
var portal_free = true
var tp_marker = false
var pos_array = []
var	set_pos = false
var selected_field_on_map = null
var npc_team_nodes = []
@export var paint_radius = Global.painting_rad

var magnet = true

var team = "Blue"

var powerups = [[-1,false,false],[-1,false,false],[-1,false,false]] #[0] = id,[1] = aktive,[2] = timer created
const standard_power_time = [10,8,5]
var power_time: = [10,8,5]
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	color_change()
	var npc_count: int = 1
	for i in get_parent().get_children():
		if i.is_in_group("npc"):
			i.get_node("Name").text = str("NPC",npc_count)
			npc_count += 1
			if i.team != player.team:
				npc_team_nodes.append(i)
			
	
func _physics_process(delta):
	if not loaded:
		loaded = true
	if not set_pos and not map.array_floor.is_empty():
		set_pos = true
		var map_pos = map.dict_floor_with_portal_id[randi_range(1,4)]
		for i in map_pos:
			pos_array.append(map.map_to_local(i))
		position = pos_array.pick_random()
		if not map.array_floor.is_empty() and map.get_tp_feld(position) != null:
			feld = map.get_tp_feld(position)[1]
	if level.get_node("loby/CenterContainer/HBoxContainer/VBoxContainer/Warten").text == "Alle Spieler bereit!":
		if not Gametriggerstart:
			Gametriggerstart = true
			map_enden = map.map_to_local(Global.Spielfeld_Size)
	if level.get_node("CanvasLayer/Time").visible:
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			if is_on_wall() or is_on_ceiling() or is_on_floor() or not is_vaild_field():
				set_random_direction()
			velocity = move_npc()*SPEED		
			move_and_slide()
			
			if magnet:
				for c in coins.get_children():
					var coin_dist = position.distance_to(c.position)
					if coin_dist < c.magnet_craft and c.magnet_id == 0:
						c.magnet_id = name.to_int()
				
					
		elif level.get_node("CanvasLayer/Time").text.to_int() == 0 and not ende:
			ende = true
			for c in $powertimers.get_children():
				c.stop()
				c.queue_free()
			if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
				if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(name)):
					return
				level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).clear_icon(powerups)
		

func _process(delta):
	if level.get_node("CanvasLayer/Time").visible:
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			paint(color_cell)
			if level.get_node("loby").tp_mode:
				tp_cool_down -= delta
				if round(tp_cool_down) <= 0:
					curent_tarrget = null
				if ((portal_free or tp_marker) and map.is_vaild_portal(position)):
					tp_marker = false
					portal_free = false
					tp_cool_down = cooldown_time_tp
					feld = map.get_next_field(feld)
					map.tp_to(self, feld)
					feld = map.get_tp_feld(position)[1]
				if not portal_free and not map.is_vaild_portal(position):
					portal_free = true
			if not powerups[0][2] and powerups[0][0] != -1:#erstes powerup
				powerups[0][2] = true
				aktivate_power(0)
			if not powerups[1][2] and powerups[1][0] != -1:#zweites powerup
				powerups[1][2] = true
				aktivate_power(1)
			if not powerups[2][2] and powerups[2][0] != -1:#drites powerup
				powerups[2][2] = true
				aktivate_power(2)
		

func aktivate_power(index: int):
	var new_timer_power_up = timer_power_up.instantiate()
	new_timer_power_up.create_id = powerups[index][0]
	$powertimers.add_child(new_timer_power_up)
	new_timer_power_up.name = str(powerups[index][0])
	new_timer_power_up.wait_time = power_time[index]
	level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).update_icon.rpc(powerups)
	new_timer_power_up.start()
	if not $TimerresetSPEED.is_stopped():
		$TimerresetSPEED.stop()
	$slow_color.visible = false
					

func color_change():
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(str(name)) != null and i == 1:
			color_cell = 2
			get_node("Color").set_color(Color.DARK_RED)
			get_node("Name").set("theme_override_colors/font_color",Color.DARK_RED)
		if get_parent().get_node(str(name)) != null and i == 2:
			color_cell = 3
			get_node("Color").set_color(Color.DARK_BLUE)
			get_node("Name").set("theme_override_colors/font_color",Color.DARK_BLUE)
		if get_parent().get_node(str(name)) != null and i == 3:
			color_cell = 4
			get_node("Color").set_color(Color.DEEP_SKY_BLUE)
			get_node("Name").set("theme_override_colors/font_color",Color.DEEP_SKY_BLUE)	
	

func paint(_current_cell: int):
	var tile_position: Vector2i = map.local_to_map(Vector2(position.x + ($Color.size.x / 2), position.y + ($Color.size.y / 2)))
	var paint_array: Array = []
	var paint_radius_sqr: float = paint_radius * paint_radius
	var block_cells = level.block_cells
	var new_pos: Vector2i
	var offset_x: int
	var offset_y: int
	var distance_sqr: float

	for x in range(-paint_radius, paint_radius):
		offset_x = x + tile_position.x
		for y in range(-paint_radius, paint_radius):
			offset_y = y + tile_position.y
			distance_sqr = x * x + y * y
			
			if distance_sqr < paint_radius_sqr:
				new_pos = Vector2i(offset_x, offset_y)
				var cell_id = map.get_cell_source_id(new_pos)
				var wall_cell_id = wall.get_cell_source_id(new_pos)
				if cell_id != -1 and cell_id != 5 and wall_cell_id != 0 and wall_cell_id == -1 and cell_id != color_cell and cell_id not in block_cells and map.is_portal_id_ok(new_pos, feld):
					#if cell_id != 0:####docch noch fehlerhaft
						#level.count_cellen[current_cell][cell_id] += 1
					#level.count_cellen[current_cell][current_cell] += 1
					paint_array.append(new_pos)
	
	BetterTerrain.set_cells(map, paint_array, color_cell)
	BetterTerrain.update_terrain_cells(map, paint_array)
	
	
func move_npc():
	var dir: Vector2
	if curent_tarrget == null:
		random = 1
	if random == 1:
		#direction_wahrlos
		dir = curent_direction
	elif random == 2:
		#direction_tarrget
		dir = (curent_tarrget.position - position).normalized()
	return dir
	
	
func get_valid_fields():
	var valid_fields = []
	if feld == null:
		return valid_fields
	if not level.get_node("loby").tp_mode:
		if player.velocity == Vector2.ZERO:
			feld = map.get_next_field(feld)
		else:
			feld = player.feld
	if feld == null:
		return valid_fields
	if not level.get_node("loby").vs_mode:
		valid_fields = get_valid_fields_help_func(valid_fields, player)
	else:
		if team == player.team:
			valid_fields = get_valid_fields_help_func(valid_fields, npc_team_nodes.pick_random())
		else:
			valid_fields = get_valid_fields_help_func(valid_fields, player)
				
	if not level.get_node("loby").tp_mode and valid_fields.is_empty():
		if player.velocity == Vector2.ZERO:
			feld = map.get_next_field(feld)
		else:
			feld = player.feld
	return valid_fields


func get_valid_fields_help_func(vaild_field_array: Array, tarrget_player: CharacterBody2D):
	for felt_cords in map.dict_floor_with_portal_id[feld]:
		if level.score[tarrget_player.color_cell] > 400 and map.get_cell_source_id(felt_cords) == tarrget_player.color_cell:
			vaild_field_array.append(felt_cords)
			tp_marker = false
		elif map.get_cell_source_id(felt_cords) == tarrget_player.color_cell or map.get_cell_source_id(felt_cords) == 0:
			vaild_field_array.append(felt_cords)
			tp_marker = false
		else:
			tp_marker = true
			curent_direction = Vector2(-1, -1).normalized()
	return vaild_field_array
	

func is_vaild_field():
	if selected_field_on_map == null:
		return false
	elif BetterTerrain.get_cell(map,selected_field_on_map) == color_cell:
		return false
	else:
		return true
	
	
func set_random_direction(auto_mode: bool = true):
	curent_tarrget = null
	var new_feld_pos = Vector2.ZERO
	var valid_bomb_list = level.get_node("Bomben").get_children().filter(func(v): v.clean)
	var power_ups = level.get_node("PowerUP").get_children()
	var candidates = valid_bomb_list + power_ups
	var valid_fields = get_valid_fields()
	for power in power_ups:
		if map.get_tp_feld(power.position)[1] != feld:
			continue
		if power.powerupid == 2:
			random = 2
			curent_tarrget = power
			return
	if auto_mode:
		random = [1,2].pick_random()
	else:
		random = 2
	if not valid_fields.is_empty() and round(tp_cool_down) > 0:
		if random == 2 and not candidates.is_empty():
			curent_tarrget = candidates.pick_random()
			if map.get_tp_feld(curent_tarrget.position)[1] == feld:
				return
			random = 1
		selected_field_on_map = valid_fields.pick_random()
		new_feld_pos = map.map_to_local(selected_field_on_map)
		curent_direction = (new_feld_pos - position).normalized()
		return
	elif not level.get_node("loby").tp_mode and valid_fields.is_empty():
		selected_field_on_map = null
		curent_direction = Vector2.ZERO
	elif level.get_node("loby").tp_mode and (valid_fields.is_empty() or round(tp_cool_down) <= 0):
		curent_direction = Vector2(-1, -1).normalized()
		return
	

@rpc("any_peer","call_local")
func reset_player_vars():
	ende = false
	level.score[color_cell] = 0
	powerups = [[-1,false,false],[-1,false,false],[-1,false,false]]
	paint_radius = Global.painting_rad
	loaded = false
	Gametriggerstart = false
	pos_array = []
	set_pos = false
	feld = 0
	

func _on_area_2d_area_entered(area: Area2D):
	if area.get_parent().is_in_group("npc") or area.get_parent().is_in_group("player"):
		set_random_direction(false)
		if $powertimers.has_node("0"):
			return
		SPEED = first_speed
		SPEED = SPEED / 2
		$TimerresetSPEED.stop()
		$TimerresetSPEED.start()
		$slow_color.visible = true
		
		
func _on_timerreset_speed_timeout():
	if SPEED < first_speed:
		SPEED += 100
	if SPEED >= first_speed:
		SPEED = first_speed
		$TimerresetSPEED.stop()
		$slow_color.visible = false
