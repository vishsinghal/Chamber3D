extends Control
class_name VirtualJoystick

## Multi-Touch Virtual Joystick for Mobile (Android & iOS)
## Handles multi-touch events, dynamic placement or fixed position,
## deadzones, and output vector normalization.

signal joystick_updated(output: Vector2)

@export var max_radius: float = 80.0
@export var deadzone: float = 0.15
@export var clampzone: float = 80.0
@export var is_dynamic: bool = true

@onready var base: Control = $Base
@onready var tip: Control = $Base/Tip

var active_touch_id: int = -1
var output_vector: Vector2 = Vector2.ZERO
var initial_base_pos: Vector2

func _ready() -> void:
	initial_base_pos = base.position
	_reset_joystick()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_touch_id == -1 and _is_point_inside(event.position):
				active_touch_id = event.index
				if is_dynamic:
					base.global_position = event.position - base.size * 0.5
				_update_tip(event.position)
		elif event.index == active_touch_id:
			_reset_joystick()
			
	elif event is InputEventScreenDrag and event.index == active_touch_id:
		_update_tip(event.position)

func _is_point_inside(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)

func _update_tip(touch_pos: Vector2) -> void:
	var center = base.global_position + (base.size * 0.5)
	var offset = touch_pos - center
	var dist = offset.length()
	
	if dist > clampzone:
		offset = offset.normalized() * clampzone
		
	tip.position = (base.size * 0.5) + offset - (tip.size * 0.5)
	
	var norm_offset = offset / clampzone
	if norm_offset.length() < deadzone:
		output_vector = Vector2.ZERO
	else:
		output_vector = norm_offset
		
	emit_signal("joystick_updated", output_vector)

func _reset_joystick() -> void:
	active_touch_id = -1
	output_vector = Vector2.ZERO
	if is_dynamic:
		base.position = initial_base_pos
	tip.position = (base.size - tip.size) * 0.5
	emit_signal("joystick_updated", Vector2.ZERO)
