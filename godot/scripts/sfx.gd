# Sfx: all audio, synthesised at runtime into AudioStreamWAV buffers (no audio
# files). Provides one-shot SFX plus a looping chiptune background track.
#
# NOTE (web/CrazyGames): browser autoplay policy requires audio to begin only
# after a user gesture. CrazyGames also requires muting during ads — the master
# bus mute (toggled from the HUD) covers that.
extends Node
class_name Sfx

const RATE := 22050
var music_player: AudioStreamPlayer

# ---- one-shot tones ----
func _tone(freq: float, dur: float, type: String, vol: float, slide_to: float) -> void:
	var n := int(RATE * dur)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		var f := freq
		if slide_to > 0.0:
			f = freq + (slide_to - freq) * (t / dur)
		phase += TAU * f / RATE
		var s := _wave(type, phase)
		var env := exp(-3.0 * t / dur)
		var v: float = clamp(s * env * vol, -1.0, 1.0)
		bytes.encode_s16(i * 2, int(v * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = wav
	p.play()
	p.finished.connect(p.queue_free)

func _wave(type: String, phase: float) -> float:
	match type:
		"square": return sign(sin(phase))
		"saw": return fmod(phase / TAU, 1.0) * 2.0 - 1.0
		"tri": return asin(sin(phase)) * 0.63662
		_: return sin(phase)

func crash() -> void:
	_tone(150, 0.35, "square", 0.45, 40)
	_tone(80, 0.4, "saw", 0.35, 30)

func near_miss() -> void:
	_tone(900, 0.12, "sine", 0.16, 1500)

func collect() -> void:
	# little ascending arpeggio
	_tone(660, 0.10, "square", 0.3, 0)
	await get_tree().create_timer(0.09).timeout
	_tone(880, 0.10, "square", 0.3, 0)
	await get_tree().create_timer(0.09).timeout
	_tone(1320, 0.16, "square", 0.3, 0)

func game_over() -> void:
	_tone(400, 0.6, "saw", 0.32, 80)

func ui_click() -> void:
	_tone(520, 0.05, "square", 0.22, 720)

# ---- looping background music ----
func play_music() -> void:
	if music_player and is_instance_valid(music_player):
		return
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = _build_music()
	music_player.volume_db = -9.0
	music_player.play()

func stop_music() -> void:
	if music_player and is_instance_valid(music_player):
		music_player.stop()

func _build_music() -> AudioStreamWAV:
	var bpm := 128.0
	var beat := 60.0 / bpm
	var N := {
		"R": 0.0, "C4": 262.0, "D4": 294.0, "E4": 330.0, "F4": 349.0, "G4": 392.0, "A4": 440.0,
		"B4": 494.0, "C5": 523.0, "D5": 587.0, "E5": 659.0, "F5": 698.0, "G5": 784.0,
		"A5": 880.0, "B5": 988.0, "C6": 1047.0,
	}
	# Three distinct 16-beat phrases sequenced A-B-C-B (64 beats ≈ 30s) so the
	# loop feels like a tune rather than an 8-second repeat.
	var phrase_a := [
		["E5", 0.5], ["G5", 0.5], ["A5", 1.0], ["G5", 0.5], ["E5", 0.5], ["D5", 1.0],
		["C5", 0.5], ["D5", 0.5], ["E5", 1.0], ["G5", 0.5], ["A5", 0.5], ["G5", 1.0],
		["E5", 0.5], ["D5", 0.5], ["C5", 1.0], ["D5", 0.5], ["E5", 0.5], ["D5", 1.0],
		["C5", 2.0], ["R", 2.0],
	]
	var phrase_b := [
		["G5", 0.5], ["A5", 0.5], ["C6", 1.0], ["A5", 0.5], ["G5", 0.5], ["E5", 1.0],
		["F5", 0.5], ["G5", 0.5], ["A5", 1.0], ["G5", 0.5], ["F5", 0.5], ["E5", 1.0],
		["D5", 0.5], ["E5", 0.5], ["F5", 1.0], ["A5", 0.5], ["G5", 0.5], ["F5", 1.0],
		["E5", 2.0], ["R", 2.0],
	]
	var phrase_c := [
		["C5", 1.0], ["E5", 1.0], ["G5", 1.0], ["E5", 1.0],
		["A4", 1.0], ["C5", 1.0], ["E5", 1.0], ["C5", 1.0],
		["F4", 1.0], ["A4", 1.0], ["C5", 1.0], ["A4", 1.0],
		["G4", 2.0], ["R", 2.0],
	]
	var melody := []
	for p in [phrase_a, phrase_b, phrase_c, phrase_b]:
		for note in p:
			melody.append([N[note[0]], note[1]])

	# Bass: a I–V–vi–IV walk, repeated to match 64 beats.
	var bass_block := [
		[131.0, 2.0], [131.0, 2.0], [98.0, 2.0], [98.0, 2.0],
		[110.0, 2.0], [110.0, 2.0], [87.0, 2.0], [87.0, 2.0],
	]
	var bass := []
	for r in 4:
		bass.append_array(bass_block)

	var total_beats := 64
	var n := int(RATE * total_beats * beat)
	var buf := PackedFloat32Array()
	buf.resize(n)
	_render_track(buf, melody, beat, "square", 0.26)
	_render_track(buf, bass, beat, "tri", 0.24)
	_add_percussion(buf, beat, total_beats)

	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		bytes.encode_s16(i * 2, int(clamp(buf[i], -1.0, 1.0) * 32767.0))

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = n - 1
	return wav

# Simple drum groove: kick on even beats, a noisy snare on odd beats, and quiet
# hi-hats on every half beat.
func _add_percussion(buf: PackedFloat32Array, beat: float, total_beats: int) -> void:
	var spb := beat * RATE
	for b in total_beats:
		var pos := int(b * spb)
		if b % 2 == 0:
			_add_hit(buf, pos, 0.14, "kick", 0.20)
		else:
			_add_hit(buf, pos, 0.10, "snare", 0.12)
		_add_hit(buf, pos, 0.03, "hat", 0.05)
		_add_hit(buf, pos + int(spb * 0.5), 0.03, "hat", 0.04)

func _add_hit(buf: PackedFloat32Array, start_idx: int, dur: float, kind: String, vol: float) -> void:
	var ns := int(dur * RATE)
	var phase := 0.0
	for i in ns:
		var idx := start_idx + i
		if idx < 0 or idx >= buf.size():
			continue
		var t := float(i) / RATE
		var s := 0.0
		match kind:
			"kick":
				var f := 120.0 * exp(-t * 20.0) + 45.0
				phase += TAU * f / RATE
				s = sin(phase) * exp(-t * 12.0)
			"snare":
				s = (randf() * 2.0 - 1.0) * exp(-t * 28.0)
			_:  # hat
				s = (randf() * 2.0 - 1.0) * exp(-t * 60.0)
		buf[idx] += s * vol

func _render_track(buf: PackedFloat32Array, track: Array, beat: float, type: String, vol: float) -> void:
	var pos := 0
	for note in track:
		var f: float = note[0]
		var dur: float = note[1] * beat
		var ns := int(dur * RATE)
		var phase := 0.0
		for i in ns:
			if pos >= buf.size():
				return
			var t := float(i) / RATE
			phase += TAU * f / RATE
			var env: float = clamp(1.0 - t / dur, 0.0, 1.0)        # gentle decay
			var att: float = clamp(t / 0.008, 0.0, 1.0)            # short attack
			buf[pos] += _wave(type, phase) * env * att * vol
			pos += 1
