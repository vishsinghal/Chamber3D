extends Node3D

## MainLevel - Tower 7 Ground Floor & Central Atrium
## Manages lighting states (normal -> blackout emergency amber),
## elevator breakdown, and enemy drone activation.

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun_light: DirectionalLight3D = $DirectionalLight3D
@onready var spawner: EnemySpawner = $EnemySpawner

func _ready() -> void:
	# Trigger the exciting story event
	_sequence_story()

func _sequence_story() -> void:
	await get_tree().create_timer(1.0).timeout
	MissionManager.play_dialogue("Priya", "Neil! Over here near the elevators. Did you see the server logs?", 3.5)
	
	await get_tree().create_timer(4.0).timeout
	# Power failure / Blackout sequence!
	AudioController.play_explosion_sfx()
	_trigger_blackout()
	
	MissionManager.complete_mission(1)
	MissionManager.start_mission(2)
	MissionManager.play_dialogue("SYNAPSE-7", "WARNING! TOWER 7 LOCKDOWN ACTIVATED. ALL BIOLOGICAL ASSETS MUST REMAIN INSIDE.", 5.0)
	
	await get_tree().create_timer(5.5).timeout
	MissionManager.play_dialogue("Marcus", "Neil! The turnstiles and elevators just locked. We're trapped! Find my keycard in the kitchen!", 5.0)

func _trigger_blackout() -> void:
	# Flickering amber/red emergency lighting
	var tween = create_tween().set_loops(3)
	tween.tween_property(sun_light, "light_energy", 0.1, 0.1)
	tween.tween_property(sun_light, "light_energy", 1.2, 0.1)
	
	await tween.finished
	sun_light.light_color = Color(1.0, 0.25, 0.1)
	sun_light.light_energy = 0.4
