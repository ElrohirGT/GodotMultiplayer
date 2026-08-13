extends Control

const WORLD_FOREST = preload("uid://da53df76ffc3c")
const PLAYER = preload("uid://sex8t1i3v61q")

@onready var btn_join: Button = %btnJoin
@onready var btn_quit: Button = %btnQuit

func _ready() -> void:
	btn_join.pressed.connect(on_join)
	btn_quit.pressed.connect(func(): get_tree().quit())
	
	if OS.has_feature("server"):
		add_world.call_deferred()
	
func on_join():
	add_world()
	add_player()

func add_world():
	var new_world = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child(new_world)
	hide()

func add_player():
	var new_player = PLAYER.instantiate()
	get_tree().current_scene.add_child(new_player)
	
