extends Node

var forest: Node3D
var spawn_container: Node3D
var username: String
var player: Player

const BALL = preload("uid://cww8t5m62gx6p")

@rpc("any_peer", "call_local")
func shoot_ball(position: Vector3, dir: Vector3, force: float):
	var new_ball: RigidBody3D = BALL.instantiate()
	new_ball.position = position + Vector3(0, -0.5, 0) + (dir*2.0)
	var force_vec = dir*force
	spawn_container.add_child(new_ball, true)
	new_ball.apply_central_force(force_vec)

@rpc("any_peer", "call_local")
func loose_life():
	print("Player ", player, " lost life!")
	player.loose_life()

@rpc("any_peer", "call_local")
func reset_player():
	print("Player ", player, " RESET!")
	player.reset_player()
