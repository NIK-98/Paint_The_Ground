extends CharacterBody2D

@onready var map = get_parent().get_parent().get_node("floor")
@onready var level = get_parent().get_parent()


const SPEED = 10
var score = 0
var last_score = score
var color_cell = 0
var loaded = false
var npc_spawn_grenze = 200
var Gametriggerstart = false
var ende = false
@export var paint_radius = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	color_change()
	position = Vector2(randi_range(npc_spawn_grenze,Global.Spielfeld_Size.x-npc_spawn_grenze-$Color.size.x),randi_range(npc_spawn_grenze,Global.Spielfeld_Size.y-npc_spawn_grenze-$Color.size.y))

func _physics_process(delta):	
	if not loaded:
		loaded = true
		paint.rpc()
		score_counter.rpc()
	
	if not get_parent().get_parent().get_node("CanvasLayer/Start").visible and get_parent().get_parent().starting:
		if not Gametriggerstart:
			Gametriggerstart = true
			map.reset_floor()
			paint.rpc()
			score_counter.rpc()
			Check_Time_Visible.rpc()
			level.get_node("Timer").start()
			level.get_node("Timerbomb").start()
		if level.get_node("CanvasLayer/Time").visible and not level.Time_out:
			paint.rpc()
			score_counter.rpc()
			velocity = move()*SPEED*delta
			move_and_collide(velocity)
		elif level.Time_out and not ende:
			ende = true
			if name.to_int() == multiplayer.get_unique_id():
				for i in level.get_node("Werten/PanelContainer/Wertung").get_children():
					if i.text.to_int() > level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).text.to_int():
						get_node("CanvasLayer/Los").visible = true
						break
				if not get_node("CanvasLayer/Los").visible:
					get_node("CanvasLayer/Winner").visible = true
			level.get_node("Timerende").start()

func color_change():
	for i in range(len(get_parent().get_children())):
		if get_parent().get_node(str(name)) != null and i == 0:
			color_cell = 7
			get_node("Color").set_color(Color.SADDLE_BROWN)
			get_node("Name").set("theme_override_colors/font_color",Color.SADDLE_BROWN)
			get_node("CanvasLayer/Winner").set_color(Color.SADDLE_BROWN)
			get_node("CanvasLayer/Los").set_color(Color.SADDLE_BROWN)
								
func change_paint_rad():
	var radius_varscheinlichkeit = [2,2,2,2,2,4] #1/6 chance auf grösseren radius
	paint_radius = radius_varscheinlichkeit.pick_random()
	
	
@rpc("any_peer","call_local")
func paint():
	var tile_position = map.local_to_map(position)
	for x in range(paint_radius):
		for y in range(paint_radius):
			var pos = Vector2i(x,y) + tile_position
			if map.get_cell_source_id(pos) != -1:
				map.set_cell(pos,color_cell,Vector2i(0,0),0)
				
				
@rpc("any_peer","call_local")
func score_counter():
	last_score = score
	score = len(map.get_used_cells_by_id(color_cell))
	if level.get_node("Werten/PanelContainer/Wertung").get_child_count() > 0 and last_score != score:
		if not level.get_node("Werten/PanelContainer/Wertung").has_node(str(name)):
			return
		level.get_node("Werten/PanelContainer/Wertung").get_node(str(name)).wertung.rpc(name.to_int())
		

@rpc("any_peer","call_local")
func Check_Time_Visible():
	for i in level.get_node("CanvasLayer").get_children():
		if i.is_in_group("time"):
			if not i.visible:
				i.visible = true


func move():
	var entfernung = abs(get_parent().get_child(0).position - position).length()
	var direction = get_parent().get_child(0).position - position
	direction.normalized()
	if entfernung <= 1000:
		return direction
	else:
		return Vector2(0,0)
		
