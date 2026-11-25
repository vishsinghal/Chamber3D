extends Node

## Autoload GameManager
## Manages global game state, score, health, waves, and mobile pause states.

signal score_changed(new_score: int)
signal wave_changed(new_wave: int)
signal player_health_changed(current_hp: int, max_hp: int)
signal game_over
signal game_restarted

var current_score: int = 0
var current_wave: int = 1
var enemies_alive: int = 0
var is_game_active: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_new_game() -> void:
	current_score = 0
	current_wave = 1
	enemies_alive = 0
	is_game_active = true
	get_tree().paused = false
	emit_signal("score_changed", current_score)
	emit_signal("wave_changed", current_wave)
	emit_signal("game_restarted")

func add_score(points: int) -> void:
	if not is_game_active:
		return
	current_score += points
	emit_signal("score_changed", current_score)

func next_wave() -> void:
	if not is_game_active:
		return
	current_wave += 1
	emit_signal("wave_changed", current_wave)

func update_player_health(current: int, max_hp: int) -> void:
	emit_signal("player_health_changed", current, max_hp)

func trigger_game_over() -> void:
	is_game_active = false
	emit_signal("game_over")

func toggle_pause() -> bool:
	get_tree().paused = not get_tree().paused
	return get_tree().paused
