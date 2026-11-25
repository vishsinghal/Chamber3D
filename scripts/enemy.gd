extends CharacterBody3D
class_name EnemyDrone

## 3D Mobile Sci-Fi AI Drone
## State-machine behavior: Patrol -> Chase -> Attack
## Procedurally animated rotating shields, eye light, and destruction particles.

enum State { PATROL, CHASE, ATTACK }

@export var move_speed: float = 4.5
@export var chase_speed: float = 6.0
@export var attack_range: float = 2.0
@export var detection_range: float = 16.0
@export var max_health: int = 50
@export var attack_damage: int = 15
@export var attack_cooldown: float = 1.2
@export var score_value: int = 100

var current_health: int = 50
var state: State = State.PATROL
var target_player: Player = null
var can_attack: bool = true
var attack_timer: float = 0.0

@onready var mesh_root: Node3D = $MeshRoot
@onready var ring_inner: Node3D = $MeshRoot/RingInner
@onready var ring_outer: Node3D = $MeshRoot/RingOuter
@onready var eye_light: OmniLight3D = $MeshRoot/EyeLight
@onready var death_particles: CPUParticles3D = $DeathParticles

var patrol_timer: float = 0.0
var patrol_dir: Vector3 = Vector3.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	_find_player()
	_pick_new_patrol_dir()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0] as Player

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	
	# Rotate futuristic visual rings procedurally
	if ring_inner:
		ring_inner.rotate_y(2.5 * delta)
		ring_inner.rotate_x(1.2 * delta)
	if ring_outer:
		ring_outer.rotate_y(-1.8 * delta)
		ring_outer.rotate_z(1.5 * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if not target_player or not is_instance_valid(target_player):
		_find_player()
		return

	var dist_to_player = global_position.distance_to(target_player.global_position)

	match state:
		State.PATROL:
			patrol_timer -= delta
			if patrol_timer <= 0.0:
				_pick_new_patrol_dir()
			
			velocity.x = patrol_dir.x * move_speed
			velocity.z = patrol_dir.z * move_speed
			
			if dist_to_player < detection_range:
				state = State.CHASE
				
		State.CHASE:
			var dir_to_player = (target_player.global_position - global_position)
			dir_to_player.y = 0.0
			dir_to_player = dir_to_player.normalized()
			
			velocity.x = dir_to_player.x * chase_speed
			velocity.z = dir_to_player.z * chase_speed
			
			# Face movement direction
			if dir_to_player.length_squared() > 0.01:
				var target_angle = atan2(-dir_to_player.x, -dir_to_player.z)
				mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_angle, 8.0 * delta)
			
			if dist_to_player <= attack_range:
				state = State.ATTACK
			elif dist_to_player > detection_range * 1.5:
				state = State.PATROL
				
		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
			
			if attack_timer > 0.0:
				attack_timer -= delta
			else:
				_perform_attack()
				attack_timer = attack_cooldown
				
			if dist_to_player > attack_range * 1.3:
				state = State.CHASE

	move_and_slide()

func _pick_new_patrol_dir() -> void:
	patrol_timer = randf_range(2.0, 4.0)
	var angle = randf() * TAU
	patrol_dir = Vector3(cos(angle), 0, sin(angle)).normalized()

func _perform_attack() -> void:
	if not target_player or not is_instance_valid(target_player):
		return
	
	AudioController.play_hit_sfx()
	target_player.take_damage(attack_damage)
	
	# Attack pulse animation
	var tween = create_tween()
	tween.tween_property(mesh_root, "scale", Vector3(1.3, 1.3, 1.3), 0.1)
	tween.tween_property(mesh_root, "scale", Vector3(1.0, 1.0, 1.0), 0.15)

func take_damage(amount: int) -> void:
	current_health -= amount
	AudioController.play_hit_sfx()
	
	# Damage flash
	var tween = create_tween()
	tween.tween_property(mesh_root, "position:y", 0.3, 0.05)
	tween.tween_property(mesh_root, "position:y", 0.0, 0.08)
	
	if current_health <= 0:
		die()

func die() -> void:
	AudioController.play_explosion_sfx()
	GameManager.add_score(score_value)
	GameManager.enemies_alive = max(0, GameManager.enemies_alive - 1)
	
	# Detach death explosion particles
	if death_particles:
		death_particles.reparent(get_parent())
		death_particles.global_position = global_position
		death_particles.restart()
		death_particles.emitting = true
		
		get_tree().create_timer(1.0).timeout.connect(death_particles.queue_free)
	
	queue_free()
