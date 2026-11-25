extends CharacterBody3D
class_name Player

## 3D Mobile Character Controller
## Handles 3D kinematics, dual-stick mobile input, dash dodging, shooting,
## and procedural character lean/tilt animation.

@export var move_speed: float = 8.0
@export var sprint_multiplier: float = 1.4
@export var acceleration: float = 24.0
@export var friction: float = 20.0
@export var dash_speed: float = 22.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

@export var max_health: int = 100
var current_health: int = 100

@export var fire_rate: float = 0.18
var can_fire: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cd_timer: float = 0.0

var projectile_scene = preload("res://scenes/projectile.tscn")

@onready var muzzle: Marker3D = $Muzzle
@onready var mesh_root: Node3D = $MeshRoot
@onready var dash_particles: CPUParticles3D = $DashParticles

# Mobile virtual input vector supplied by VirtualJoystick
var virtual_move_dir: Vector2 = Vector2.ZERO
var virtual_aim_dir: Vector2 = Vector2.ZERO

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	current_health = max_health
	GameManager.update_player_health(current_health, max_health)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	
	# Handle dash timers
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	if dash_cd_timer > 0.0:
		dash_cd_timer -= delta

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Combine physical keyboard/gamepad and touch joystick inputs
	var input_vector = Vector2.ZERO
	if virtual_move_dir.length_squared() > 0.01:
		input_vector = virtual_move_dir
	else:
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	# Align movement direction with camera view
	var cam = get_viewport().get_camera_3d()
	var cam_forward = Vector3.FORWARD
	var cam_right = Vector3.RIGHT
	if cam:
		cam_forward = -cam.global_transform.basis.z
		cam_forward.y = 0.0
		cam_forward = cam_forward.normalized()
		cam_right = cam.global_transform.basis.x
		cam_right.y = 0.0
		cam_right = cam_right.normalized()

	var target_dir = (cam_right * input_vector.x + cam_forward * -input_vector.y).normalized()

	if is_dashing:
		# Maintain dash velocity
		pass
	elif target_dir.length_squared() > 0.01:
		velocity.x = move_toward(velocity.x, target_dir.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_dir.z * move_speed, acceleration * delta)
		
		# Smoothly rotate mesh towards movement or aim
		var target_angle = atan2(-target_dir.x, -target_dir.z)
		mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_angle, 14.0 * delta)
		
		# Procedural tilt for high-speed dynamic mobile feel
		mesh_root.rotation.z = lerp(mesh_root.rotation.z, -input_vector.x * 0.15, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)
		mesh_root.rotation.z = lerp(mesh_root.rotation.z, 0.0, 10.0 * delta)

	move_and_slide()

	# Mobile auto-fire or continuous fire check
	if Input.is_action_pressed("fire") and can_fire:
		shoot()

func shoot() -> void:
	if not can_fire or not GameManager.is_game_active:
		return
	
	can_fire = false
	AudioController.play_laser_sfx()
	
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = muzzle.global_position
	
	# Fire forward along player mesh facing direction
	var shoot_dir = -mesh_root.global_transform.basis.z
	proj.set_direction(shoot_dir)
	
	# Procedural recoil
	mesh_root.position.z = 0.15
	var tween = create_tween()
	tween.tween_property(mesh_root, "position:z", 0.0, 0.1)
	
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func dash() -> void:
	if is_dashing or dash_cd_timer > 0.0:
		return
	
	is_dashing = true
	dash_timer = dash_duration
	dash_cd_timer = dash_cooldown
	
	var dash_dir = -mesh_root.global_transform.basis.z
	velocity.x = dash_dir.x * dash_speed
	velocity.z = dash_dir.z * dash_speed
	
	if dash_particles:
		dash_particles.restart()
		dash_particles.emitting = true
	
	AudioController.play_dash_sfx()

func take_damage(amount: int) -> void:
	if is_dashing or not GameManager.is_game_active:
		return # Invulnerable during dash
	
	current_health -= amount
	AudioController.play_hit_sfx()
	GameManager.update_player_health(current_health, max_health)
	
	# Red flash effect
	var tween = create_tween()
	tween.tween_property(mesh_root, "scale", Vector3(1.2, 0.8, 1.2), 0.06)
	tween.tween_property(mesh_root, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	
	if current_health <= 0:
		die()

func die() -> void:
	AudioController.play_explosion_sfx()
	GameManager.trigger_game_over()
	visible = false
	set_physics_process(false)
