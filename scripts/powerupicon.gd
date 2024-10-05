extends HBoxContainer

var is_npc = false


@rpc("any_peer","call_local")
func update_icon(powerups):
	if powerups[0][1] == true and powerups[0][0] == 0:
		$TextureRect.texture = load("res://assets/powerups/speedup.png")
	if powerups[1][1] == true and powerups[1][0] == 1:
		$TextureRect2.texture = load("res://assets/powerups/bigrad.png")
	if powerups[2][1] == true and powerups[2][0] == 2:
		$TextureRect3.texture = load("res://assets/powerups/protect.png")
	


func update_icon_npc(powerups):
	if powerups[0][1] == true and powerups[0][0] == 0:
		$TextureRect.texture = load("res://assets/powerups/speedup.png")
	if powerups[1][1] == true and powerups[1][0] == 1:
		$TextureRect2.texture = load("res://assets/powerups/bigrad.png")
	if powerups[2][1] == true and powerups[2][0] == 2:
		$TextureRect3.texture = load("res://assets/powerups/protect.png")


@rpc("any_peer","call_local")
func clear_icon(powerups):
	if powerups[0][1] == false and powerups[0][0] == -1:
		$TextureRect.texture = load("res://assets/powerups/empty.png")
	if powerups[1][1] == false and powerups[1][0] == -1:
		$TextureRect2.texture = load("res://assets/powerups/empty.png")
	if powerups[2][1] == false and powerups[2][0] == -1:
		$TextureRect3.texture = load("res://assets/powerups/empty.png")
				

func clear_icon_npc(powerups):
	if powerups[0][1] == false and powerups[0][0] == -1:
		$TextureRect.texture = load("res://assets/powerups/empty.png")
	if powerups[1][1] == false and powerups[1][0] == -1:
		$TextureRect2.texture = load("res://assets/powerups/empty.png")
	if powerups[2][1] == false and powerups[2][0] == -1:
		$TextureRect3.texture = load("res://assets/powerups/empty.png")
