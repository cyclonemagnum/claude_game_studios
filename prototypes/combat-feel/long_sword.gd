# PROTOTYPE - NOT FOR PRODUCTION
extends Node

## Long Sword weapon component.
## Light combo builds spirit gauge → Iai-giri parry window → Spirit Release finisher.

# --- Tuning constants ---
const COMBO_DAMAGE: Array[int] = [10, 12, 15]
const COMBO_HIT_DURATION: float = 0.1    # active hitbox window per hit
const COMBO_RECOVERY: float = 0.25       # time between combo hits allowed
const COMBO_RESET_TIME: float = 0.6      # idle time to reset combo

const SPIRIT_PER_HIT: int = 8
const SPIRIT_DECAY_RATE: float = 5.0     # per second when not attacking
const SPIRIT_MAX: int = 100

const SPIRIT_LEVEL_THRESHOLDS: Array[int] = [0, 34, 67]   # white, yellow, red
const SPIRIT_DAMAGE_BONUS: Array[float] = [0.0, 0.15, 0.30]

const HITBOX_RADIUS: float = 70.0
const HITBOX_ARC: float = PI * 0.8

# Iai-giri (見切)
const IAI_COUNTER_DAMAGE: int = 40
const IAI_SPIRIT_BONUS: int = 25
const IAI_FAIL_RECOVERY: float = 0.5
const IAI_FREEZE_DURATION: float = 0.15
var iai_window_frames: int = 6   # adjustable at runtime (4/6/8/10)

# Spirit Release (居合斩)
const RELEASE_DAMAGE: int = 80
const RELEASE_HITBOX_RADIUS: float = 120.0

# --- Signals ---
signal spirit_changed(value: int)
signal spirit_level_changed(level: int)   # 0=white, 1=yellow, 2=red
signal iai_window_opened()
signal iai_success(frame_hit: int, window: int)
signal iai_failed()
signal combo_hit(hit_index: int, damage: int, position: Vector2)
signal spirit_release_fired(damage: int, position: Vector2)

# --- State ---
var _spirit: int = 0
var _spirit_level: int = 0
var _combo_index: int = 0
var _combo_timer: float = 0.0
var _hit_active: bool = false
var _hit_timer: float = 0.0
var _in_recovery: bool = false
var _recovery_timer: float = 0.0
var _decay_suppress_timer: float = 0.0   # suppress decay after a hit

# Iai state
var _iai_active: bool = false
var _iai_frame_counter: int = 0
var _iai_in_recovery: bool = false
var _iai_recovery_timer: float = 0.0

# References
var player: CharacterBody2D = null
var camera: Camera2D = null
var hit_effects: Node2D = null


func _physics_process(delta: float) -> void:
	_update_spirit_decay(delta)
	_update_combo_timer(delta)
	_update_hit_window(delta)
	_update_recovery(delta)
	_update_iai(delta)


func _update_spirit_decay(delta: float) -> void:
	if _decay_suppress_timer > 0.0:
		_decay_suppress_timer -= delta
		return
	if _spirit > 0:
		_spirit = max(0, _spirit - int(SPIRIT_DECAY_RATE * delta + 0.5))
		_update_spirit_level()
		spirit_changed.emit(_spirit)


func _update_combo_timer(delta: float) -> void:
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0 and not _hit_active:
			_combo_index = 0


func _update_hit_window(delta: float) -> void:
	if _hit_active:
		_hit_timer -= delta
		if _hit_timer <= 0.0:
			_hit_active = false
		else:
			_check_combo_hits()


func _update_recovery(delta: float) -> void:
	if _in_recovery:
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			_in_recovery = false


func _update_iai(delta: float) -> void:
	if _iai_active:
		_iai_frame_counter += 1
		if _iai_frame_counter > iai_window_frames:
			# Window expired without parry
			_iai_active = false
			_iai_in_recovery = true
			_iai_recovery_timer = IAI_FAIL_RECOVERY
			iai_failed.emit()
			print("IAI-GIRI MISSED: window expired (%d frames)" % iai_window_frames)

	if _iai_in_recovery:
		_iai_recovery_timer -= delta
		if _iai_recovery_timer <= 0.0:
			_iai_in_recovery = false


func can_act() -> bool:
	return not _in_recovery and not _hit_active and not _iai_in_recovery


func press_attack() -> void:
	if not can_act():
		return
	_execute_combo_hit()


