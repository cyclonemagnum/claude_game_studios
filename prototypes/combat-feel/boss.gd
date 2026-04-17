# PROTOTYPE - NOT FOR PRODUCTION
extends CharacterBody2D

## Boss with 3 phases, 5 attacks, weighted-random selection, and combo chains.
## Phase 1 (100%-60%): learning — slow, 2 attacks.
## Phase 2 (60%-30%): pressure — faster, 4 attacks.
## Phase 3 (<30%): frenzy — fastest, all attacks + combos.

# --- Tuning constants ---
const MAX_HP: int = 500
const MOVE_SPEED: float = 120.0
const ATTACK_RANGE: float = 140.0
const IDLE_TIME_MIN: float = 0.8
const IDLE_TIME_MAX: float = 1.6

# Phase thresholds (fraction of MAX_HP)
const PHASE2_THRESHOLD: float = 0.6
const PHASE3_THRESHOLD: float = 0.3
const PHASE_TRANSITION_DURATION: float = 1.5

# Combo probability in Phase 3
const COMBO_CHAIN_CHANCE: float = 0.4

# Colors
const COLOR_IDLE: Color = Color(0.85, 0.15, 0.15)
const COLOR_TELEGRAPH: Color = Color(1.0, 0.6, 0.0)
const COLOR_ATTACKING: Color = Color(1.0, 0.0, 0.0)
const COLOR_RECOVERY: Color = Color(0.5, 0.1, 0.1)
const COLOR_PHASE_TRANSITION: Color = Color(1.0, 1.0, 1.0)

const PHASE_COLORS: Array[Color] = [
	Color(0.85, 0.15, 0.15),   # Phase 1 — red
	Color(0.9, 0.4, 0.05),     # Phase 2 — orange
	Color(0.7, 0.0, 0.3),      # Phase 3 — crimson-purple
]

# --- Attack definitions ---
enum AttackType { SLAM, SWEEP, CHARGE, LEAP, COMBO }

const ATTACK_NAMES: Array[String] = [
	"SLAM 重击", "SWEEP 横扫", "CHARGE 冲撞", "LEAP 跳砸", "COMBO 连斩",
]

# Per-phase telegraph speed multiplier (1.0 = base speed)
const PHASE_SPEED: Array[float] = [1.0, 0.7, 0.45]

# Base telegraph times (scaled by PHASE_SPEED)
const BASE_TELEGRAPH: Array[float] = [1.0, 0.8, 0.5, 0.9, 0.35]

# Recovery times per attack — the breakwindow
const RECOVERY_TIMES: Array[float] = [1.2, 0.6, 1.0, 0.8, 1.5]

# Damage per attack
const ATTACK_DAMAGES: Array[int] = [25, 15, 30, 35, 12]
const COMBO_SECOND_HIT_DAMAGE: int = 18

# Attack ranges
const ATTACK_RANGES: Array[float] = [120.0, 180.0, 250.0, 150.0, 130.0]

# Active hitbox windows
const ACTIVE_WINDOWS: Array[float] = [0.15, 0.2, 0.25, 0.15, 0.12]

# LEAP specifics
const LEAP_JUMP_DURATION: float = 0.5
const LEAP_HEIGHT_OFFSET: float = -80.0   # visual only, move Y offset

# CHARGE specifics
const CHARGE_SPEED: float = 450.0

# Attack weights per phase — [SLAM, SWEEP, CHARGE, LEAP, COMBO]
# Zero means unavailable in that phase
const PHASE_WEIGHTS: Array[Array] = [
	[3, 2, 0, 0, 0],   # Phase 1: SLAM + SWEEP only
	[2, 2, 2, 2, 0],   # Phase 2: + CHARGE + LEAP
	[1, 1, 2, 2, 3],   # Phase 3: all + COMBO favored
]

# Weight boost for fast attacks after being parried
const PARRIED_FAST_BOOST: int = 3

# --- Signals ---
signal health_changed(current: int, maximum: int)
signal defeated()
signal attack_telegraphed(attack_name: String)
signal attack_landed(damage: int, position: Vector2)
signal phase_changed(new_phase: int)

# --- State machine ---
enum BossState { IDLE, MOVING, TELEGRAPH, ATTACKING, RECOVERY, PHASE_TRANSITION, LEAP_AIRBORNE, COMBO_GAP, DEAD }
var _state: BossState = BossState.IDLE
var _state_timer: float = 0.0

