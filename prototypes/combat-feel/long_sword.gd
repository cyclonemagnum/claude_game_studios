# PROTOTYPE - NOT FOR PRODUCTION
extends Node

## Long Sword weapon component.
## Light combo builds spirit gauge.
## L enters 居合構え (Iai Stance):
##   - J in stance → 小居合 (Mini Iai slash, quick, consumes some spirit)
##   - K in stance → cancel into dodge roll
##   - L in stance → 大居合 (Grand Iai): dash forward with i-frames,
##     if hit during dash → delayed counter slash + screen shake,
##     if not hit → punish recovery

# --- Tuning constants ---
const COMBO_DAMAGE: Array[int] = [10, 12, 15]
const COMBO_HIT_DURATION: float = 0.1
const COMBO_RECOVERY: float = 0.25
const COMBO_RESET_TIME: float = 0.6

const SPIRIT_PER_HIT: int = 8
const SPIRIT_DECAY_RATE: float = 5.0
const SPIRIT_MAX: int = 100

const SPIRIT_LEVEL_THRESHOLDS: Array[int] = [0, 34, 67]
const SPIRIT_DAMAGE_BONUS: Array[float] = [0.0, 0.15, 0.30]

const HITBOX_RADIUS: float = 70.0
const HITBOX_ARC: float = PI * 0.8

# --- 居合構え (Iai Stance) ---
const STANCE_DURATION: float = 2.0        # max time in stance before auto-exit
const STANCE_SPIRIT_COST: int = 0          # entering stance is free

# 小居合 (Mini Iai) — quick slash from stance
const MINI_IAI_DAMAGE: int = 25
const MINI_IAI_SPIRIT_COST: int = 15
const MINI_IAI_HITBOX_RADIUS: float = 90.0
const MINI_IAI_RECOVERY: float = 0.3

# 大居合 (Grand Iai) — dash with i-frames + counter
const GRAND_IAI_DASH_SPEED: float = 500.0
const GRAND_IAI_DASH_DURATION: float = 0.25
const GRAND_IAI_COUNTER_DAMAGE: int = 50
const GRAND_IAI_COUNTER_DELAY: float = 0.3    # delay before counter slash lands
const GRAND_IAI_SPIRIT_BONUS: int = 30
const GRAND_IAI_FAIL_RECOVERY: float = 0.7    # punish for whiffed grand iai
const GRAND_IAI_FREEZE_DURATION: float = 0.18
const GRAND_IAI_SHAKE_INTENSITY: float = 12.0
const GRAND_IAI_SHAKE_DURATION: float = 0.25
var grand_iai_window_frames: int = 6           # adjustable at runtime

# Spirit Release (居合斩) — full gauge finisher
const RELEASE_DAMAGE: int = 80
const RELEASE_HITBOX_RADIUS: float = 120.0

# --- Signals ---
signal spirit_changed(value: int)
signal spirit_level_changed(level: int)
signal stance_entered()
signal stance_exited()
signal mini_iai_fired(damage: int, position: Vector2)
signal grand_iai_started()
signal grand_iai_success(frame_hit: int, window: int)
signal grand_iai_failed()
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
var _decay_suppress_timer: float = 0.0

# Iai Stance state
var _in_stance: bool = false
var _stance_timer: float = 0.0

# Grand Iai state
var _grand_iai_dashing: bool = false
var _grand_iai_dash_timer: float = 0.0
var _grand_iai_dash_dir: Vector2 = Vector2.ZERO
var _grand_iai_frame_counter: int = 0
var _grand_iai_hit_absorbed: bool = false   # did we block a hit during dash?
var _grand_iai_attack_origin: Vector2 = Vector2.ZERO
var _grand_iai_in_recovery: bool = false
var _grand_iai_recovery_timer: float = 0.0

# Counter delay state
var _counter_pending: bool = false
var _counter_delay_timer: float = 0.0
var _counter_origin: Vector2 = Vector2.ZERO

# References
var player: CharacterBody2D = null
var camera: Camera2D = null
var hit_effects: Node2D = null


func _physics_process(delta: float) -> void:
	_update_spirit_decay(delta)
	_update_combo_timer(delta)
	_update_hit_window(delta)
	_update_recovery(delta)
	_update_stance(delta)
	_update_grand_iai(delta)
	_update_counter_delay(delta)


func _update_spirit_decay(delta: float) -> void:
	if _decay_suppress_timer > 0.0:
		_decay_suppress_timer -= delta
		return
	if _in_stance:
		return   # no decay during stance
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


func _update_stance(delta: float) -> void:
	if _in_stance and not _grand_iai_dashing:
		_stance_timer -= delta
		if _stance_timer <= 0.0:
			_exit_stance()


