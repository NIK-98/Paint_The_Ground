extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var wall = get_parent().get_parent().get_node("wall")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var level = get_parent().get_parent()
@onready var coins = get_parent().get_parent().get_node("Coins")
@export var timer_power_up: PackedScene


var first_speed = Global.speed_player
var SPEED = first_speed
var spawn = position
var is_moving = true
var map_enden = Vector2.ZERO
@export var color_cell = 0
var loaded = false
var Gametriggerstart = false
var count_gegner_cellen = {1:0,2:0,3:0,4:0}
var count_cellen = 0
@export var score = 0
var d_score = 0 # Durchschnitz score einer runde
var move = Vector2i.ZERO
var player_spawn_grenze = 200
var ende = false
var input_mode = 0 # 0=pc 1=controller
var zoom_old = 1
const cooldown_time_tp = 1
var tp_cool_down = cooldown_time_tp
@export var feld = 1
var pos_array = []
var set_pos = false
@export var paint_radius = Global.painting_rad
var portal_free = true

@export var magnet = true

@export var team = "Red"

@export var powerups = [[-1,false,false],[-1,false,false],[-1,false,false]] #[0] = id,[1] = aktive,[2] = timer created
const standard_power_time = [10,8,5]
var power_time = [10,8,5]

# Zoom-Grenzen festlegen
var min_zoom = 0.3
var max_zoom = 2.0

@onready var camera: Camera2D = $Camera2D

	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
	
func _ready():
	if name.to_int() == multiplayer.get_unique_id():
		camera.make_current()
	level.get_node("loby").update_player_count.rpc_id(multiplayer.get_unique_id(), true)
	$CanvasLayer/Winner.visible = false
	$CanvasLayer/Los.visible = false
	if not level.get_node("loby").vs_mode:
		color_change()


func _physics_process(_delta):
	if not loaded:
		loaded = true
		sync_hide_win_los_meldung.rpc(name.to_int())
	if not set_pos and not map.array_floor.is_empty():
		set_pos = true
		var map_pos = map.dict_floor_with_portal_id[randi_range(1,4)]
		for i in map_pos:
			pos_array.append(map.map_to_local(i))
		position = pos_array.pick_random()
	if not map.array_floor.is_empty() and map.get_tp_feld(position) != null:
		feld = map.get_tp_feld(position)[1]
	if level.get_node("loby/CenterContainer/HBoxContainer/VBoxContainer/Warten").text == "Alle Player bereit!":
		if not Gametriggerstart:
			Gametriggerstart = true
			map_enden = map.map_to_local(Global.Spielfeld_Size)
			main.get_node("CanvasLayer/change").visible = true
	if level.get_node("CanvasLayer/Time").visible:
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			if name.to_int() == multiplayer.get_unique_id():
				moving()
					
				velocity = move*SPEED
				move_and_slide()
				
				if magnet:
					magnet_trigger.rpc_id(1, name.to_int())
					
					
		elif level.get_node("CanvasLayer/Time").text.to_int() == 0 and not ende:
			ende = true
			main.get_node("CanvasLayer/change").visible = false
			for c in $powertimers.get_children():
				c.stop()
				c.queue_free()
			if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
				if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(name)):
					return
				level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).clear_icon.rpc(powerups)
			sync_show_win_los_meldung.rpc(name.to_int())
			if get_node("CanvasLayer/Winner").visible:
				d_score = 0
				for d in get_parent().get_children():
					d_score += d.score
				d_score /= len(get_parent().get_children())
				main.get_node("money/coin_display").set_money(d_score)
	
	
@rpc("any_peer","call_local")
func magnet_trigger(id: int):
	for c in coins.get_children():
		var coin_dist = position.distance_to(c.position)
		if coin_dist < c.magnet_craft and c.magnet_id == 0:
			c.magnet_id = id
	
	
