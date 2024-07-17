extends MultiplayerSynchronizer

@export var move = Input.get_vector("left","right","up","down")

var aktueller_spieler = false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(_delta):
	if is_multiplayer_authority():
		if get_parent().position.x < get_parent().get_node("Color").size.x:
			Input.action_release("left")
			
		if get_parent().position.x+get_parent().get_node("Color").size.x > Global.Spielfeld_Size.x-get_parent().get_node("Color").size.x:
			Input.action_release("right")
			
		if get_parent().position.y < get_parent().get_node("Color").size.y:
			Input.action_release("up")
			
		if get_parent().position.y+get_parent().get_node("Color").size.y > Global.Spielfeld_Size.y-get_parent().get_node("Color").size.y:
			Input.action_release("down")
		moving()
			
			
		aktueller_spieler = true
	else:
		aktueller_spieler = false
		
func moving():
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		move = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("CanvasLayer/joy").get_joystick_dir()
	else:
		move = Input.get_vector("left","right","up","down")