func _update_grand_iai(delta: float) -> void:
	if _grand_iai_dashing:
		_grand_iai_dash_timer -= delta
		_grand_iai_frame_counter += 1

		# Apply dash movement via player velocity
		if player:
			player.velocity = _grand_iai_dash_dir * GRAND_IAI_DASH_SPEED

		if _grand_iai_dash_timer <= 0.0:
			# Dash ended
			_grand_iai_dashing = false
			if player:
				player.velocity = Vector2.ZERO

			if _grand_iai_hit_absorbed:
				# Success — schedule delayed counter
				_counter_pending = true
				_counter_delay_timer = GRAND_IAI_COUNTER_DELAY
				_counter_origin = _grand_iai_attack_origin
			else:
				# Failed — punish recovery
				_grand_iai_in_recovery = true
				_grand_iai_recovery_timer = GRAND_IAI_FAIL_RECOVERY
				grand_iai_failed.emit()
				print("大居合 MISSED: no attack absorbed during dash")

			_in_stance = false
			stance_exited.emit()

	if _grand_iai_in_recovery:
		_grand_iai_recovery_timer -= delta
		if _grand_iai_recovery_timer <= 0.0:
			_grand_iai_in_recovery = false


func _update_counter_delay(delta: float) -> void:
	if _counter_pending:
		_counter_delay_timer -= delta
		if _counter_delay_timer <= 0.0:
			_counter_pending = false
			_execute_grand_iai_counter()


# --- Can act ---

func can_act() -> bool:
	return (
		not _in_recovery
		and not _hit_active
		and not _grand_iai_in_recovery
		and not _grand_iai_dashing
		and not _counter_pending
	)


func is_in_stance() -> bool:
	return _in_stance


func is_grand_iai_dashing() -> bool:
	return _grand_iai_dashing


func is_busy() -> bool:
	return not can_act() or _in_stance or _grand_iai_dashing or _counter_pending


# --- Normal combo ---

func press_attack() -> void:
	if _in_stance:
		_execute_mini_iai()
		return
	if not can_act():
		return
	_execute_combo_hit()


func _execute_combo_hit() -> void:
	_hit_active = true
	_hit_timer = COMBO_HIT_DURATION
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

				_combo_index = (_combo_index % 3) + 1
				_spirit = min(SPIRIT_MAX, _spirit + SPIRIT_PER_HIT)
				_update_spirit_level()
				spirit_changed.emit(_spirit)

				if hit_effects:
					hit_effects.spawn_hit(body.global_position, dmg)

				_hit_active = false
				_in_recovery = true
				_recovery_timer = COMBO_RECOVERY
				return


# --- Iai Stance ---

func press_special() -> void:
	if _in_stance:
		# Already in stance — L again triggers Grand Iai
		_execute_grand_iai()
		return

	if not can_act():
		return

	# Full gauge → Spirit Release (居合斩) — bypasses stance
	if _spirit >= SPIRIT_MAX:
		_execute_spirit_release()
		return

	# Enter stance
	_enter_stance()


func _enter_stance() -> void:
	_in_stance = true
	_stance_timer = STANCE_DURATION
	_combo_index = 0
	_combo_timer = 0.0
	stance_entered.emit()
	print("居合構え ENTERED (%.1fs)" % STANCE_DURATION)


func _exit_stance() -> void:
	if not _in_stance:
		return
	_in_stance = false
	stance_exited.emit()
	print("居合構え EXITED")


func request_dodge_cancel() -> bool:
	## Called by player when dodge is pressed during stance.
	## Returns true if stance was active and should cancel into dodge.
	if _in_stance and not _grand_iai_dashing:
		_exit_stance()
		return true
	return false


# --- 小居合 (Mini Iai) ---

