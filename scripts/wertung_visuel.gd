extends ColorRect

var max_x_pixel = Vector2(575,30)
var is_npc = false


@rpc("any_peer","call_local")
func update_var(id: int):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		var new_size =Vector2(get_parent().get_parent().get_parent().get_parent().get_node("Players").get_node(str(id)).score*max_x_pixel.x/get_parent().get_parent().get_parent().get_parent().get_node("floor").get_felder_summe(Global.Spielfeld_Size, Vector2i(64,64)), max_x_pixel.y)
		custom_minimum_size = floor(new_size)
	
func update_var_npc(id: int):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		var new_size =Vector2(get_parent().get_parent().get_parent().get_parent().get_node("Players").get_node(str(id)).score*max_x_pixel.x/get_parent().get_parent().get_parent().get_parent().get_node("floor").get_felder_summe(Global.Spielfeld_Size, Vector2i(64,64)), max_x_pixel.y)
		custom_minimum_size = floor(new_size)
