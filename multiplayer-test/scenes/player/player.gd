extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
@onready var nameplate: Label3D = $Nameplate
@onready var btn_leave: Button = %btnLeave
@onready var menu: Control = %PauseMenu
@onready var label_session: Label = %labelSession
@onready var btn_copy_session: Button = %btnCopySession
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# Died Menu
@onready var died_menu: PanelContainer = %DiedMenu
@onready var btn_respawn: Button = %btnRespawn
@onready var btn_exit: Button = %btnExit

# Mobile controls
@onready var move_joystick: VirtualJoystick = %move_joystick
@onready var see_joystick: VirtualJoystick = %see_joystick
@onready var btn_fire: TextureButton = %btnFire
@onready var btn_pause: Button = %btnPause


@export var sensitivity: float = 0.005
@export var mobileSensitivity: float = 0.5
@export var initialLife = 3

@export var life = initialLife

var immobile = false
func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready() -> void:
	add_to_group("Players")
	life = initialLife
	nameplate.text = self.name
	menu.hide()
	if OS.has_feature("mobile"):
		move_joystick.show()
		see_joystick.show()
		btn_fire.show()
		btn_pause.show()
	else:
		move_joystick.hide()
		see_joystick.hide()
		btn_fire.hide()
		btn_pause.hide()
	
	if not is_multiplayer_authority():
		# set_process(false)
		set_physics_process(false)
		canvas_layer.hide()
		return
	
	btn_respawn.pressed.connect(reset_player)
	
	btn_fire.pressed.connect(shoot)
	btn_pause.pressed.connect(func (): open_menu(menu.visible))
	label_session.text = Network.tube_client.session_id
	camera_3d.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	btn_leave.pressed.connect(func(): Network.leave_server())
	btn_exit.pressed.connect(func(): Network.leave_server())
	btn_copy_session.pressed.connect(func(): DisplayServer.clipboard_set(Network.tube_client.session_id))
	DisplayServer.clipboard_set(Network.tube_client.session_id)

func open_menu(current_visibility: bool):
	menu.visible = !current_visibility
	immobile = menu.visible
	
	if not OS.has_feature("mobile"):
		if menu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var look_dir := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if not immobile:
		head.rotate_y(-look_dir.x * mobileSensitivity)
		camera_3d.rotate_x(-look_dir.y * mobileSensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if immobile:
		direction = Vector3.ZERO
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not menu.visible and life > 0:
		head.rotate_y(-event.relative.x * sensitivity)
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta: float) -> void:
	nameplate.text = "%s - %d" % [self.name, self.life]
	if not is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("ui_cancel") and life > 0:
		open_menu(menu.visible)
	if immobile:
		return
	if Input.is_action_just_pressed("ui_click"):
		shoot()

func loose_life():
	life -= 1
	if life <= 0:
		died_menu.show()
		menu.hide()
		immobile = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func reset_player():
	print("Resetting player ", self)
	life = initialLife
	immobile = false
	menu.hide()
	died_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.global_position = Vector3.UP * 2

func shoot():
	var facing_dir = -head.transform.basis.z
	var force = 300
	
	Global.shoot_ball.rpc_id(1, self.global_position, facing_dir, force)
