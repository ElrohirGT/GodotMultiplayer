extends RigidBody3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not is_multiplayer_authority():
		return
	
	if body.is_in_group("Players"):
		queue_free()
