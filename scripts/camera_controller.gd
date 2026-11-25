extends Node3D
class_name CameraController

## Smooth Third-Person Camera Rig for Mobile
## Follows the player with a SpringArm3D to prevent clipping into walls,
## supporting both mouse and multi-touch swipe rotation.

@export var target_node: NodePath
@export var follow_speed: float = 12.0
@export var min_pitch: float = -45.0
@export var max_pitch: float = 30.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var target: Node3D = null
var current_pitch: float = -15.0
var current_yaw: float = 0.0

func _ready() -> void:
	if has_node(target_node):
		target = get_node(target_node) as Node3D

func _process(delta: float) -> void:
	if not target:
		return
	
	# Smoothly interpolate position towards target
	global_position = global_position.lerp(target.global_position + Vector3(0, 1.2, 0), follow_speed * delta)

func apply_look_delta(delta: Vector2) -> void:
	current_yaw -= deg_to_rad(delta.x)
	current_pitch -= delta.y
	current_pitch = clamp(current_pitch, min_pitch, max_pitch)
	
	rotation.y = current_yaw
	spring_arm.rotation_degrees.x = current_pitch
