extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var main = get_parent().get_parent().get_parent().get_parent()
@onready var level = get_parent().get_parent()
@export var timer_power_up: PackedScene


var first_speed = Global.speed_player
var SPEED = first_speed
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
@export var paint_radius = Global.painting_rad

var powerups = [[-1,false,false],[-1,false,false],[-1,false,false]] #[0] = id,[1] = aktive,[2] = timer created
var power_time = [10,8,5]


# Zoom-Grenzen festlegen
var min_zoom = 0.8
var max_zoom = 2.0

@onready var camera = $Camera2D
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
	
func _ready():
	if name.to_int() == multiplayer.get_unique_id():
		camera.make_current()
	level.visibility_npc_settings.rpc()
	level.get_node("loby").update_player_count.rpc_id(multiplayer.get_unique_id(), true)
	$CanvasLayer/Winner.visible = false
	$CanvasLayer/Los.visible = false
	$Camera2D.limit_right = Global.Spielfeld_Size.x
	$Camera2D.limit_bottom = Global.Spielfeld_Size.y
	color_change()
	position = Vector2(randi_range(player_spawn_grenze,Global.Spielfeld_Size.x-player_spawn_grenze-$Color.size.x),randi_range(player_spawn_grenze,Global.Spielfeld_Size.y-player_spawn_grenze-$Color.size.y))


func _physics_process(_delta):
	if not loaded:
		loaded = true
		sync_hide_win_los_meldung.rpc(name.to_int())
		map.reset_floor()
		paint()
		score_counter()
	
	
	if level.get_node("CanvasLayer/Time").visible:
		if not Gametriggerstart:
			Gametriggerstart = true
		if level.get_node("CanvasLayer/Time").text.to_int() > 0:
			if name.to_int() == multiplayer.get_unique_id():
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
				paint()
			score_counter()
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
					Global.powerup_sound = true
					if not $TimerresetSPEED.is_stopped():
						$TimerresetSPEED.stop()
					$slow_color.visible = false
					
					
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
			

@rpc("any_peer","call_local")
func sync_show_win_los_meldung(id):
	var obj_id = id
	if obj_id == multiplayer.get_unique_id():
		for i in level.get_node("Werten/PanelContainer/Wertung/werte").get_children():
			if i.text.to_int() > level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(name)).text.to_int():
				get_node("CanvasLayer/Los").visible = true
				break
		if not get_node("CanvasLayer/Los").visible:
			get_node("CanvasLayer/Winner").visible = true


@rpc("any_peer","call_local")
func sync_hide_win_los_meldung(id):
	var obj_id = id
	if obj_id == multiplayer.get_unique_id():
		get_node("CanvasLayer/Winner").visible = false
		get_node("CanvasLayer/Los").visible = false
	

func moving():
	if OS.has_feature("dedicated_server"):
		return
	if OS.get_name() == "Android" or OS.get_name() == "IOS":
		if main.get_node("CanvasLayer/joy").get_joystick_dir().x > 0.45 or Input.is_action_pressed("pad_right"):
			Input.action_press("right")
		else:
			Input.action_release("right")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().x < -0.45 or Input.is_action_pressed("pad_left"):
			Input.action_press("left")
		else:
			Input.action_release("left")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().y > 0.45 or Input.is_action_pressed("pad_down"):
			Input.action_press("down")
		else:
			Input.action_release("down")
		if main.get_node("CanvasLayer/joy").get_joystick_dir().y < -0.45 or Input.is_action_pressed("pad_up"):
			Input.action_press("up")
		else:
			Input.action_release("up")
				

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 0.9  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1  # Zoom out

		# Zoom-Grenzen anwenden
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	
	if Input.is_action_pressed("zoomin") and not level.get_node("Scoreboard/CanvasLayer").visible:
		camera.zoom *= 0.9  # Zoom in
		# Zoom-Grenzen anwenden
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	if Input.is_action_pressed("zoomout") and not level.get_node("Scoreboard/CanvasLayer").visible:
		camera.zoom *= 1.1  # Zoom out
		# Zoom-Grenzen anwenden
		camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
		camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
	

func score_counter():
	last_score = score
	score = len(map.get_used_cells_by_id(color_cell))
	
	if level.get_node("Werten/PanelContainer/Wertung/werte").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer/Wertung/werte").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung/werte").get_node(str(name)).wertung.rpc(name.to_int())
		
	if level.get_node("Werten/PanelContainer2/visual").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer2/visual").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer2/visual").get_node(str(name)).update_var.rpc(score, 1000)
	
	if level.get_node("Werten/PanelContainer/Wertung/powerlist").get_child_count() > 0:
		if not level.get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(name)).update_icon.rpc(powerups)
		

func paint():
	var tile_position = map.local_to_map(Vector2(position.x+($Color.size.x/2),position.y+($Color.size.y/2)))
	for x in range(-paint_radius,paint_radius):
		for y in range(-paint_radius,paint_radius):
			var pos = Vector2i(x,y) + tile_position
			var distance = pos.distance_to(tile_position)
			if map.get_cell_source_id(pos) != -1 and map.get_cell_source_id(pos) not in level.block_cells and distance < paint_radius:
				map.set_cell(pos,color_cell,Vector2i(0,0),0)
		
		
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
	

func reset_player_vars():
	ende = false
	loaded = false
	Gametriggerstart = false
	score = 0
	powerups = [[-1,false,false],[-1,false,false],[-1,false,false]]
	paint_radius = Global.painting_rad


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
		SPEED += 1
	if SPEED == first_speed:
		$TimerresetSPEED.stop()
		$slow_color.visible = false