var _current_attack: AttackType = AttackType.SLAM
var _last_attack: AttackType = AttackType.SLAM
var _hp: int = MAX_HP
var _phase: int = 0   # 0, 1, 2 (maps to Phase 1, 2, 3)

var _attack_hit_this_swing: bool = false
var _charge_velocity: Vector2 = Vector2.ZERO
var _was_parried: bool = false   # set by player via signal, reset after next attack pick

# LEAP state
var _leap_origin: Vector2 = Vector2.ZERO
var _leap_target: Vector2 = Vector2.ZERO
var _leap_elapsed: float = 0.0
var _leap_base_y_offset: float = 0.0

# COMBO state
var _combo_hit_index: int = 0   # 0 = first hit, 1 = second hit

# Phase transition
var _transition_flash_timer: float = 0.0

# References
var _player_ref: CharacterBody2D = null
var _body_rect: ColorRect = null
var _label: Label = null


func _ready() -> void:
	_body_rect = $BodyRect
	_label = $AttackLabel
	_state = BossState.IDLE
	_state_timer = randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX)


func set_player(p: CharacterBody2D) -> void:
	_player_ref = p


func notify_parried() -> void:
	_was_parried = true


# --- Main loop ---
func _physics_process(delta: float) -> void:
	if _state == BossState.DEAD:
		return

	_state_timer -= delta

	match _state:
		BossState.IDLE:
			_tick_idle(delta)
		BossState.MOVING:
			_tick_moving(delta)
		BossState.TELEGRAPH:
			_tick_telegraph(delta)
		BossState.ATTACKING:
			_tick_attacking(delta)
		BossState.RECOVERY:
			_tick_recovery(delta)
		BossState.PHASE_TRANSITION:
			_tick_phase_transition(delta)
		BossState.LEAP_AIRBORNE:
			_tick_leap_airborne(delta)
		BossState.COMBO_GAP:
			_tick_combo_gap(delta)

	# Only apply physics movement for non-leap states
	if _state != BossState.LEAP_AIRBORNE:
		move_and_slide()


# --- State ticks ---

