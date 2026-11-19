extends Node

# SoundManager for PROJECT PROTO-BREACH / ZOMBIE OUTBREAK
# Full zero-dependency 16-bit procedural WAV synthesizer for:
# - Authentic real weapons (M1911, Remington 870, AK-47, M4A1, Magnum .357)
# - Humanoid zombie vocalizations (groans, alert shrieks, attack bites, headshot splatters)
# - Environmental zombie survival cues (barricade hammering, mystery box, shell tinks, round horn)
# - 2-track adaptive subterranean horror music crossfade

var sound_cache: Dictionary = {}
var ambient_player: AudioStreamPlayer
var combat_player: AudioStreamPlayer
var combat_intensity: float = 0.0
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 24

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _setup_audio_players()
    _generate_procedural_sounds()
    _connect_events()
    _start_adaptive_music()

func _setup_audio_players() -> void:
    ambient_player = AudioStreamPlayer.new()
    ambient_player.bus = "Master"
    ambient_player.volume_db = -6.0
    add_child(ambient_player)
    
    combat_player = AudioStreamPlayer.new()
    combat_player.bus = "Master"
    combat_player.volume_db = -80.0
    add_child(combat_player)
    
    for i in range(POOL_SIZE):
        var p = AudioStreamPlayer.new()
        p.bus = "Master"
        add_child(p)
        sfx_pool.append(p)

func _connect_events() -> void:
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        if eb.has_signal("hit_confirmed"):
            eb.hit_confirmed.connect(_on_hit_confirmed)
        if eb.has_signal("enemy_alerted"):
            eb.enemy_alerted.connect(_on_enemy_alerted)
        if eb.has_signal("player_damaged"):
            eb.player_damaged.connect(_on_player_damaged)

func _process(delta: float) -> void:
    if combat_intensity > 0.0:
        combat_intensity = max(0.0, combat_intensity - delta * 0.15)
    
    var target_combat_db = lerp(-80.0, -3.0, clamp(combat_intensity, 0.0, 1.0))
    var target_ambient_db = lerp(-6.0, -20.0, clamp(combat_intensity, 0.0, 1.0))
    
    combat_player.volume_db = lerp(combat_player.volume_db, target_combat_db, delta * 3.0)
    ambient_player.volume_db = lerp(ambient_player.volume_db, target_ambient_db, delta * 3.0)

func play_sfx(sound_name: String, pitch_range: float = 0.05, volume_db: float = 0.0) -> void:
    if not sound_cache.has(sound_name):
        return
    
    for p in sfx_pool:
        if not p.playing:
            p.stream = sound_cache[sound_name]
            p.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
            p.volume_db = volume_db
            p.play()
            return
            
    var p = sfx_pool[0]
    p.stream = sound_cache[sound_name]
    p.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
    p.volume_db = volume_db
    p.play()

func play_sfx_3d(sound_name: String, global_pos: Vector3, max_distance: float = 35.0, volume_db: float = 0.0) -> void:
    if not sound_cache.has(sound_name):
        return
    var p3d = AudioStreamPlayer3D.new()
    p3d.stream = sound_cache[sound_name]
    p3d.max_distance = max_distance
    p3d.volume_db = volume_db
    p3d.pitch_scale = randf_range(0.92, 1.08)
    p3d.finished.connect(func(): p3d.queue_free())
    get_tree().root.add_child(p3d)
    p3d.global_position = global_pos
    p3d.play()

func _on_hit_confirmed(is_headshot: bool, pos: Vector3) -> void:
    if is_headshot:
        play_sfx("headshot", 0.02, 3.0)
        play_sfx("zombie_headshot_splat", 0.05, 2.0)
    else:
        play_sfx("hit_marker", 0.04, 0.0)

func _on_enemy_alerted(_enemy: Node3D) -> void:
    combat_intensity = 1.0

func _on_player_damaged(_amount: int, _pos: Vector3) -> void:
    play_sfx("player_hurt", 0.08, 2.0)
    play_sfx("zombie_attack", 0.05, 2.0)
    combat_intensity = 1.0

func _start_adaptive_music() -> void:
    if sound_cache.has("music_ambient"):
        ambient_player.stream = sound_cache["music_ambient"]
        ambient_player.play()
    if sound_cache.has("music_combat"):
        combat_player.stream = sound_cache["music_combat"]
        combat_player.play()

# ==============================================================================
# PROCEDURAL SOUND SYNTHESIS
# ==============================================================================

