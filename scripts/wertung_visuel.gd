extends ColorRect

var max_x_pixel = Vector2(575,30)
var is_npc = false


@rpc("any_peer","call_local")
func update_var(id, score):
	if get_parent().get_parent().get_parent().get_parent().get_node("Players").has_node(str(id)):
		custom_minimum_size = floor(Vector2(score*max_x_pixel.x/get_parent().get_parent().get_parent().get_parent().get_node("floor").get_felder_summe(get_parent().get_parent().get_parent().get_parent().map_enden, Vector2i(64,64)), max_x_pixel.y))