func _tick_idle(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _state_timer <= 0.0:
		_enter_move()


func _tick_moving(delta: float) -> void:
	if _player_ref == null:
		_enter_idle()
		return
	var to_player := _player_ref.global_position - global_position
	var dist := to_player.length()
	if dist > ATTACK_RANGE:
		velocity = to_player.normalized() * MOVE_SPEED * (1.0 + _phase * 0.15)
	else:
		velocity = Vector2.ZERO
		_enter_telegraph()


func _tick_telegraph(_delta: float) -> void:
	velocity = Vector2.ZERO
	var pulse := sin(_state_timer * TAU * 3.0) * 0.5 + 0.5
	if _body_rect:
		_body_rect.color = PHASE_COLORS[_phase].lerp(COLOR_TELEGRAPH, 1.0 - pulse)

	if _state_timer <= 0.0:
		_enter_attack()


func _tick_attacking(delta: float) -> void:
	if _current_attack == AttackType.CHARGE:
		velocity = _charge_velocity
	else:
		velocity = Vector2.ZERO

	if not _attack_hit_this_swing:
		_check_attack_hit()

	if _state_timer <= 0.0:
		# COMBO: after first hit, go to gap then second hit
		if _current_attack == AttackType.COMBO and _combo_hit_index == 0:
			_enter_combo_gap()
			return
		_enter_recovery()


func _tick_recovery(delta: float) -> void:
	velocity = Vector2.ZERO
	# Visual: lerp from dark recovery color back to phase idle color
	if _body_rect and RECOVERY_TIMES[_current_attack] > 0.0:
		var total: float = RECOVERY_TIMES[_current_attack]
		var remaining: float = max(_state_timer, 0.0)
		var t: float = 1.0 - (remaining / total)
		_body_rect.color = COLOR_RECOVERY.lerp(PHASE_COLORS[_phase], t)

	if _state_timer <= 0.0:
		# Phase 3 combo chain chance — immediately attack again
		if _phase == 2 and randf() < COMBO_CHAIN_CHANCE and _current_attack != AttackType.COMBO:
			_enter_telegraph()
			return
		_enter_idle()


func _tick_phase_transition(delta: float) -> void:
	velocity = Vector2.ZERO
	_transition_flash_timer += delta
	# Flash between white and phase color
	if _body_rect:
		var flash := sin(_transition_flash_timer * TAU * 4.0) * 0.5 + 0.5
		_body_rect.color = PHASE_COLORS[_phase].lerp(COLOR_PHASE_TRANSITION, flash)

	if _state_timer <= 0.0:
		if _body_rect:
			_body_rect.color = PHASE_COLORS[_phase]
		if _label:
			_label.text = ""
		_enter_idle()


func _tick_leap_airborne(delta: float) -> void:
	_leap_elapsed += delta
	var t: float = _leap_elapsed / LEAP_JUMP_DURATION

	if t >= 1.0:
		# Land
		global_position = _leap_target
		if _body_rect:
			_body_rect.position.y = 0.0
		# Enter attacking state for the landing hit
		_state = BossState.ATTACKING
		_state_timer = ACTIVE_WINDOWS[AttackType.LEAP]
		_attack_hit_this_swing = false
		if _body_rect:
			_body_rect.color = COLOR_ATTACKING
		return

	# Parabolic arc: horizontal lerp + vertical arc
	global_position = _leap_origin.lerp(_leap_target, t)
	# Visual vertical offset (parabola: -4h*t*(t-1))
	var height: float = LEAP_HEIGHT_OFFSET * (-4.0 * t * (t - 1.0))
	if _body_rect:
		_body_rect.position.y = height


func _tick_combo_gap(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _state_timer <= 0.0:
		# Second hit
		_combo_hit_index = 1
		_state = BossState.ATTACKING
		_state_timer = ACTIVE_WINDOWS[AttackType.COMBO]
		_attack_hit_this_swing = false
		if _body_rect:
			_body_rect.color = COLOR_ATTACKING
		if _label:
			_label.text = "COMBO 连斩 [2]"


# --- State transitions ---

func _enter_idle() -> void:
	_state = BossState.IDLE
	# Phase 3 has shorter idle
	var idle_min: float = IDLE_TIME_MIN * (1.0 - _phase * 0.2)
	var idle_max: float = IDLE_TIME_MAX * (1.0 - _phase * 0.2)
	_state_timer = randf_range(idle_min, idle_max)
	if _body_rect:
		_body_rect.color = PHASE_COLORS[_phase]
	if _label:
		_label.text = ""


func _enter_move() -> void:
	_state = BossState.MOVING


func _enter_telegraph() -> void:
	_state = BossState.TELEGRAPH
	_current_attack = _pick_next_attack()
	_last_attack = _current_attack
	var base_time: float = BASE_TELEGRAPH[_current_attack]
	_state_timer = base_time * PHASE_SPEED[_phase]
	_attack_hit_this_swing = false
	_combo_hit_index = 0

	var aname := ATTACK_NAMES[_current_attack]
	if _label:
		if _current_attack == AttackType.COMBO:
			_label.text = aname + " [1]"
		else:
			_label.text = aname
	attack_telegraphed.emit(aname)


func _enter_attack() -> void:
	_state = BossState.ATTACKING
	_state_timer = ACTIVE_WINDOWS[_current_attack]
	if _body_rect:
		_body_rect.color = COLOR_ATTACKING

	match _current_attack:
		AttackType.CHARGE:
			if _player_ref:
				_charge_velocity = (
					(_player_ref.global_position - global_position).normalized() * CHARGE_SPEED
				)
		AttackType.LEAP:
			_enter_leap()
			return   # leap handles its own state


func _enter_leap() -> void:
	if _player_ref == null:
		_enter_recovery()
		return
	_state = BossState.LEAP_AIRBORNE
	_leap_origin = global_position
	_leap_target = _player_ref.global_position
	_leap_elapsed = 0.0
	if _body_rect:
		_body_rect.color = COLOR_ATTACKING
	if _label:
		_label.text = "LEAP 跳砸 !"


func _enter_recovery() -> void:
	_state = BossState.RECOVERY
	_state_timer = RECOVERY_TIMES[_current_attack]
	if _body_rect:
		_body_rect.color = COLOR_RECOVERY
	if _label:
		_label.text = "◆ 破绽"


func _enter_combo_gap() -> void:
	_state = BossState.COMBO_GAP
	_state_timer = 0.15   # brief gap between combo hits
	if _label:
		_label.text = "COMBO 连斩 ..."


func _enter_phase_transition(new_phase: int) -> void:
	_phase = new_phase
	_state = BossState.PHASE_TRANSITION
	_state_timer = PHASE_TRANSITION_DURATION
	_transition_flash_timer = 0.0
	velocity = Vector2.ZERO

	var phase_names: Array[String] = ["Phase 1 — 学习", "Phase 2 — 狂暴化", "Phase 3 — 极限"]
	if _label:
		_label.text = phase_names[_phase]
	phase_changed.emit(_phase)
	print("BOSS PHASE TRANSITION → %s" % phase_names[_phase])


# --- Attack selection ---

func _pick_next_attack() -> AttackType:
	var weights: Array = PHASE_WEIGHTS[_phase].duplicate()

	# Don't repeat the same attack
	weights[_last_attack] = 0

	# After being parried, boost fast attacks
	if _was_parried:
		if weights[AttackType.CHARGE] > 0:
			weights[AttackType.CHARGE] += PARRIED_FAST_BOOST
		if weights[AttackType.COMBO] > 0:
			weights[AttackType.COMBO] += PARRIED_FAST_BOOST
		_was_parried = false

	# Weighted random selection
	var total: int = 0
	for w: int in weights:
		total += w

	if total == 0:
		# Fallback: reset weights but still exclude last attack
		var fallback_weights: Array = PHASE_WEIGHTS[_phase].duplicate()
		fallback_weights[_last_attack] = 0
		for w: int in fallback_weights:
			total += w
		weights = fallback_weights

	if total == 0:
		return AttackType.SLAM   # absolute fallback

	var roll: int = randi_range(0, total - 1)
	var cumulative: int = 0
	for i: int in range(weights.size()):
		cumulative += weights[i] as int
		if roll < cumulative:
			return i as AttackType
	return AttackType.SLAM


# --- Hit detection ---

func _check_attack_hit() -> void:
	if _player_ref == null:
		return
	var dist := (_player_ref.global_position - global_position).length()
	var attack_range: float = ATTACK_RANGES[_current_attack]
	if dist <= attack_range:
		_attack_hit_this_swing = true
		var dmg: int = ATTACK_DAMAGES[_current_attack]
		# Combo second hit uses different damage
		if _current_attack == AttackType.COMBO and _combo_hit_index == 1:
			dmg = COMBO_SECOND_HIT_DAMAGE
		_player_ref.take_damage(dmg, global_position)
		attack_landed.emit(dmg, _player_ref.global_position)


# --- Damage & phase check ---

func take_damage(amount: int, source_position: Vector2) -> void:
	if _state == BossState.DEAD:
		return
	_hp = max(0, _hp - amount)
	health_changed.emit(_hp, MAX_HP)

	# Flash white on hit
	if _body_rect:
		var tween := create_tween()
		tween.tween_property(_body_rect, "color", Color.WHITE, 0.04)
		tween.tween_property(_body_rect, "color", _get_state_color(), 0.1)

	# Check phase transitions
	_check_phase_transition()

	if _hp <= 0:
		_die()


func _check_phase_transition() -> void:
	var hp_ratio: float = float(_hp) / float(MAX_HP)
	var target_phase: int = 0
	if hp_ratio <= PHASE3_THRESHOLD:
		target_phase = 2
	elif hp_ratio <= PHASE2_THRESHOLD:
		target_phase = 1

	if target_phase > _phase:
		# Interrupt current action for phase transition
		_enter_phase_transition(target_phase)


func _get_state_color() -> Color:
	match _state:
		BossState.TELEGRAPH: return COLOR_TELEGRAPH
		BossState.ATTACKING: return COLOR_ATTACKING
		BossState.RECOVERY: return COLOR_RECOVERY
		BossState.PHASE_TRANSITION: return PHASE_COLORS[_phase]
		_: return PHASE_COLORS[_phase]


func _die() -> void:
	_state = BossState.DEAD
	velocity = Vector2.ZERO
	if _body_rect:
		_body_rect.color = Color(0.3, 0.3, 0.3)
		_body_rect.position.y = 0.0   # reset leap offset
	if _label:
		_label.text = "DEFEATED 讨伐完成"
	defeated.emit()
	print("BOSS DEFEATED!")


# --- Queries ---

func is_in_recovery() -> bool:
	return _state == BossState.RECOVERY


func get_phase() -> int:
	return _phase


func reset() -> void:
	_hp = MAX_HP
	_phase = 0
	_state = BossState.IDLE
	_state_timer = randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX)
	_was_parried = false
	_last_attack = AttackType.SLAM
	if _body_rect:
		_body_rect.color = PHASE_COLORS[0]
		_body_rect.position.y = 0.0
	if _label:
		_label.text = ""
	health_changed.emit(_hp, MAX_HP)
