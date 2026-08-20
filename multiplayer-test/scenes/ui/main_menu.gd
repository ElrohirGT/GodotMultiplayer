extends Control

const WORLD_FOREST = preload("uid://da53df76ffc3c")
const PLAYER = preload("uid://sex8t1i3v61q")

@onready var btn_join: Button = %btnJoin
@onready var btn_quit: Button = %btnQuit

@onready var username: LineEdit = %username
@onready var session_id: LineEdit = %sessionId
@onready var btn_host_tube: Button = %btnHostTube
@onready var btn_join_tube: Button = %btnJoinTube
@onready var btn_quit_tube: Button = %btnQuitTube

@onready var enet_menu: VBoxContainer = $Center/MarginContainer/HBoxContainer/EnetMenu
@onready var tube_menu: VBoxContainer = $Center/MarginContainer/HBoxContainer/TubeMenu

func _ready() -> void:
	if Network.tube_enabled:
		enet_menu.hide()
	else:
		tube_menu.hide()
	
	btn_join.pressed.connect(on_join)
	btn_quit.pressed.connect(func(): get_tree().quit())
	
	session_id.text_changed.connect(update_session)
	username.text_changed.connect(update_username)
	
	btn_join_tube.disabled = true
	btn_join_tube.pressed.connect(on_join_tube)
	btn_host_tube.pressed.connect(on_host_tube)
	btn_quit_tube.pressed.connect(func(): get_tree().quit())
	
	Network.tube_client.error_raised.connect(on_error_raised)
	
	if OS.has_feature("server"):
		Network.start_server()
		add_world.call_deferred()
	
func on_join():
	Network.join_server()
	add_world()
	# add_player()

func add_world():
	var new_world = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child(new_world)
	hide()

func add_player():
	var new_player = PLAYER.instantiate()
	get_tree().current_scene.add_child(new_player)

func on_join_tube():
	Network.tube_join(session_id.text)
	multiplayer.connected_to_server.connect(add_world)

func on_host_tube():
	Network.tube_create()
	add_world()

func update_session(new_text: String):
	if new_text != "":
		btn_join_tube.disabled = false
	
func update_username(new_text: String):
	Global.username = new_text

func on_error_raised(_code, _message):
	session_id.text = ""
	btn_join_tube.add_theme_color_override("font_disabled_color", Color.DARK_RED)
	btn_join_tube.disabled = true
	Network.clean_up_signals()
