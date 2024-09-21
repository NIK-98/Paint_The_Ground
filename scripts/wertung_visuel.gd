extends ColorRect


var max_x_pixel = Vector2(575,30)
var is_npc = false


@rpc("any_peer","call_local")
func update_var(wert: int, max_wert: int):
	var new_size =Vector2(wert*max_x_pixel.x/max_wert, max_x_pixel.y)
	custom_minimum_size = new_size
	
func update_var_npc(wert: int, max_wert: int):
	var new_size =Vector2(wert*max_x_pixel.x/max_wert, max_x_pixel.y)
	custom_minimum_size = new_size
