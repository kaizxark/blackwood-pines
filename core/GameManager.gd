extends Node

# GameManager for PROJECT PROTO-BREACH / ZOMBIE OUTBREAK
# Controls game state, mouse capture, zombie round survival progression, and points economy.

enum GameState {
    TITLE,
    PLAYING,
    PAUSED,
    GAME_OVER,
    VICTORY
}

var current_state: GameState = GameState.PLAYING

# Survival Economy & Stats
var points: int = 500
var current_round: int = 1
var zombies_killed: int = 0
var headshot_kills: int = 0
var total_shots_fired: int = 0
var total_shots_hit: int = 0
var elapsed_time: float = 0.0

# Perks active on player
var active_perks: Dictionary = {
    "juggernog": false,
    "speed_cola": false
}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _connect_events()
    set_mouse_captured(true)

func _process(delta: float) -> void:
    if current_state == GameState.PLAYING:
        elapsed_time += delta

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        toggle_pause()

func _connect_events() -> void:
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        if eb.has_signal("enemy_killed"):
            eb.enemy_killed.connect(_on_enemy_killed)
        if eb.has_signal("weapon_fired"):
            eb.weapon_fired.connect(_on_weapon_fired)
        if eb.has_signal("hit_confirmed"):
            eb.hit_confirmed.connect(_on_hit_confirmed)
        if eb.has_signal("player_died"):
            eb.player_died.connect(_on_player_died)
        if eb.has_signal("level_completed"):
            eb.level_completed.connect(_on_level_completed)
        if eb.has_signal("barricade_plank_restored"):
            eb.barricade_plank_restored.connect(func(_w, _c): add_points(10))

func set_mouse_captured(captured: bool) -> void:
    if captured:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    else:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_pause() -> void:
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
        set_mouse_captured(false)
    elif current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
        set_mouse_captured(true)

func restart_current_level() -> void:
    get_tree().paused = false
    points = 500
    current_round = 1
    zombies_killed = 0
    headshot_kills = 0
    total_shots_fired = 0
    total_shots_hit = 0
    elapsed_time = 0.0
    active_perks = {"juggernog": false, "speed_cola": false}
    current_state = GameState.PLAYING
    set_mouse_captured(true)
    get_tree().reload_current_scene()

func add_points(amount: int) -> void:
    points += amount
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.points_changed.emit(points, amount)

func spend_points(amount: int) -> bool:
    if points >= amount:
        points -= amount
        var eb = get_node_or_null("/root/EventBus")
        if eb:
            eb.points_changed.emit(points, -amount)
        var sm = get_node_or_null("/root/SoundManager")
        if sm:
            sm.play_sfx("pickup", 0.04, 1.0)
        return true
    else:
        var sm = get_node_or_null("/root/SoundManager")
        if sm:
            sm.play_sfx("dry_fire", 0.05, -2.0)
        return false

func has_perk(perk_name: String) -> bool:
    return active_perks.get(perk_name.to_lower(), false)

func grant_perk(perk_name: String) -> void:
    active_perks[perk_name.to_lower()] = true
    var eb = get_node_or_null("/root/EventBus")
    if eb:
        eb.perk_acquired.emit(perk_name)
    var sm = get_node_or_null("/root/SoundManager")
    if sm:
        sm.play_sfx("perk_drink", 0.05, 2.0)

func get_accuracy() -> float:
    if total_shots_fired == 0:
        return 0.0
    return (float(total_shots_hit) / float(total_shots_fired)) * 100.0

func _on_enemy_killed(enemy_type: String, score_val: int) -> void:
    zombies_killed += 1
    # Check if headshot
    if score_val >= 100:
        headshot_kills += 1
        add_points(100)
    else:
        add_points(score_val if score_val > 0 else 60)

func _on_weapon_fired(_weapon_name: String, _ammo: int, _max_ammo: int) -> void:
    total_shots_fired += 1

func _on_hit_confirmed(is_headshot: bool, _pos: Vector3) -> void:
    total_shots_hit += 1
    add_points(10) # 10 points per bullet hit

func _on_player_died() -> void:
    current_state = GameState.GAME_OVER
    set_mouse_captured(false)

func _on_level_completed() -> void:
    current_state = GameState.VICTORY
    set_mouse_captured(false)

## Central state management for player score, survival rounds, and perk buffs

# Points economy: 100 pts per kill, 10 pts per barricade plank, 250 pts ammo refill

# Perk tracking: Juggernog sets max health to 250 with persistent flag state

# Autoload verification: initialized prior to level scene instantiation
