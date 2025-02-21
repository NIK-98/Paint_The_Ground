extends Control

@onready var _1: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/1"
@onready var _2: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/2"
@onready var _3: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/3"
@onready var _4: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/CenterContainer/4"
@onready var main = get_parent().get_parent()
@onready var popup_edit: LineEdit = $PanelContainer/CenterContainer/VBoxContainer/popup_edit
@onready var a: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/A"
@onready var b: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/B"
@onready var c: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/C"
@onready var d: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/D"
@onready var e: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/E"
@onready var f: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/F"
@onready var g: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/G"
@onready var h: Button = $"PanelContainer/CenterContainer/VBoxContainer/1/H"
@onready var i: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/I"
@onready var j: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/J"
@onready var k: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/K"
@onready var l: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/L"
@onready var m: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/M"
@onready var n: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/N"
@onready var o: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/O"
@onready var p: Button = $"PanelContainer/CenterContainer/VBoxContainer/2/P"
@onready var q: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/Q"
@onready var r: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/R"
@onready var s: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/S"
@onready var t: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/T"
@onready var u: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/U"
@onready var v: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/V"
@onready var w: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/W"
@onready var x: Button = $"PanelContainer/CenterContainer/VBoxContainer/3/X"
@onready var y: Button = $"PanelContainer/CenterContainer/VBoxContainer/CenterContainer/4/Y"
@onready var z: Button = $"PanelContainer/CenterContainer/VBoxContainer/CenterContainer/4/Z"

var last_focus_path = ""


var letter = "A"
var big_letter = true

var selected = false
var selected_node = null
var old_max_length = 35
var parent_fild_length = 0


func _ready() -> void:
	visible = false
	get_window().set_ime_active(true)
	

func set_big_small_letter():
	match letter:
		"A":
			letter = "a"
		"B":
			letter = "b"
		"C":
			letter = "c"
		"D":
			letter = "d"
		"E":
			letter = "e"
		"F":
			letter = "f"
		"G":
			letter = "g"
		"H":
			letter = "h"
		"I":
			letter = "i"
		"J":
			letter = "j"
		"K":
			letter = "k"
		"L":
			letter = "l"
		"M":
			letter = "m"
		"N":
			letter = "n"
		"O":
			letter = "o"
		"P":
			letter = "p"
		"Q":
			letter = "q"
		"R":
			letter = "r"
		"S":
			letter = "s"
		"T":
			letter = "t"
		"U":
			letter = "u"
		"V":
			letter = "v"
		"W":
			letter = "w"
		"X":
			letter = "x"
		"Y":
			letter = "y"
		"Z":
			letter = "z"
			
			
		"a":
			letter = "A"
		"b":
			letter = "B"
		"c":
			letter = "C"
		"d":
			letter = "D"
		"e":
			letter = "E"
		"f":
			letter = "F"
		"g":
			letter = "G"
		"h":
			letter = "H"
		"i":
			letter = "I"
		"j":
			letter = "J"
		"k":
			letter = "K"
		"l":
			letter = "L"
		"m":
			letter = "M"
		"n":
			letter = "N"
		"o":
			letter = "O"
		"p":
			letter = "P"
		"q":
			letter = "Q"
		"r":
			letter = "R"
		"s":
			letter = "S"
		"t":
			letter = "T"
		"u":
			letter = "U"
		"v":
			letter = "V"
		"w":
			letter = "W"
		"x":
			letter = "X"
		"y":
			letter = "Y"
		"z":
			letter = "Z"


func _process(delta: float) -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS" or Input.get_connected_joypads().size() > 1:
		if selected and not visible:
			visible = true
			$PanelContainer/CenterContainer/VBoxContainer/popup_edit.grab_focus()
			$PanelContainer/CenterContainer/VBoxContainer/popup_edit.max_length = parent_fild_length
			main.keyboard.visible = true
	
		
