extends MultiplayerSynchronizer

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(_delta):
	if is_multiplayer_authority():
		pass
		

	