func _execute_mini_iai() -> void:
	if not _in_stance or _grand_iai_dashing:
		return
	_in_stance = false
	stance_exited.emit()

	# Costs spirit but still works at 0
	_spirit = max(0, _spirit - MINI_IAI_SPIRIT_COST)
	_update_spirit_level()
	spirit_changed.emit(_spirit)

	# Hitbox check
	if player == null:
		return
	var space := player.get_world_2d().direct_space_state
	var origin := player.global_position
	var facing := Vector2.RIGHT.rotated(player.rotation)

	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = MINI_IAI_HITBOX_RADIUS
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = 4

	var hit_any := false
	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			var to_body: Vector2 = (body.global_position - origin).normalized()
			var angle: float = facing.angle_to(to_body)
			if abs(angle) <= HITBOX_ARC * 0.5:
				var bonus := SPIRIT_DAMAGE_BONUS[_spirit_level]
				var dmg: int = int(MINI_IAI_DAMAGE * (1.0 + bonus))
				body.take_damage(dmg, origin)
				mini_iai_fired.emit(dmg, body.global_position)
				hit_any = true

				if hit_effects:
					hit_effects.spawn_hit(body.global_position, dmg)

				# Spirit gain on hit
				_spirit = min(SPIRIT_MAX, _spirit + SPIRIT_PER_HIT)
				_update_spirit_level()
				spirit_changed.emit(_spirit)

	if hit_any and camera:
		camera.shake(4.0, 0.1)

	_in_recovery = true
	_recovery_timer = MINI_IAI_RECOVERY
	_decay_suppress_timer = 0.8
	print("小居合 FIRED: %d base damage" % MINI_IAI_DAMAGE)


# --- 大居合 (Grand Iai) ---

func _execute_grand_iai() -> void:
	if not _in_stance or _grand_iai_dashing:
		return

	# Start dash in facing direction
	_grand_iai_dashing = true
	_grand_iai_dash_timer = GRAND_IAI_DASH_DURATION
	_grand_iai_frame_counter = 0
	_grand_iai_hit_absorbed = false
	_grand_iai_attack_origin = Vector2.ZERO

	if player:
		_grand_iai_dash_dir = Vector2.RIGHT.rotated(player.rotation)
	else:
		_grand_iai_dash_dir = Vector2.RIGHT

	grand_iai_started.emit()
	print("大居合 DASH STARTED: %d i-frames" % grand_iai_window_frames)


## Called by player when taking damage during grand iai dash.
## Returns true if the attack was absorbed (i-frame parry).
func try_grand_iai_absorb(attack_origin: Vector2) -> bool:
	if not _grand_iai_dashing:
		return false
	if _grand_iai_frame_counter > grand_iai_window_frames:
		return false   # past the i-frame window

	_grand_iai_hit_absorbed = true
	_grand_iai_attack_origin = attack_origin

	grand_iai_success.emit(_grand_iai_frame_counter, grand_iai_window_frames)
	print("大居合 ABSORBED at frame %d, window %d" % [_grand_iai_frame_counter, grand_iai_window_frames])
	return true


func _execute_grand_iai_counter() -> void:
	if player == null:
		return

	# Big counter slash
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = HITBOX_RADIUS * 1.5
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = 4

	var results := space.intersect_shape(query, 8)
	for r in results:
		var body: Node2D = r["collider"] as Node2D
		if body and body.has_method("take_damage"):
			var bonus := SPIRIT_DAMAGE_BONUS[_spirit_level]
			var dmg: int = int(GRAND_IAI_COUNTER_DAMAGE * (1.0 + bonus))
			body.take_damage(dmg, player.global_position)
			combo_hit.emit(-2, dmg, body.global_position)

			if hit_effects:
				hit_effects.spawn_hit(body.global_position, dmg)

	# Spirit bonus
	_spirit = min(SPIRIT_MAX, _spirit + GRAND_IAI_SPIRIT_BONUS)
	_update_spirit_level()
	spirit_changed.emit(_spirit)

	# Feedback
	if camera:
		camera.shake(GRAND_IAI_SHAKE_INTENSITY, GRAND_IAI_SHAKE_DURATION)
		camera.hit_freeze(GRAND_IAI_FREEZE_DURATION)
	if hit_effects:
		hit_effects.spawn_iai_success(player.global_position)

	_decay_suppress_timer = 1.0
	print("大居合 COUNTER: %d base damage" % GRAND_IAI_COUNTER_DAMAGE)


# --- Spirit Release ---

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
	print("居合斩 FIRED: %d damage" % RELEASE_DAMAGE)


# --- Spirit level ---

func _update_spirit_level() -> void:
	var new_level: int = 0
	for i in range(SPIRIT_LEVEL_THRESHOLDS.size() - 1, -1, -1):
		if _spirit >= SPIRIT_LEVEL_THRESHOLDS[i]:
			new_level = i
			break
	if new_level != _spirit_level:
		_spirit_level = new_level
		spirit_level_changed.emit(_spirit_level)


# --- Queries ---

func get_spirit() -> int:
	return _spirit


func get_spirit_level() -> int:
	return _spirit_level


func is_iai_active() -> bool:
	return _in_stance


func get_stance_state() -> String:
	if _grand_iai_dashing:
		return "大居合"
	if _counter_pending:
		return "反击中"
	if _grand_iai_in_recovery:
		return "后摇"
	if _in_stance:
		return "居合構え"
	return "通常"
