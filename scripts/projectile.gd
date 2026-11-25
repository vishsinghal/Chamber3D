extends Area3D
class_name Projectile

## 3D Plasma Bolt Projectile
## Moves in target direction, hits enemies or environment,
## triggers particle burst, and frees itself after lifetime.

@export var speed: float = 30.0
@export var damage: int = 25
@export var lifetime: float = 2.0

var direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0

@onready var particles: CPUParticles3D = $TrailParticles
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()
	look_at(global_position + direction, Vector3.UP)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_explode_and_free()
	elif body.is_in_group("environment"):
		_explode_and_free()

func _explode_and_free() -> void:
	# Detach particles for natural fade out
	if particles:
		particles.emitting = false
	queue_free()
