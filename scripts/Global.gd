extends Node

var Standard_Spielfeld_Size = Vector2i(20,12)
var Spielfeld_Size = Standard_Spielfeld_Size
const Spawn_bomben_limit = 6
const Spawn_powerup_limit = 4
const Spawn_coins_limit = 5
const npc_einfach = 650.0
const npc_normal = 800.0
const npc_schwer = 950.0
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

var music1_sound = false
var stop_main_theama = false
var hit_sound = false
var powerup_sound = false
var bombe_sound = false
var ui_sound = false
var ui_hover_sound = false
var coin_sound = false

var menu = false
var akzept = ""
var temp_virtual_keyboard_text = ""
