extends Area3D

## BuildingEntrance
## Placed at the entrance portal of Tower 7.
## Allows the player to enter the building, completing Mission 1 and loading the interior.

@export var target_scene: String = "res://scenes/main.tscn"

var player_in_zone: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		MissionManager.play_dialogue("SYSTEM", "TOWER 7 LOBBY ENTRANCE. Press INTERACT to enter.", 3.0)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("fire"):
		enter_tower()

func enter_tower() -> void:
	MissionManager.complete_mission(1)
	MissionManager.play_dialogue("ANNOUNCER", "Welcome to Tower 7. Please badge in at Reception.", 3.5)
	get_tree().change_scene_to_file(target_scene)