func _execute_combo_hit() -> void:
	_hit_active = true
	_hit_timer = COMBO_HIT_DURATION
	# Start at hit 1 if no combo active, else stay on current
	if _combo_index < 1:
		_combo_index = 1
	_combo_timer = COMBO_RESET_TIME
	_decay_suppress_timer = 0.8


func _check_combo_hits() -> void:
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var origin := player.global_position
	var facing := Vector2.RIGHT.rotated(player.rotation)

	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = HITBOX_RADIUS
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			var to_body: Vector2 = (body.global_position - origin).normalized()
			var angle: float = facing.angle_to(to_body)
			if abs(angle) <= HITBOX_ARC * 0.5:
				var idx: int = clampi(_combo_index - 1, 0, 2)
				var bonus := SPIRIT_DAMAGE_BONUS[_spirit_level]
				var base_dmg: int = COMBO_DAMAGE[idx]
				var dmg: int = int(base_dmg * (1.0 + bonus))
				body.take_damage(dmg, origin)
				combo_hit.emit(idx, dmg, body.global_position)

				# Advance combo for next hit
				_combo_index = (_combo_index % 3) + 1

				# Spirit gain
				_spirit = min(SPIRIT_MAX, _spirit + SPIRIT_PER_HIT)
				_update_spirit_level()
				spirit_changed.emit(_spirit)

				if hit_effects:
					hit_effects.spawn_hit(body.global_position, dmg)

				_hit_active = false
				_in_recovery = true
				_recovery_timer = COMBO_RECOVERY
				return


func press_special() -> void:
	if not can_act():
		return
	# Full gauge → Spirit Release
	if _spirit >= SPIRIT_MAX:
		_execute_spirit_release()
		return
	# Otherwise → Iai-giri attempt
	_start_iai()


func _start_iai() -> void:
	_iai_active = true
	_iai_frame_counter = 0
	iai_window_opened.emit()
	print("IAI-GIRI WINDOW OPENED: %d frames" % iai_window_frames)


## Called by player when a boss attack hits while iai is active.
func try_iai_parry(attack_origin: Vector2) -> bool:
	if not _iai_active:
		return false
	var frame := _iai_frame_counter
	_iai_active = false

	# Success
	_spirit = min(SPIRIT_MAX, _spirit + IAI_SPIRIT_BONUS)
	_update_spirit_level()
	spirit_changed.emit(_spirit)

	# Counter slash
	if player:
		_execute_counter_slash(attack_origin)

	if camera:
		camera.hit_freeze(IAI_FREEZE_DURATION)
	if hit_effects:
		hit_effects.spawn_iai_success(player.global_position if player else attack_origin)

	iai_success.emit(frame, iai_window_frames)
	print("IAI-GIRI SUCCESS at frame %d, window was %d frames" % [frame, iai_window_frames])
	return true


func _execute_counter_slash(origin: Vector2) -> void:
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = HITBOX_RADIUS * 1.2
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			body.take_damage(IAI_COUNTER_DAMAGE, player.global_position)
			combo_hit.emit(-1, IAI_COUNTER_DAMAGE, body.global_position)


func _execute_spirit_release() -> void:
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = RELEASE_HITBOX_RADIUS
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			body.take_damage(RELEASE_DAMAGE, player.global_position)
			spirit_release_fired.emit(RELEASE_DAMAGE, body.global_position)

	if camera:
		camera.shake(10.0, 0.3)
		camera.hit_freeze(0.12)
	if hit_effects:
		hit_effects.spawn_iai_success(player.global_position)

	_spirit = 0
	_update_spirit_level()
	spirit_changed.emit(_spirit)
	print("SPIRIT RELEASE (居合斩) FIRED: %d damage" % RELEASE_DAMAGE)


func _update_spirit_level() -> void:
	var new_level: int = 0
	for i in range(SPIRIT_LEVEL_THRESHOLDS.size() - 1, -1, -1):
		if _spirit >= SPIRIT_LEVEL_THRESHOLDS[i]:
			new_level = i
			break
	if new_level != _spirit_level:
		_spirit_level = new_level
		spirit_level_changed.emit(_spirit_level)


func get_spirit() -> int:
	return _spirit


func get_spirit_level() -> int:
	return _spirit_level


func is_iai_active() -> bool:
	return _iai_active
