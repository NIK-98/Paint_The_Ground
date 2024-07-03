extends MultiplayerSynchronizer

@export var move = Input.get_vector("left","right","up","down")

var aktueller_spieler = false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(_delta):
	if is_multiplayer_authority():
		if OS.get_name() == "Android" or OS.get_name() == "iOS":
			move = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("CanvasLayer/joy").get_joystick_dir()
		else:
			move = Input.get_vector("left","right","up","down")
		aktueller_spieler = true
	else:
		aktueller_spieler = false
