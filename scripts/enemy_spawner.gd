extends Node3D
class_name EnemySpawner

## 3D Arena Wave Spawner
## Dynamically spawns cyber drones around the arena in waves,
## scaling difficulty and announcing wave transitions to HUD.

@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var arena_radius: float = 18.0
@export var base_enemies_per_wave: int = 4
@export var wave_cooldown: float = 3.5

var current_wave_count: int = 0
var is_wave_in_progress: bool = false
var time_until_next_wave: float = 2.0

func _ready() -> void:
	GameManager.game_restarted.connect(_on_game_restarted)

func _on_game_restarted() -> void:
	# Clear remaining enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	time_until_next_wave = 2.0
	is_wave_in_progress = false

func _process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	
	if not is_wave_in_progress:
		time_until_next_wave -= delta
		if time_until_next_wave <= 0.0:
			_start_wave()
	else:
		if GameManager.enemies_alive <= 0:
			is_wave_in_progress = false
			GameManager.next_wave()
			time_until_next_wave = wave_cooldown

func _start_wave() -> void:
	is_wave_in_progress = true
	var wave_num = GameManager.current_wave
	var count = base_enemies_per_wave + (wave_num * 2)
	GameManager.enemies_alive = count
	
	for i in range(count):
		_spawn_enemy()
		await get_tree().create_timer(0.35).timeout

func _spawn_enemy() -> void:
	if not enemy_scene:
		return
	
	var angle = randf() * TAU
	var dist = randf_range(8.0, arena_radius)
	var spawn_pos = Vector3(cos(angle) * dist, 1.0, sin(angle) * dist)
	
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos
