# PROTOTYPE - NOT FOR PRODUCTION
extends Node

## Great Sword weapon component.
## Hold attack to charge (3 levels), release to swing.

# --- Tuning constants ---
const BASE_DAMAGE: int = 30
const CHARGE_TIME_L1: float = 0.0   # instant
const CHARGE_TIME_L2: float = 0.7
const CHARGE_TIME_L3: float = 1.4
const CHARGE_TIME_MAX: float = 2.0

const DAMAGE_MULT: Array[float] = [1.0, 2.0, 3.0]   # index = charge level - 1
const RECOVERY_TIME: Array[float] = [0.3, 0.5, 0.8]

const HITBOX_RADIUS: Array[float] = [50.0, 75.0, 100.0]
const HITBOX_ARC_ANGLE: float = PI * 0.75   # ~135 degrees

const SHAKE_INTENSITY: Array[float] = [3.0, 7.0, 14.0]
const SHAKE_DURATION: Array[float] = [0.1, 0.15, 0.2]
const FREEZE_DURATION: Array[float] = [0.05, 0.07, 0.1]

# --- Signals ---
signal attacked(damage: int, position: Vector2, charge_level: int)
signal charge_level_changed(level: int)   # 0 = not charging, 1/2/3
signal swing_started(charge_level: int)
signal recovery_ended()

# --- State ---
var _charging: bool = false
var _charge_time: float = 0.0
var _charge_level: int = 0
var _in_recovery: bool = false
var _recovery_timer: float = 0.0
var _swing_active: bool = false
var _swing_timer: float = 0.0

const SWING_DURATION: float = 0.12   # active hitbox window

# References set by player
var player: CharacterBody2D = null
var camera: Camera2D = null
var hit_effects: Node2D = null


func _physics_process(delta: float) -> void:
	if _in_recovery:
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			_in_recovery = false
			recovery_ended.emit()
		return

	if _swing_active:
		_swing_timer -= delta
		if _swing_timer <= 0.0:
			_swing_active = false
			_start_recovery(_charge_level - 1)
		else:
			_check_hits()
		return

	if _charging:
		_charge_time += delta
		var new_level := _get_charge_level(_charge_time)
		if new_level != _charge_level:
			_charge_level = new_level
			charge_level_changed.emit(_charge_level)


func can_act() -> bool:
	return not _in_recovery and not _swing_active


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

	# Check all bodies in radius
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = 4   # layer 3 = boss

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body = r["collider"]
		if body.has_method("take_damage"):
			# Check arc
			var to_body: Vector2 = (body.global_position - origin).normalized()
			var angle: float = facing.angle_to(to_body)
			if abs(angle) <= HITBOX_ARC_ANGLE * 0.5:
				var dmg: int = int(BASE_DAMAGE * DAMAGE_MULT[_charge_level - 1])
				body.take_damage(dmg, origin)
				attacked.emit(dmg, body.global_position, _charge_level)
				_apply_hit_feedback(_charge_level - 1, body.global_position)
				# Only hit once per swing
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


func get_charge_level() -> int:
	return _charge_level


func is_charging() -> bool:
	return _charging


func is_in_recovery() -> bool:
	return _in_recovery