func _generate_procedural_sounds() -> void:
    # 1. Real Firearms
    sound_cache["m1911_fire"] = _synth_gunshot(0.18, 240.0, 50.0, 0.55)
    sound_cache["pistol_fire"] = sound_cache["m1911_fire"]
    sound_cache["shotgun_fire"] = _synth_gunshot(0.42, 110.0, 20.0, 0.95)
    sound_cache["shotgun_pump"] = _synth_mechanical_rack(0.22)
    sound_cache["ak47_fire"] = _synth_gunshot(0.16, 210.0, 40.0, 0.65)
    sound_cache["rifle_fire"] = sound_cache["ak47_fire"]
    sound_cache["m4a1_fire"] = _synth_gunshot(0.13, 310.0, 65.0, 0.45)
    sound_cache["magnum_fire"] = _synth_gunshot(0.48, 160.0, 25.0, 0.85)
    sound_cache["dry_fire"] = _synth_tone(0.03, 1400.0, false)
    sound_cache["shell_tink"] = _synth_tone(0.04, 2800.0, true)
    
    # 2. Reload Handling Sounds
    sound_cache["mag_out"] = _synth_noise_burst(0.09, 0.4)
    sound_cache["mag_in"] = _synth_two_tone(0.08, 440.0, 660.0)
    sound_cache["slide_rack"] = _synth_mechanical_rack(0.18)

    # 3. Zombie NPC Audio
    sound_cache["zombie_groan_1"] = _synth_zombie_groan(1.2, 75.0, 45.0)
    sound_cache["zombie_groan_2"] = _synth_zombie_groan(1.5, 90.0, 50.0)
    sound_cache["zombie_groan_3"] = _synth_zombie_groan(0.9, 65.0, 38.0)
    sound_cache["zombie_shriek"] = _synth_zombie_shriek(0.65)
    sound_cache["zombie_attack"] = _synth_zombie_attack(0.25)
    sound_cache["zombie_headshot_splat"] = _synth_splatter(0.32)
    
    # 4. Player & Survival Audio
    sound_cache["hit_marker"] = _synth_tone(0.05, 980.0, true)
    sound_cache["headshot"] = _synth_two_tone(0.08, 920.0, 1480.0)
    sound_cache["player_hurt"] = _synth_gunshot(0.22, 130.0, 35.0, 0.5)
    sound_cache["pickup"] = _synth_two_tone(0.12, 523.25, 659.25)
    sound_cache["footstep"] = _synth_noise_burst(0.07, 0.25)
    sound_cache["explosion"] = _synth_explosion(0.65)
    
    # 5. Zombie Horde / Game Mode Cues
    sound_cache["barricade_hammer"] = _synth_wood_hammer(0.16)
    sound_cache["barricade_tear"] = _synth_wood_tear(0.3)
    sound_cache["round_start_horn"] = _synth_round_horn(2.2)
    sound_cache["round_end_calm"] = _synth_two_tone(0.8, 440.0, 220.0)
    sound_cache["mystery_box_jingle"] = _synth_box_jingle(1.8)
    sound_cache["perk_drink"] = _synth_two_tone(0.35, 330.0, 880.0)

    # 6. Music Loops
    sound_cache["music_ambient"] = _synth_ambient_loop(4.0)
    sound_cache["music_combat"] = _synth_combat_loop(4.0)

