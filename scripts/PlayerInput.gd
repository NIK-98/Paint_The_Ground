extends MultiplayerSynchronizer

@export var move = Input.get_vector("left","right","up","down")

var aktueller_spieler = false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(_delta):
	if is_multiplayer_authority():
		move = Input.get_vector("left","right","up","down")
		aktueller_spieler = true
	else:
		aktueller_spieler = false
