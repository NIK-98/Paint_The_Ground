extends ColorRect

var max_x_pixel = Vector2(575,30)
var is_npc = false


func update_var(id, score):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		custom_minimum_size = Vector2(score*max_x_pixel.x/get_parent().get_parent().get_parent().get_parent().get_node("floor").felder_summe, max_x_pixel.y)
