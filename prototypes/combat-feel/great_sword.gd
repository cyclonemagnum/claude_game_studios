# PROTOTYPE - NOT FOR PRODUCTION
extends Node

## Great Sword weapon component.
## Hold attack to charge (3 levels), release to swing.
## Dodge during charge → Shoulder Tackle: dash forward with super armor,
## small damage, keeps charge level.

# --- Tuning constants ---
const BASE_DAMAGE: int = 30
const CHARGE_TIME_L1: float = 0.0   # instant
const CHARGE_TIME_L2: float = 0.7
const CHARGE_TIME_L3: float = 1.4
const CHARGE_TIME_MAX: float = 2.0

const DAMAGE_MULT: Array[float] = [1.0, 2.0, 3.0]
const RECOVERY_TIME: Array[float] = [0.3, 0.5, 0.8]

const HITBOX_RADIUS: Array[float] = [50.0, 75.0, 100.0]
const HITBOX_ARC_ANGLE: float = PI * 0.75

const SHAKE_INTENSITY: Array[float] = [3.0, 7.0, 14.0]
const SHAKE_DURATION: Array[float] = [0.1, 0.15, 0.2]
const FREEZE_DURATION: Array[float] = [0.05, 0.07, 0.1]

const SWING_DURATION: float = 0.12

# Shoulder Tackle
const TACKLE_DAMAGE: int = 8
const TACKLE_SPEED: float = 550.0
const TACKLE_DURATION: float = 0.2
const TACKLE_RECOVERY: float = 0.15
const TACKLE_HITBOX_RADIUS: float = 60.0

# --- Signals ---
signal attacked(damage: int, position: Vector2, charge_level: int)
signal charge_level_changed(level: int)
signal swing_started(charge_level: int)
signal recovery_ended()
signal shoulder_tackle_hit(damage: int, position: Vector2)

# --- State ---
var _charging: bool = false
var _charge_time: float = 0.0
var _charge_level: int = 0
var _in_recovery: bool = false
var _recovery_timer: float = 0.0
var _swing_active: bool = false
var _swing_timer: float = 0.0

# Shoulder tackle state
var _tackling: bool = false
var _tackle_timer: float = 0.0
var _tackle_dir: Vector2 = Vector2.ZERO
var _tackle_hit_done: bool = false
var _tackle_saved_charge: int = 0
var _tackle_recovery: bool = false
var _tackle_recovery_timer: float = 0.0

# References set by player
var player: CharacterBody2D = null
var camera: Camera2D = null
var hit_effects: Node2D = null


func _physics_process(delta: float) -> void:
	# Tackle
	if _tackling:
		_tackle_timer -= delta
		if player:
			player.velocity = _tackle_dir * TACKLE_SPEED
		if not _tackle_hit_done:
			_check_tackle_hit()
		if _tackle_timer <= 0.0:
			_end_tackle()
		return

	if _tackle_recovery:
		_tackle_recovery_timer -= delta
		if _tackle_recovery_timer <= 0.0:
			_tackle_recovery = false
			# Resume charging at saved level
			if _tackle_saved_charge > 0:
				_charging = true
				_charge_time = _get_min_time_for_level(_tackle_saved_charge)
				_charge_level = _tackle_saved_charge
				charge_level_changed.emit(_charge_level)
				_tackle_saved_charge = 0
		return

	# Normal recovery
	if _in_recovery:
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			_in_recovery = false
			recovery_ended.emit()
		return

	# Swing
	if _swing_active:
		_swing_timer -= delta
		if _swing_timer <= 0.0:
			_swing_active = false
			_start_recovery(_charge_level - 1)
		else:
			_check_hits()
		return

	# Charging
	if _charging:
		_charge_time += delta
		var new_level := _get_charge_level(_charge_time)
		if new_level != _charge_level:
			_charge_level = new_level
			charge_level_changed.emit(_charge_level)


func can_act() -> bool:
	return not _in_recovery and not _swing_active and not _tackling and not _tackle_recovery


func press_attack() -> void:
	if not can_act():
		return
	_charging = true
	_charge_time = 0.0
	_charge_level = 1
	charge_level_changed.emit(1)


func release_attack() -> void:
	if not _charging:
		return
	_charging = false
	var level := _get_charge_level(_charge_time)
	_charge_level = level
	_execute_swing(level)


func _get_charge_level(t: float) -> int:
	if t >= CHARGE_TIME_L3:
		return 3
	elif t >= CHARGE_TIME_L2:
		return 2
	else:
		return 1


func _get_min_time_for_level(level: int) -> float:
	match level:
		3: return CHARGE_TIME_L3
		2: return CHARGE_TIME_L2
		_: return 0.0


func _execute_swing(level: int) -> void:
	_swing_active = true
	_swing_timer = SWING_DURATION
	_charge_level = level
	swing_started.emit(level)
	charge_level_changed.emit(0)


func _check_hits() -> void:
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var origin := player.global_position
	var facing := Vector2.RIGHT.rotated(player.rotation)
	var radius := HITBOX_RADIUS[_charge_level - 1]

	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			var to_body: Vector2 = (body.global_position - origin).normalized()
			var angle: float = facing.angle_to(to_body)
			if abs(angle) <= HITBOX_ARC_ANGLE * 0.5:
				var dmg: int = int(BASE_DAMAGE * DAMAGE_MULT[_charge_level - 1])
				body.take_damage(dmg, origin)
				attacked.emit(dmg, body.global_position, _charge_level)
				_apply_hit_feedback(_charge_level - 1, body.global_position)
				_swing_active = false
				_swing_timer = 0.0
				_start_recovery(_charge_level - 1)
				return


func _start_recovery(level_index: int) -> void:
	_in_recovery = true
	_recovery_timer = RECOVERY_TIME[level_index]


func _apply_hit_feedback(level_index: int, pos: Vector2) -> void:
	if camera:
		camera.shake(SHAKE_INTENSITY[level_index], SHAKE_DURATION[level_index])
		camera.hit_freeze(FREEZE_DURATION[level_index])
	if hit_effects:
		var dmg := int(BASE_DAMAGE * DAMAGE_MULT[level_index])
		hit_effects.spawn_hit(pos, dmg)


# --- Shoulder Tackle ---

func start_shoulder_tackle() -> void:
	if not _charging:
		return
	_tackle_saved_charge = _charge_level
	_charging = false
	_tackling = true
	_tackle_timer = TACKLE_DURATION
	_tackle_hit_done = false
	charge_level_changed.emit(0)

	if player:
		_tackle_dir = Vector2.RIGHT.rotated(player.rotation)
	else:
		_tackle_dir = Vector2.RIGHT

	print("SHOULDER TACKLE: charge level %d preserved" % _tackle_saved_charge)


func _check_tackle_hit() -> void:
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = TACKLE_HITBOX_RADIUS
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			body.take_damage(TACKLE_DAMAGE, player.global_position)
			shoulder_tackle_hit.emit(TACKLE_DAMAGE, body.global_position)
			_tackle_hit_done = true
			if camera:
				camera.shake(3.0, 0.08)
			if hit_effects:
				hit_effects.spawn_hit(body.global_position, TACKLE_DAMAGE)
			return


func _end_tackle() -> void:
	_tackling = false
	if player:
		player.velocity = Vector2.ZERO
	_tackle_recovery = true
	_tackle_recovery_timer = TACKLE_RECOVERY


func is_shoulder_tackling() -> bool:
	return _tackling


# --- Queries ---

func get_charge_level() -> int:
	return _charge_level


func is_charging() -> bool:
	return _charging


func is_in_recovery() -> bool:
	return _in_recovery
