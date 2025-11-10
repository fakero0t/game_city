extends Node
## SoundManager - Singleton for managing game sound effects
## Handles playing correct answer chimes and incorrect answer thuds
## Uses procedurally generated sounds with AudioStreamGenerator

# Audio players for sound effects
var correct_player: AudioStreamPlayer
var incorrect_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var triumph_player: AudioStreamPlayer
var laser_player: AudioStreamPlayer

func _ready() -> void:
	# Create audio players
	correct_player = AudioStreamPlayer.new()
	incorrect_player = AudioStreamPlayer.new()
	click_player = AudioStreamPlayer.new()
	triumph_player = AudioStreamPlayer.new()
	laser_player = AudioStreamPlayer.new()
	
	add_child(correct_player)
	add_child(incorrect_player)
	add_child(click_player)
	add_child(triumph_player)
	add_child(laser_player)
	
	# Try to load sound files from assets/sounds/
	# If files don't exist, generate procedural sounds or use retro sci-fi sounds
	var correct_sound_path = "res://assets/Free Retro Sci-Fi Sound Fx/14 Retro Explosion #1.mp3"
	var incorrect_sound_path = "res://assets/sounds/incorrect_thud.wav"
	var click_sound_path = "res://assets/sounds/click.wav"
	var triumph_sound_path = "res://assets/sounds/triumph.wav"
	var laser_sound_path = "res://assets/Free Retro Sci-Fi Sound Fx/03 Retro Lazer #3.mp3"
	
	if ResourceLoader.exists(correct_sound_path):
		correct_player.stream = load(correct_sound_path)
	else:
		correct_player.stream = _create_correct_beep()
	
	if ResourceLoader.exists(incorrect_sound_path):
		incorrect_player.stream = load(incorrect_sound_path)
	else:
		incorrect_player.stream = _create_incorrect_thud()
	
	if ResourceLoader.exists(click_sound_path):
		click_player.stream = load(click_sound_path)
	else:
		click_player.stream = _create_click_sound()
	
	if ResourceLoader.exists(triumph_sound_path):
		triumph_player.stream = load(triumph_sound_path)
	else:
		triumph_player.stream = _create_triumph_sound()
	
	if ResourceLoader.exists(laser_sound_path):
		laser_player.stream = load(laser_sound_path)
	else:
		laser_player.stream = _create_click_sound()
	
	# Set volume (adjust as needed)
	correct_player.volume_db = -10.0
	incorrect_player.volume_db = -10.0
	click_player.volume_db = -12.0
	triumph_player.volume_db = -8.0
	laser_player.volume_db = -13.0
	
	# Set pitch scale to make laser sound shorter and snappier
	laser_player.pitch_scale = 2.0

## Play positive chime sound for correct answers
func play_correct_sound() -> void:
	if correct_player and correct_player.stream:
		correct_player.play()

## Play dull thud sound for incorrect answers
func play_incorrect_sound() -> void:
	if incorrect_player and incorrect_player.stream:
		incorrect_player.play()

## Play click sound for button presses
func play_click_sound() -> void:
	if click_player and click_player.stream:
		click_player.play()

## Play triumphant sound for completing all activities
func play_triumph_sound() -> void:
	if triumph_player and triumph_player.stream:
		triumph_player.play()

## Play laser sound for shooting
func play_laser_sound() -> void:
	if laser_player and laser_player.stream:
		laser_player.play()