func _on_umschalt_pressed() -> void:
	for b in _1.get_children():
		if not b.is_in_group("BUCHSTABEN"):
			continue
		letter = b.text
		set_big_small_letter()
		b.text = letter
	for b in _2.get_children():
		if not b.is_in_group("BUCHSTABEN"):
			continue
		letter = b.text
		set_big_small_letter()
		b.text = letter
	for b in _3.get_children():
		if not b.is_in_group("BUCHSTABEN"):
			continue
		letter = b.text
		set_big_small_letter()
		b.text = letter
	for b in _4.get_children():
		if not b.is_in_group("BUCHSTABEN"):
			continue
		letter = b.text
		set_big_small_letter()
		b.text = letter
	big_letter = not big_letter


func _on_leer_pressed() -> void:
	popup_edit.text += " "
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_loeschen_pressed() -> void:
	popup_edit.text = popup_edit.text.erase(len(popup_edit.text)-1)
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_ok_pressed() -> void:
	selected_node.text = popup_edit.text
	$PanelContainer/CenterContainer/VBoxContainer/popup_edit.text = ""
	visible = false
	get_node(last_focus_path).grab_focus()
	selected = false
	selected_node = null
	$PanelContainer/CenterContainer/VBoxContainer/popup_edit.max_length = old_max_length
	visible = false
	

func _on_a_pressed() -> void:
	popup_edit.text += a.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_b_pressed() -> void:
	popup_edit.text += b.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_c_pressed() -> void:
	popup_edit.text += c.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_d_pressed() -> void:
	popup_edit.text += d.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_e_pressed() -> void:
	popup_edit.text += e.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_f_pressed() -> void:
	popup_edit.text += f.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_g_pressed() -> void:
	popup_edit.text += g.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_h_pressed() -> void:
	popup_edit.text += h.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()
		

func _on_i_pressed() -> void:
	popup_edit.text += i.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_j_pressed() -> void:
	popup_edit.text += j.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()

func _on_k_pressed() -> void:
	popup_edit.text += k.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_l_pressed() -> void:
	popup_edit.text += l.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_m_pressed() -> void:
	popup_edit.text += m.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_n_pressed() -> void:
	popup_edit.text += n.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_o_pressed() -> void:
	popup_edit.text += o.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_p_pressed() -> void:
	popup_edit.text += p.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_q_pressed() -> void:
	popup_edit.text += g.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_r_pressed() -> void:
	popup_edit.text += r.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_s_pressed() -> void:
	popup_edit.text += s.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_t_pressed() -> void:
	popup_edit.text += t.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_u_pressed() -> void:
	popup_edit.text += u.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()
	

func _on_v_pressed() -> void:
	popup_edit.text += v.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_w_pressed() -> void:
	popup_edit.text += w.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_x_pressed() -> void:
	popup_edit.text += x.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_y_pressed() -> void:
	popup_edit.text += y.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()
	

func _on_z_pressed() -> void:
	popup_edit.text += z.text
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_0_pressed() -> void:
	popup_edit.text += "0"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_1_pressed() -> void:
	popup_edit.text += "1"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_2_pressed() -> void:
	popup_edit.text += "2"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()
	

func _on_3_pressed() -> void:
	popup_edit.text += "3"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_4_pressed() -> void:
	popup_edit.text += "4"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()
		

func _on_5_pressed() -> void:
	popup_edit.text += "5"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_6_pressed() -> void:
	popup_edit.text += "6"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_7_pressed() -> void:
	popup_edit.text += "7"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_8_pressed() -> void:
	popup_edit.text += "8"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_9_pressed() -> void:
	popup_edit.text += "9"
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_punkt_pressed() -> void:
	popup_edit.text += "."
	selected_node.text = popup_edit.text
	if big_letter:
		_on_umschalt_pressed()


func _on_clear_pressed() -> void:
	popup_edit.text = ""
	selected_node.text = popup_edit.text
