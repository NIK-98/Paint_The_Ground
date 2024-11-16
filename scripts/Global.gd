extends Node

var Standard_Spielfeld_Size = Vector2(1280,800)
var Spielfeld_Size = Standard_Spielfeld_Size
const Spawn_bomben_limit = 6
const Spawn_powerup_limit = 4
const npc_einfach = 15
const npc_normal = 20
const npc_schwer = 30
var npcs_anzahl = 3
var count_npcs = 1
var speed_npcs = 15.0
var speed_player = 20.0
var painting_rad = 2
var standart_powerup_spawn_time = 10
var standart_bomben_spawn_time = 5
var trigger_audio_menu = false
var trigger_host_focus = false
var trigger_grafik_menu = false
var trigger_input_menu = false

var music1_sound = false
var hit_sound = false
var powerup_sound = false
var bombe_sound = false
var ui_sound = false
var ui_hover_sound = false

var esc_is_pressing_in_game = false