func _process(delta):
	if level.get_node("CanvasLayer/Time").visible:
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			paint()
			if level.get_node("loby").tp_mode:
				tp_cool_down -= delta
				if round(tp_cool_down) <= 0:
					if portal_free and map.is_vaild_portal(position):
						portal_free = false
						tp_cool_down = cooldown_time_tp
						Global.tp_sound = true
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
	
	
@rpc("any_peer","call_local")
func sync_show_win_los_meldung(id):
	var obj_id: int = id
	if obj_id == multiplayer.get_unique_id():
		for i in level.get_node("Werten/PanelContainer/Wertung/werte").get_children():
			if not level.get_node("loby").vs_mode:
				if i.text.to_int() > level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(name)).text.to_int():
					get_node("CanvasLayer/Los").visible = true
					break
			else:
				if i.text.to_int() > level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(team)).text.to_int():
					get_node("CanvasLayer/Los").visible = true
					break
		if not get_node("CanvasLayer/Los").visible:
			get_node("CanvasLayer/Winner").visible = true


@rpc("any_peer","call_local")
func sync_hide_win_los_meldung(id):
	var obj_id: int = id
	if obj_id == multiplayer.get_unique_id():
		get_node("CanvasLayer/Winner").visible = false
		get_node("CanvasLayer/Los").visible = false
	

func moving():
	if OS.has_feature("dedicated_server"):
		return
	if OS.get_name() == "Android" or OS.get_name() == "IOS":
		if (main.get_node("CanvasLayer/joy").get_joystick_dir().x > 0.45 or Input.is_action_pressed("pad_right") or Input.is_action_pressed("right")):
			move.x = 1
		elif (main.get_node("CanvasLayer/joy").get_joystick_dir().x < -0.45 or Input.is_action_pressed("pad_left") or Input.is_action_pressed("left")):
			move.x = -1
		else:
			move.x = 0
		if (main.get_node("CanvasLayer/joy").get_joystick_dir().y > 0.45 or Input.is_action_pressed("pad_down") or Input.is_action_pressed("down")):
			move.y = 1
		elif (main.get_node("CanvasLayer/joy").get_joystick_dir().y < -0.45 or Input.is_action_pressed("pad_up") or Input.is_action_pressed("up")):
			move.y = -1
		else:
			move.y = 0
	else:
		if (Input.is_action_pressed("pad_right") or Input.is_action_pressed("right")):
			move.x = 1
		elif (Input.is_action_pressed("pad_left") or Input.is_action_pressed("left")):
			move.x = -1
		else:
			move.x = 0
		if (Input.is_action_pressed("pad_down") or Input.is_action_pressed("down")):
			move.y = 1
		elif (Input.is_action_pressed("pad_up") or Input.is_action_pressed("up")):
			move.y = -1
		else:
			move.y = 0

			
func _input(event):
	if event is InputEventKey:
		input_mode = 0
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_mode = 1

		# Zoom-Grenzen anwenden
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	if zoom_old != main.get_node("Grafik").zoom.value and not level.get_node("Scoreboard/CanvasLayer").visible:
		zoom_old = main.get_node("Grafik").zoom.value
		camera.zoom.x = main.get_node("Grafik").zoom.value  # Zoom
		camera.zoom.y = main.get_node("Grafik").zoom.value  # Zoom
		# Zoom-Grenzen anwenden
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
		

func paint():
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
				if cell_id != -1 and cell_id != 5 and wall_cell_id != 0 and cell_id != color_cell and cell_id not in block_cells and map.is_portal_id_ok(new_pos, feld):
					if wall_cell_id != -1:
						continue
					if cell_id != 0:
						count_gegner_cellen[cell_id] += 1
					count_cellen += 1
					paint_array.append(new_pos)
	
	BetterTerrain.set_cells(map, paint_array, color_cell)
	BetterTerrain.update_terrain_cells(map, paint_array)

		
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
	


@rpc("any_peer","call_local")
func reset_player_vars():
	ende = false
	score = 0
	powerups = [[-1,false,false],[-1,false,false],[-1,false,false]]
	paint_radius = Global.painting_rad
	loaded = false
	Gametriggerstart = false
	pos_array = []
	set_pos = false
	feld = 0
	

func _on_area_2d_area_entered(area: Area2D):
	if area.get_parent().is_in_group("npc") or area.get_parent().is_in_group("player"):
		if $powertimers.has_node("0"):
			return
		SPEED = first_speed
		SPEED = SPEED / 2
		$TimerresetSPEED.stop()
		$TimerresetSPEED.start()
		Global.hit_sound = true
		$slow_color.visible = true
		

func _on_timerreset_speed_timeout():
	if SPEED < first_speed:
		SPEED += 100
	if SPEED >= first_speed:
		SPEED = first_speed
		$TimerresetSPEED.stop()
		$slow_color.visible = false
