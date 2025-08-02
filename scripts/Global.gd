extends Node

var Standard_Spielfeld_Size = Vector2i(20,12)
var Spielfeld_Size = Standard_Spielfeld_Size
const Spawn_bomben_limit = 6
const Spawn_powerup_limit = 4
const Spawn_coins_limit = 5
const npc_einfach = 650.0
const npc_normal = 800.0
const npc_schwer = 1200.0
var npcs_anzahl = 3
var count_npcs = 1
var speed_npcs = 800.0
var speed_player = 800.0
var painting_rad = 2
var trigger_audio_menu = false
var trigger_host_focus = false
var trigger_grafik_menu = false
var trigger_input_menu = false
var trigger_shop_menu = false
var load_menu_showed = false
var trigger_look = false
var trigger_look_id = 0
var look_set_wall = ["res://resources/tilesets/wall.tres","res://resources/tilesets/wall2.tres"]
var look_set_ground = ["res://resources/tilesets/floor.tres","res://resources/tilesets/floor2.tres"]


const tracks = ["res://assets/sounds/Paint_The_Ground_game.ogg","res://assets/sounds/Paint_The_Ground_Sound_loop_Version.ogg","res://assets/sounds/Paint_The_Ground_Moving_Sound.ogg"]
var music1_sound = false
var music1_replay = false
var selected_music_sound = "res://assets/sounds/Paint_The_Ground_game.ogg"
var stop_main_theama = false
var hit_sound = false
var powerup_sound = false
var bombe_sound = false
var ui_sound = false
var ui_hover_sound = false
var coin_sound = false
var tp_sound = false

var menu = false
var akzept = ""

var load_score_path = ""
var ui_focus = false
