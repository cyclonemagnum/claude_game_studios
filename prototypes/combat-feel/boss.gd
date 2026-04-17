# PROTOTYPE - NOT FOR PRODUCTION
extends CharacterBody2D

## Simple boss with 3 attack patterns and clear visual telegraphs.

const MAX_HP: int = 500
const MOVE_SPEED: float = 120.0
const ATTACK_RANGE: float = 140.0
const IDLE_TIME_MIN: float = 1.0
const IDLE_TIME_MAX: float = 2.0

const COLOR_IDLE: Color = Color(0.85, 0.15, 0.15)
const COLOR_TELEGRAPH: Color = Color(1.0, 0.6, 0.0)
const COLOR_ATTACKING: Color = Color(1.0, 0.0, 0.0)
const COLOR_RECOVERY: Color = Color(0.5, 0.1, 0.1)

# Signals
signal health_changed(current: int, maximum: int)
signal defeated()
signal attack_telegraphed(attack_name: String)
signal attack_landed(damage: int, position: Vector2)

# State machine
enum BossState { IDLE, MOVING, TELEGRAPH, ATTACKING, RECOVERY, DEAD }
var _state: BossState = BossState.IDLE
var _state_timer: float = 0.0

enum AttackType { SLAM, SWEEP, CHARGE }
var _current_attack: AttackType = AttackType.SLAM
var _attack_cycle: int = 0

const ATTACK_NAMES: Array[String] = ["SLAM 重击", "SWEEP 横扫", "CHARGE 冲撞"]
const TELEGRAPH_TIMES: Array[float] = [1.0, 0.7, 0.5]
const RECOVERY_TIMES: Array[float] = [1.0, 0.8, 0.5]
const ATTACK_DAMAGES: Array[int] = [20, 15, 25]
const ATTACK_RANGES: Array[float] = [120.0, 160.0, 200.0]
const ACTIVE_WINDOWS: Array[float] = [0.15, 0.2, 0.25]

var _hp: int = MAX_HP
var _player: Node = null
var _body_rect: ColorRect = null
var _label: Label = null
var _attack_hit_this_swing: bool = false
var _charge_velocity: Vector2 = Vector2.ZERO

# Reference to player's long_sword for iai window notification
var _player_ref: CharacterBody2D = null


func _ready() -> void:
	_body_rect = $BodyRect
	_label = $AttackLabel
	_state = BossState.IDLE
	_state_timer = randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX)


func set_player(p: CharacterBody2D) -> void:
	_player_ref = p


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

	move_and_slide()


func _tick_idle(delta: float) -> void:
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
		velocity = to_player.normalized() * MOVE_SPEED
	else:
		velocity = Vector2.ZERO
		_enter_telegraph()


func _tick_telegraph(delta: float) -> void:
	velocity = Vector2.ZERO
	# Pulse color during telegraph
	var pulse := sin(_state_timer * TAU * 3.0) * 0.5 + 0.5
	if _body_rect:
		_body_rect.color = COLOR_IDLE.lerp(COLOR_TELEGRAPH, 1.0 - pulse)

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
		_enter_recovery()


func _tick_recovery(delta: float) -> void:
	velocity = Vector2.ZERO
	if _state_timer <= 0.0:
		_attack_cycle += 1
		_enter_idle()


func _enter_idle() -> void:
	_state = BossState.IDLE
	_state_timer = randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX)
	if _body_rect:
		_body_rect.color = COLOR_IDLE
	if _label:
		_label.text = ""


func _enter_move() -> void:
	_state = BossState.MOVING


func _enter_telegraph() -> void:
	_state = BossState.TELEGRAPH
	_current_attack = _pick_next_attack()
	_state_timer = TELEGRAPH_TIMES[_current_attack]
	_attack_hit_this_swing = false

	var aname := ATTACK_NAMES[_current_attack]
	if _label:
		_label.text = aname
	attack_telegraphed.emit(aname)
	print("BOSS TELEGRAPH: %s (%.1fs)" % [aname, _state_timer])


func _enter_attack() -> void:
	_state = BossState.ATTACKING
	_state_timer = ACTIVE_WINDOWS[_current_attack]
	if _body_rect:
		_body_rect.color = COLOR_ATTACKING

	if _current_attack == AttackType.CHARGE and _player_ref:
		_charge_velocity = (_player_ref.global_position - global_position).normalized() * 400.0


func _enter_recovery() -> void:
	_state = BossState.RECOVERY
	_state_timer = RECOVERY_TIMES[_current_attack]
	if _body_rect:
		_body_rect.color = COLOR_RECOVERY
	if _label:
		_label.text = "◆ VULNERABLE"


func _pick_next_attack() -> AttackType:
	# Cycle through in order with some randomness
	var options: Array[AttackType] = [AttackType.SLAM, AttackType.SWEEP, AttackType.CHARGE]
	return options[_attack_cycle % 3]


func _check_attack_hit() -> void:
	if _player_ref == null:
		return
	var dist := (_player_ref.global_position - global_position).length()
	var range := ATTACK_RANGES[_current_attack]
	if dist <= range:
		_attack_hit_this_swing = true
		var dmg := ATTACK_DAMAGES[_current_attack]
		# Let player decide if parried
		_player_ref.take_damage(dmg, global_position)
		attack_landed.emit(dmg, _player_ref.global_position)
		print("BOSS HIT PLAYER: %s, %d damage" % [ATTACK_NAMES[_current_attack], dmg])


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

	if _hp <= 0:
		_die()


func _get_state_color() -> Color:
	match _state:
		BossState.TELEGRAPH: return COLOR_TELEGRAPH
		BossState.ATTACKING: return COLOR_ATTACKING
		BossState.RECOVERY: return COLOR_RECOVERY
		_: return COLOR_IDLE


func _die() -> void:
	_state = BossState.DEAD
	velocity = Vector2.ZERO
	if _body_rect:
		_body_rect.color = Color(0.3, 0.3, 0.3)
	if _label:
		_label.text = "DEFEATED"
	defeated.emit()
	print("BOSS DEFEATED!")


func is_in_recovery() -> bool:
	return _state == BossState.RECOVERY


func reset() -> void:
	_hp = MAX_HP
	_state = BossState.IDLE
	_state_timer = randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX)
	_attack_cycle = 0
	if _body_rect:
		_body_rect.color = COLOR_IDLE
	if _label:
		_label.text = ""
	health_changed.emit(_hp, MAX_HP)