# Synthesizers
func _synth_gunshot(duration: float, start_freq: float, end_freq: float, noise_mix: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var phase: float = 0.0
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 22.0)
        var freq = lerp(start_freq, end_freq, t / duration)
        phase += freq * (2.0 * PI / sample_rate)
        
        var tone = sin(phase)
        var noise = randf_range(-1.0, 1.0)
        var sample_val = (lerp(tone, noise, noise_mix) * env)
        sample_val = clamp(sample_val, -1.0, 1.0)
        data.encode_s16(i * 2, int(sample_val * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_zombie_groan(duration: float, base_freq: float, end_freq: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var phase: float = 0.0
    var gargle_phase: float = 0.0
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = sin(t / duration * PI) # Fade in and out smoothly
        var freq = lerp(base_freq, end_freq, t / duration)
        phase += freq * (2.0 * PI / sample_rate)
        gargle_phase += 18.0 * (2.0 * PI / sample_rate) # Vocal fry modulation
        
        var tone = sin(phase) + 0.3 * sin(phase * 1.5)
        var gargle = (sin(gargle_phase) * 0.5 + 0.5)
        var breath = randf_range(-0.15, 0.15)
        var val = (tone * gargle + breath) * env * 0.75
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_zombie_shriek(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var phase: float = 0.0
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 4.5)
        var freq = lerp(680.0, 320.0, t / duration)
        phase += freq * (2.0 * PI / sample_rate)
        
        var pitch_mod = sin(t * 30.0 * 2.0 * PI) * 0.2
        var tone = sin(phase + pitch_mod)
        var noise = randf_range(-0.4, 0.4)
        var val = (tone * 0.7 + noise) * env * 0.85
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_zombie_attack(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 18.0)
        var snap = sin(t * 180.0 * 2.0 * PI) * 0.6
        var tear = randf_range(-0.6, 0.6) * 0.5
        var val = (snap + tear) * env
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_splatter(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var phase: float = 0.0
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 12.0)
        phase += (140.0 - t * 120.0) * (2.0 * PI / sample_rate)
        var pop = sin(phase) * 0.5
        var squelch = randf_range(-0.8, 0.8) * (sin(t * 40.0) * 0.5 + 0.5)
        var val = (pop + squelch) * env * 0.85
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_mechanical_rack(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var click1 = exp(-t * 60.0) * sin(t * 1200.0 * 2.0 * PI)
        var click2 = exp(-max(0.0, t - duration * 0.5) * 60.0) * sin(t * 900.0 * 2.0 * PI)
        var val = (click1 + click2) * 0.65
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_wood_hammer(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 26.0)
        var thud = sin(t * 120.0 * 2.0 * PI) * 0.7
        var strike = sin(t * 1600.0 * 2.0 * PI) * 0.4 * exp(-t * 90.0)
        var val = (thud + strike) * env
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_wood_tear(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 8.0)
        var crack = randf_range(-0.9, 0.9) * (sin(t * 60.0 * 2.0 * PI) * 0.5 + 0.5)
        var val = crack * env * 0.7
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_round_horn(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = sin(clamp(t / duration * PI, 0.0, PI))
        var f1 = 82.4 # Low E brass
        var f2 = 123.5 # B
        var horn = (sin(t * f1 * 2.0 * PI) * 0.6 + sin(t * f2 * 2.0 * PI) * 0.35)
        var val = horn * env * 0.8
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_box_jingle(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var notes = [440.0, 493.88, 523.25, 587.33, 659.25, 698.46, 783.99, 880.0]
    var note_dur = duration / notes.size()
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var note_idx = int(t / note_dur) % notes.size()
        var note_t = fmod(t, note_dur)
        var env = exp(-note_t * 6.0)
        var val = sin(note_t * notes[note_idx] * 2.0 * PI) * env * 0.55
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
        
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_tone(duration: float, freq: float, decaying: bool) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 30.0) if decaying else 1.0
        var val = sin(t * freq * 2.0 * PI) * env * 0.7
        data.encode_s16(i * 2, int(val * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_two_tone(duration: float, freq1: float, freq2: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    var mid = total_samples / 2
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var freq = freq1 if i < mid else freq2
        var env = exp(-fmod(t, duration * 0.5) * 20.0)
        var val = sin(t * freq * 2.0 * PI) * env * 0.65
        data.encode_s16(i * 2, int(val * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_noise_burst(duration: float, intensity: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 40.0)
        var val = randf_range(-1.0, 1.0) * env * intensity
        data.encode_s16(i * 2, int(val * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_explosion(duration: float) -> AudioStreamWAV:
    var sample_rate = 22050
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var phase: float = 0.0
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var env = exp(-t * 6.0)
        phase += 45.0 * (2.0 * PI / sample_rate)
        var rumble = sin(phase) * 0.6
        var noise = randf_range(-1.0, 1.0) * 0.4
        var val = (rumble + noise) * env
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.data = data
    return wav

func _synth_ambient_loop(duration: float) -> AudioStreamWAV:
    var sample_rate = 11025
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    for i in range(total_samples):
        var t = float(i) / sample_rate
        var sub = sin(t * 45.0 * 2.0 * PI) * 0.4
        var chord = sin(t * 65.4 * 2.0 * PI) * 0.25
        var mod = (sin(t * 0.3 * 2.0 * PI) * 0.5 + 0.5)
        var val = (sub + chord) * mod * 0.45
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
    wav.loop_begin = 0
    wav.loop_end = total_samples
    wav.data = data
    return wav

func _synth_combat_loop(duration: float) -> AudioStreamWAV:
    var sample_rate = 11025
    var total_samples = int(duration * sample_rate)
    var data = PackedByteArray()
    data.resize(total_samples * 2)
    
    var beat_len = sample_rate * (60.0 / 128.0) # 128 BPM
    for i in range(total_samples):
        var beat_pos = fmod(float(i), beat_len) / beat_len
        var kick_env = exp(-beat_pos * 12.0)
        var kick = sin(beat_pos * 80.0 * 2.0 * PI) * kick_env * 0.85
        
        var t = float(i) / sample_rate
        var bass = sin(t * 90.0 * 2.0 * PI) * 0.35
        var val = (kick + bass) * 0.55
        data.encode_s16(i * 2, int(clamp(val, -1.0, 1.0) * 32767.0))
    
    var wav = AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = sample_rate
    wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
    wav.loop_begin = 0
    wav.loop_end = total_samples
    wav.data = data
    return wav
