extends Node

const PLAYER = preload("uid://sex8t1i3v61q")

var enet_peer = ENetMultiplayerPeer.new()

@export var PORT = 6969
@export var IP_ADDRESS = "127.0.0.1"

func start_server():
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id: int):
	if peer_id == 1:
		return
	
	var new_player = PLAYER.instantiate()
	new_player.name = str(peer_id)
	get_tree().current_scene.add_child(new_player, true)

func on_peer_connected(peer_id: int):
	add_player(peer_id)
	
func join_server():
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	enet_peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = enet_peer

func on_peer_disconnected(peer_id: int):
	if peer_id == 1:
		leave_server()
	
	var players: Array[Node] = get_tree().get_nodes_in_group("Players")
	var players_to_remove = players.find_custom(func(item): return item.name == str(peer_id))
	if players_to_remove != -1:
		players[players_to_remove].queue_free()

func on_connected_to_server():
	add_player(multiplayer.get_unique_id())

func leave_server():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	clean_up_signals()
	
	get_tree().reload_current_scene()

func clean_up_signals():
	multiplayer.peer_connected.disconnect(on_peer_connected)
	multiplayer.peer_disconnected.disconnect(on_peer_disconnected)
	multiplayer.connected_to_server.disconnect(on_connected_to_server)