## Create a three-tone ascending chime using AudioStreamWAV
func _create_correct_beep() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.4  # Total duration in seconds
	var sample_count = int(sample_rate * duration)
	
	# Create audio data array
	var data = PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit samples = 2 bytes per sample
	
	# Generate three ascending tones (C5, E5, G5)
	var frequencies = [523.25, 659.25, 783.99]
	var tone_duration = duration / 3.0
	var samples_per_tone = int(sample_rate * tone_duration)
	
	var write_pos = 0
	for freq in frequencies:
		for i in range(samples_per_tone):
			var t = float(i) / float(sample_rate)
			var envelope = 1.0 - (float(i) / float(samples_per_tone))  # Fade out
			var value = sin(2.0 * PI * freq * t) * envelope
			var sample_value = int(value * 16000.0)  # Scale to 16-bit range
			
			# Clamp to 16-bit range
			sample_value = clamp(sample_value, -32768, 32767)
			
			# Write as little-endian 16-bit
			if write_pos < data.size() - 1:
				data[write_pos] = sample_value & 0xFF
				data[write_pos + 1] = (sample_value >> 8) & 0xFF
				write_pos += 2
	
	# Create AudioStreamWAV from data
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	return stream

## Create a low thud sound using AudioStreamWAV
func _create_incorrect_thud() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.3  # Duration in seconds
	var sample_count = int(sample_rate * duration)
	
	# Create audio data array
	var data = PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit samples = 2 bytes per sample
	
	# Generate low frequency thud (120 Hz with quick decay)
	var frequency = 120.0
	
	var write_pos = 0
	for i in range(sample_count):
		var t = float(i) / float(sample_rate)
		var envelope = exp(-t * 10.0)  # Quick exponential decay
		var value = sin(2.0 * PI * frequency * t) * envelope
		var sample_value = int(value * 20000.0)  # Scale to 16-bit range
		
		# Clamp to 16-bit range
		sample_value = clamp(sample_value, -32768, 32767)
		
		# Write as little-endian 16-bit
		if write_pos < data.size() - 1:
			data[write_pos] = sample_value & 0xFF
			data[write_pos + 1] = (sample_value >> 8) & 0xFF
			write_pos += 2
	
	# Create AudioStreamWAV from data
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	return stream

## Create a short click sound using AudioStreamWAV
func _create_click_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.05  # Very short 50ms
	var sample_count = int(sample_rate * duration)
	
	# Create audio data array
	var data = PackedByteArray()
	data.resize(sample_count * 2)
	
	# Generate a short click with high frequency (2000 Hz)
	var frequency = 2000.0
	
	var write_pos = 0
	for i in range(sample_count):
		var t = float(i) / float(sample_rate)
		var envelope = 1.0 - (float(i) / float(sample_count))  # Quick fade
		var value = sin(2.0 * PI * frequency * t) * envelope
		var sample_value = int(value * 12000.0)
		
		sample_value = clamp(sample_value, -32768, 32767)
		
		if write_pos < data.size() - 1:
			data[write_pos] = sample_value & 0xFF
			data[write_pos + 1] = (sample_value >> 8) & 0xFF
			write_pos += 2
	
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	return stream

## Create a triumphant fanfare sound using AudioStreamWAV
func _create_triumph_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 1.2  # Longer celebratory sound
	var sample_count = int(sample_rate * duration)
	
	# Create audio data array
	var data = PackedByteArray()
	data.resize(sample_count * 2)
	
	# Generate triumphant ascending scale: C5, E5, G5, C6 (major chord arpeggio)
	var frequencies = [523.25, 659.25, 783.99, 1046.50]
	var tone_duration = duration / 4.0
	var samples_per_tone = int(sample_rate * tone_duration)
	
	var write_pos = 0
	for freq in frequencies:
		for i in range(samples_per_tone):
			var t = float(i) / float(sample_rate)
			var envelope = 1.0 - (float(i) / float(samples_per_tone * 1.5))  # Slower fade
			envelope = clamp(envelope, 0.0, 1.0)
			var value = sin(2.0 * PI * freq * t) * envelope
			var sample_value = int(value * 18000.0)
			
			sample_value = clamp(sample_value, -32768, 32767)
			
			if write_pos < data.size() - 1:
				data[write_pos] = sample_value & 0xFF
				data[write_pos + 1] = (sample_value >> 8) & 0xFF
				write_pos += 2
	
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	return stream

