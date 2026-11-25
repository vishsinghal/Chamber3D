extends CanvasLayer
class_name MobileHUD

## Complete Mobile HUD & Touch Controller
## Connects multi-touch VirtualJoystick and TouchLookZone to Player and Camera,
## displays health, score, wave banner, and handles pause / game over UI.

@onready var joystick: VirtualJoystick = $Control/VirtualJoystick
@onready var look_zone: TouchLookZone = $Control/TouchLookZone
@onready var fire_button: Button = $Control/ActionButtons/FireButton
@onready var dash_button: Button = $Control/ActionButtons/DashButton
@onready var pause_button: Button = $Control/TopBar/PauseButton

@onready var health_bar: ProgressBar = $Control/TopBar/HealthBar
@onready var score_label: Label = $Control/TopBar/ScoreLabel
@onready var wave_label: Label = $Control/TopBar/WaveLabel

@onready var game_over_panel: Panel = $Control/GameOverPanel
@onready var final_score_label: Label = $Control/GameOverPanel/FinalScoreLabel
@onready var restart_button: Button = $Control/GameOverPanel/RestartButton

@onready var pause_panel: Panel = $Control/PausePanel
@onready var resume_button: Button = $Control/PausePanel/ResumeButton

var player: Player = null
var camera_controller: CameraController = null

func _ready() -> void:
	game_over_panel.visible = false
	pause_panel.visible = false
	
	# Connect GameManager signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.player_health_changed.connect(_on_health_changed)
	GameManager.game_over.connect(_on_game_over)
	
	# Connect UI buttons
	fire_button.button_down.connect(_on_fire_down)
	dash_button.pressed.connect(_on_dash_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Connect virtual controls
	joystick.joystick_updated.connect(_on_joystick_updated)
	look_zone.camera_look_delta.connect(_on_camera_look_delta)
	
	_find_actors()

func _find_actors() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Player
	
	var cameras = get_tree().get_nodes_in_group("camera_controller")
	if cameras.size() > 0:
		camera_controller = cameras[0] as CameraController

func _on_joystick_updated(vector: Vector2) -> void:
	if not player:
		_find_actors()
	if player:
		player.virtual_move_dir = vector

func _on_camera_look_delta(delta: Vector2) -> void:
	if not camera_controller:
		_find_actors()
	if camera_controller:
		camera_controller.apply_look_delta(delta)

func _on_fire_down() -> void:
	if not player:
		_find_actors()
	if player:
		player.shoot()

func _on_dash_pressed() -> void:
	if not player:
		_find_actors()
	if player:
		player.dash()

func _on_score_changed(score: int) -> void:
	score_label.text = "SCORE: %06d" % score

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "WAVE %d" % wave

func _on_health_changed(hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = hp

func _on_pause_pressed() -> void:
	var paused = GameManager.toggle_pause()
	pause_panel.visible = paused

func _on_resume_pressed() -> void:
	GameManager.toggle_pause()
	pause_panel.visible = false

func _on_game_over() -> void:
	final_score_label.text = "FINAL SCORE: %d\nWAVE SURVIVED: %d" % [GameManager.current_score, GameManager.current_wave]
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	game_over_panel.visible = false
	GameManager.start_new_game()
	get_tree().reload_current_scene()
