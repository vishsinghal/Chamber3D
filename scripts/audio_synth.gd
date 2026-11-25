extends Node

## Autoload AudioController
## Generates lightweight procedural sound effects (laser shot, explosion, hit, dash)
## using AudioStreamGenerator to ensure zero download footprint on Mac storage.

var sample_hz: float = 22050.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_laser_sfx() -> void:
	_play_synthesized_tone(0.12, 880.0, 220.0, 0.4)

func play_hit_sfx() -> void:
	_play_synthesized_tone(0.08, 300.0, 100.0, 0.5)

func play_explosion_sfx() -> void:
	_play_synthesized_noise(0.25, 0.6)

func play_dash_sfx() -> void:
	_play_synthesized_tone(0.15, 200.0, 600.0, 0.3)

func _play_synthesized_tone(duration: float, start_freq: float, end_freq: float, volume: float) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_hz
	generator.buffer_length = duration + 0.05
	player.stream = generator
	player.play()
	
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var total_frames: int = int(duration * sample_hz)
	var phase: float = 0.0
	
	for i in range(total_frames):
		var t = float(i) / float(total_frames)
		var current_freq = lerp(start_freq, end_freq, t)
		var amp = (1.0 - t) * volume
		var sample = sin(phase * TAU) * amp
		phase = fmod(phase + current_freq / sample_hz, 1.0)
		playback.push_frame(Vector2(sample, sample))
	
	await get_tree().create_timer(duration + 0.1).timeout
	player.queue_free()

func _play_synthesized_noise(duration: float, volume: float) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_hz
	generator.buffer_length = duration + 0.05
	player.stream = generator
	player.play()
	
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var total_frames: int = int(duration * sample_hz)
	
	for i in range(total_frames):
		var t = float(i) / float(total_frames)
		var amp = (1.0 - t) * volume
		var noise = (randf() * 2.0 - 1.0) * amp
		playback.push_frame(Vector2(noise, noise))
	
	await get_tree().create_timer(duration + 0.1).timeout
	player.queue_free()
