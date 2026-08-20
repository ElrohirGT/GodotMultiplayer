extends RigidBody3D

class_name Ball

@onready var alive_timer: Timer = %aliveTimer

func _ready() -> void:
	if not is_multiplayer_authority():
		pass
	alive_timer.timeout.connect(delete_ball)

func delete_ball():
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not is_multiplayer_authority():
		return
	
	if body.is_in_group("Players"):
		queue_free()
		
		var player: Player = body as Player
		if player:
			print("Player should loose life! ", player.name)
			Global.loose_life.rpc_id(int(player.name))
