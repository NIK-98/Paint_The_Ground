extends MultiplayerSynchronizer

@export var move = Input.get_vector("left","right","up","down")

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(delta):
	move = Input.get_vector("left","right","up","down")
