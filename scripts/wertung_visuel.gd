extends ColorRect

var max_x_pixel = Vector2(575,30)
var is_npc = false


@rpc("any_peer","call_local")
func update_var(id: int, max_wert: int):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		var new_size =Vector2(get_parent().get_parent().get_parent().get_parent().get_node("Players").get_node(str(id)).score*max_x_pixel.x/max_wert, max_x_pixel.y)
		custom_minimum_size = floor(new_size)
	
func update_var_npc(id: int, max_wert: int):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		var new_size =Vector2(get_parent().get_parent().get_parent().get_parent().get_node("Players").get_node(str(id)).score*max_x_pixel.x/max_wert, max_x_pixel.y)
		custom_minimum_size = floor(new_size)
