extends HBoxContainer

@onready var animation_player: AnimationPlayer = $TextureRect/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $TextureRect2/AnimationPlayer2
@onready var animation_player_3: AnimationPlayer = $TextureRect3/AnimationPlayer3

var is_npc = false
var cached_textures = {
	"speedup": preload("res://assets/powerups/speedup.png"),
	"bigrad": preload("res://assets/powerups/bigrad.png"),
	"protect": preload("res://assets/powerups/protect.png"),
	"empty": preload("res://assets/powerups/empty.png")
}


@rpc("any_peer","call_local")
func animate_rest_time(powerup):
	if powerup == 0:
		play_animation_on_server(animation_player, "rest")
	if powerup == 1:
		play_animation_on_server(animation_player_2, "rest2")
	if powerup == 2:
		play_animation_on_server(animation_player_3, "rest3")
		
		

@rpc("any_peer","call_local")
func update_icon(powerups):
	if powerups[0][1] == true and powerups[0][0] == 0:
		$TextureRect.texture = cached_textures["speedup"]
		stop_animation_on_server(animation_player)
	if powerups[1][1] == true and powerups[1][0] == 1:
		$TextureRect2.texture = cached_textures["bigrad"]
		stop_animation_on_server(animation_player_2)
	if powerups[2][1] == true and powerups[2][0] == 2:
		$TextureRect3.texture = cached_textures["protect"]
		stop_animation_on_server(animation_player_3)



@rpc("any_peer","call_local")
func clear_icon(powerups):
	if powerups[0][1] == false and powerups[0][0] == -1:
		$TextureRect.texture = cached_textures["empty"]
		stop_animation_on_server(animation_player)
	if powerups[1][1] == false and powerups[1][0] == -1:
		$TextureRect2.texture = cached_textures["empty"]
		stop_animation_on_server(animation_player_2)
	if powerups[2][1] == false and powerups[2][0] == -1:
		$TextureRect3.texture = cached_textures["empty"]
		stop_animation_on_server(animation_player_3)
		

func play_animation_on_server(APlayer:AnimationPlayer, animation_name: String):
	APlayer.play(animation_name)
	

func stop_animation_on_server(APlayer:AnimationPlayer):
	APlayer.stop()
