extends Control

@onready var _1: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/1"
@onready var _2: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/2"
@onready var _3: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/3"
@onready var _4: HBoxContainer = $"PanelContainer/CenterContainer/VBoxContainer/CenterContainer/4"

var letter = "A"
var big_letter = true


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
	if big_letter:
		_on_umschalt_pressed()


func _on_loeschen_pressed() -> void:
	if big_letter:
		_on_umschalt_pressed()


func _on_ok_pressed() -> void:
	visible = false


func _on_a_pressed() -> void:
	pass # Replace with function body.


func _on_b_pressed() -> void:
	pass # Replace with function body.


func _on_c_pressed() -> void:
	pass # Replace with function body.


func _on_d_pressed() -> void:
	pass # Replace with function body.


func _on_e_pressed() -> void:
	pass # Replace with function body.


func _on_f_pressed() -> void:
	pass # Replace with function body.


func _on_g_pressed() -> void:
	pass # Replace with function body.


func _on_h_pressed() -> void:
	pass # Replace with function body.


func _on_i_pressed() -> void:
	pass # Replace with function body.


func _on_j_pressed() -> void:
	pass # Replace with function body.


func _on_k_pressed() -> void:
	pass # Replace with function body.


func _on_l_pressed() -> void:
	pass # Replace with function body.


func _on_m_pressed() -> void:
	pass # Replace with function body.


func _on_n_pressed() -> void:
	pass # Replace with function body.


func _on_o_pressed() -> void:
	pass # Replace with function body.


func _on_p_pressed() -> void:
	pass # Replace with function body.


func _on_q_pressed() -> void:
	pass # Replace with function body.


func _on_r_pressed() -> void:
	pass # Replace with function body.


func _on_s_pressed() -> void:
	pass # Replace with function body.


func _on_t_pressed() -> void:
	pass # Replace with function body.


func _on_u_pressed() -> void:
	pass # Replace with function body.


func _on_v_pressed() -> void:
	pass # Replace with function body.


func _on_w_pressed() -> void:
	pass # Replace with function body.


func _on_x_pressed() -> void:
	pass # Replace with function body.


func _on_y_pressed() -> void:
	pass # Replace with function body.


func _on_z_pressed() -> void:
	pass # Replace with function body.


func _on_0_pressed() -> void:
	pass # Replace with function body.


func _on_1_pressed() -> void:
	pass # Replace with function body.


func _on_2_pressed() -> void:
	pass # Replace with function body.


func _on_3_pressed() -> void:
	pass # Replace with function body.


func _on_4_pressed() -> void:
	pass # Replace with function body.


func _on_5_pressed() -> void:
	pass # Replace with function body.


func _on_6_pressed() -> void:
	pass # Replace with function body.


func _on_7_pressed() -> void:
	pass # Replace with function body.


func _on_8_pressed() -> void:
	pass # Replace with function body.


func _on_9_pressed() -> void:
	pass # Replace with function body.


func _on_punkt_pressed() -> void:
	pass # Replace with function body.
