extends Control
class_name TouchLookZone

## Touch drag area for 3D Camera Orbit on Mobile
## Detects finger swipes on the right half of the screen
## and converts them into yaw and pitch deltas for the camera controller.

signal camera_look_delta(delta: Vector2)

@export var sensitivity: float = 0.25

var touch_id: int = -1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_id == -1 and get_global_rect().has_point(event.position):
				touch_id = event.index
		elif event.index == touch_id:
			touch_id = -1
			
	elif event is InputEventScreenDrag and event.index == touch_id:
		var look_delta = event.relative * sensitivity
		emit_signal("camera_look_delta", look_delta)
