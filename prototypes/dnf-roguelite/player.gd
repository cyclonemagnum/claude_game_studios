# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## DNF风格2.5D玩家控制器
## 2.5D: X轴水平, Y轴纵深(Z), 跳跃
## 武器系统: 太刀(居合構え) / 大剑(蓄力+肩撞) — Tab切换
## 共通技能: K=三段斩, L=崩山裂地斩 (两把武器都能用)

# --- Movement ---
const MOVE_SPEED: float = 350.0
const Z_MOVE_SPEED: float = 180.0
const JUMP_FORCE: float = 600.0
const GRAVITY: float = 1800.0
const MAX_HP: int = 100
var DODGE_SPEED: float = 700.0
const DODGE_DURATION: float = 0.25
const DODGE_COOLDOWN: float = 0.5

# --- 太刀 (Long Sword) ---
const LS_COMBO_DAMAGE: Array[int] = [10, 12, 15]
const LS_COMBO_RANGE: float = 90.0
const LS_COMBO_RECOVERY: float = 0.2
const LS_SPIRIT_PER_HIT: int = 10
const LS_SPIRIT_MAX: int = 100
const LS_SPIRIT_DECAY: float = 5.0
const LS_STANCE_DURATION: float = 2.0
const LS_MINI_IAI_DAMAGE: int = 25
const LS_MINI_IAI_RANGE: float = 100.0
const LS_GRAND_IAI_DASH_SPEED: float = 600.0
const LS_GRAND_IAI_DURATION: float = 0.25
const LS_GRAND_IAI_COUNTER_DAMAGE: int = 50
const LS_GRAND_IAI_FAIL_RECOVERY: float = 0.6
var ls_grand_iai_window_frames: int = 6

# --- 大剑 (Great Sword) ---
const GS_BASE_DAMAGE: int = 30
const GS_CHARGE_TIME_L2: float = 0.7
const GS_CHARGE_TIME_L3: float = 1.4
const GS_DAMAGE_MULT: Array[float] = [1.0, 2.0, 3.0]
const GS_RANGE: Array[float] = [60.0, 85.0, 110.0]
const GS_RECOVERY: Array[float] = [0.3, 0.5, 0.8]
const GS_TACKLE_DAMAGE: int = 8
const GS_TACKLE_SPEED: float = 550.0
const GS_TACKLE_DURATION: float = 0.2

# --- 三段斩 (Triple Slash) — 共通技能 ---
var TRIPLE_SLASH_DAMAGE: Array[int] = [15, 20, 30]
var TRIPLE_SLASH_RANGE: float = 120.0
var TRIPLE_SLASH_ADVANCE: float = 150.0
const TRIPLE_SLASH_HIT_DURATION: float = 0.12
const TRIPLE_SLASH_GAP: float = 0.1
const TRIPLE_SLASH_RECOVERY: float = 0.4
var TRIPLE_SLASH_COOLDOWN: float = 3.0

# --- 崩山裂地斩 (Crash Slash) — 共通技能 ---
var CRASH_SLASH_DAMAGE: int = 60
const CRASH_SLASH_JUMP_HEIGHT: float = 200.0
const CRASH_SLASH_DURATION: float = 0.6
const CRASH_SLASH_RECOVERY: float = 0.6
var CRASH_SLASH_COOLDOWN: float = 8.0
var CRASH_SLASH_AOE_RADIUS: float = 130.0

# --- Roguelite upgradeable ---
var iframes_duration: float = 0.15
var skill_range_mult: float = 1.0

# --- Signals ---
signal health_changed(current: int, maximum: int)
signal weapon_switched(weapon_name: String)
signal died()
signal combo_hit(hit_index: int, damage: int)
signal skill_used(skill_name: String)
signal spirit_changed(value: int)

# --- 2.5D Position ---
var ground_x: float = 0.0
var ground_z: float = 0.0
var air_height: float = 0.0
var velocity_x: float = 0.0
var velocity_z: float = 0.0
var velocity_air: float = 0.0
var is_grounded: bool = true
var facing: int = 1  # 1=right, -1=left

# --- Core state ---
var _hp: int = MAX_HP
var _invincible: bool = false
var _invincible_timer: float = 0.0
var _weapon_mode: int = 0  # 0=太刀, 1=大剑

# --- Dodge ---
var _dodging: bool = false
var _dodge_timer: float = 0.0
var _dodge_cooldown_timer: float = 0.0
var _dodge_dir: float = 1.0

# --- Generic attack state ---
var _in_recovery: bool = false
var _recovery_timer: float = 0.0

# --- 太刀 state ---
var _ls_combo_index: int = 0
var _ls_combo_timer: float = 0.0
var _ls_attacking: bool = false
var _ls_attack_timer: float = 0.0
var _ls_spirit: int = 0
var _ls_in_stance: bool = false
var _ls_stance_timer: float = 0.0
var _ls_grand_iai_dashing: bool = false
var _ls_grand_iai_timer: float = 0.0
var _ls_grand_iai_frame_counter: int = 0
var _ls_grand_iai_absorbed: bool = false
var _ls_grand_iai_fail_recovery: bool = false
var _ls_grand_iai_recovery_timer: float = 0.0

# --- 大剑 state ---
var _gs_charging: bool = false
var _gs_charge_time: float = 0.0
var _gs_charge_level: int = 0
var _gs_swinging: bool = false
var _gs_swing_timer: float = 0.0
var _gs_tackling: bool = false
var _gs_tackle_timer: float = 0.0
var _gs_tackle_dir: float = 1.0
var _gs_tackle_saved_charge: int = 0

# --- Triple Slash ---
var _triple_active: bool = false
var _triple_index: int = 0
var _triple_timer: float = 0.0
var _triple_phase: int = 0
var _triple_cooldown: float = 0.0

# --- Crash Slash ---
var _crash_active: bool = false
var _crash_timer: float = 0.0
var _crash_phase: int = 0
var _crash_cooldown: float = 0.0

# --- Visual ---
var _body: ColorRect = null
var _shadow: ColorRect = null
var _weapon_rect: ColorRect = null
var _spirit_bar_bg: ColorRect = null
var _spirit_bar: ColorRect = null

# --- Arena ---
var arena_min_x: float = -600.0
var arena_max_x: float = 600.0
var arena_min_z: float = -100.0
var arena_max_z: float = 100.0

# Colors
const COLOR_LONGSWORD: Color = Color(0.2, 0.4, 1.0)
const COLOR_GREATSWORD: Color = Color(1.0, 0.55, 0.1)
const COLOR_STANCE: Color = Color(0.2, 0.2, 0.9)
const COLOR_GRAND_IAI: Color = Color(0.4, 0.8, 1.0)
const COLOR_TRIPLE: Color = Color(0.8, 0.2, 0.8)
const COLOR_CRASH: Color = Color(1.0, 0.2, 0.1)
const COLOR_DODGE: Color = Color(0.8, 0.8, 0.8, 0.4)
const COLOR_TACKLE: Color = Color(1.0, 0.7, 0.2)


func _ready() -> void:
	_build_visual()


func _build_visual() -> void:
	# Shadow
	_shadow = ColorRect.new()
	_shadow.size = Vector2(40, 14)
	_shadow.position = Vector2(-20, -7)
	_shadow.color = Color(0, 0, 0, 0.3)
	add_child(_shadow)

	# Body
	_body = ColorRect.new()
	_body.size = Vector2(36, 60)
	_body.position = Vector2(-18, -60)
	_body.color = COLOR_LONGSWORD
	add_child(_body)

	# Weapon effect rect (shows during attacks)
	_weapon_rect = ColorRect.new()
	_weapon_rect.size = Vector2(60, 8)
	_weapon_rect.position = Vector2(10, -35)
	_weapon_rect.color = Color(1, 1, 1, 0)
	add_child(_weapon_rect)

	# Spirit gauge (太刀 only, small bar above head)
	_spirit_bar_bg = ColorRect.new()
	_spirit_bar_bg.size = Vector2(36, 4)
	_spirit_bar_bg.position = Vector2(-18, -68)
	_spirit_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	add_child(_spirit_bar_bg)

	_spirit_bar = ColorRect.new()
	_spirit_bar.size = Vector2(0, 4)
	_spirit_bar.position = Vector2(-18, -68)
	_spirit_bar.color = Color(1.0, 1.0, 0.3)
	add_child(_spirit_bar)


func _physics_process(delta: float) -> void:
	_update_cooldowns(delta)
	_update_invincibility(delta)
	_update_dodge(delta)
	_update_triple_slash(delta)
	_update_crash_slash(delta)
	_update_longsword(delta)
	_update_greatsword(delta)
	_update_recovery(delta)

	if _can_move():
		_handle_movement(delta)
		_handle_jump()

	_handle_combat_input()
	_apply_gravity(delta)
	_apply_movement(delta)
	_update_visual()


# ===== Movement =====

func _can_move() -> bool:
	return (not _ls_attacking and not _gs_swinging and not _gs_charging
		and not _triple_active and not _crash_active
		and not _dodging and not _in_recovery
		and not _ls_grand_iai_dashing and not _gs_tackling
		and not _ls_grand_iai_fail_recovery)


func _can_act() -> bool:
	return (not _ls_attacking and not _gs_swinging and not _gs_charging
		and not _triple_active and not _crash_active
		and not _dodging and not _in_recovery
		and not _ls_grand_iai_dashing and not _gs_tackling
		and not _ls_grand_iai_fail_recovery and not _ls_in_stance)


func _handle_movement(_delta: float) -> void:
	var input_x: float = Input.get_axis("move_left", "move_right")
	var input_z: float = Input.get_axis("move_up", "move_down")

	# Slower in stance
	var speed_mult: float = 0.4 if _ls_in_stance else 1.0
	velocity_x = input_x * MOVE_SPEED * speed_mult
	velocity_z = input_z * Z_MOVE_SPEED * speed_mult

	if input_x != 0.0:
		facing = 1 if input_x > 0.0 else -1


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_grounded:
		velocity_air = -JUMP_FORCE
		is_grounded = false


func _apply_gravity(delta: float) -> void:
	if not is_grounded:
		velocity_air += GRAVITY * delta
		air_height -= velocity_air * delta
		if air_height <= 0.0:
			air_height = 0.0
			velocity_air = 0.0
			is_grounded = true


func _apply_movement(delta: float) -> void:
	if _dodging:
		ground_x += _dodge_dir * DODGE_SPEED * delta
	elif _gs_tackling:
		ground_x += _gs_tackle_dir * GS_TACKLE_SPEED * delta
	elif _ls_grand_iai_dashing:
		ground_x += facing * LS_GRAND_IAI_DASH_SPEED * delta
	elif _triple_active and _triple_phase == 0:
		ground_x += facing * TRIPLE_SLASH_ADVANCE * 3.0 * delta
	elif _crash_active:
		if _crash_phase <= 1:
			ground_x += facing * 200.0 * delta
	else:
		ground_x += velocity_x * delta
		ground_z += velocity_z * delta

	ground_x = clampf(ground_x, arena_min_x, arena_max_x)
	ground_z = clampf(ground_z, arena_min_z, arena_max_z)
	position.x = ground_x
	position.y = ground_z - air_height


# ===== Combat Input =====

func _handle_combat_input() -> void:
	# Weapon switch
	if Input.is_action_just_pressed("switch_weapon") and _can_act():
		_weapon_mode = 1 - _weapon_mode
		var wname: String = "太刀" if _weapon_mode == 0 else "大剑"
		weapon_switched.emit(wname)
		_gs_charging = false
		_gs_charge_time = 0.0

	# Dodge — also handles 太刀stance cancel and 大剑shoulder tackle
	if Input.is_action_just_pressed("dodge") and _dodge_cooldown_timer <= 0.0:
		if _ls_in_stance and _weapon_mode == 0:
			# Stance dodge cancel
			_ls_in_stance = false
			_start_dodge()
			return
		if _gs_charging and _weapon_mode == 1:
			# Shoulder tackle
			_start_gs_tackle()
			return
		if _can_act() or _can_move():
			_start_dodge()
			return

	# Skill 1: 三段斩 (K) — works with both weapons
	if Input.is_action_just_pressed("skill_1") and _triple_cooldown <= 0.0:
		if _can_act() or _ls_in_stance:
			_ls_in_stance = false
			_start_triple_slash()
			return

	# Skill 2: L键 — 太刀:居合系统 / 大剑:崩山裂地斩
	if Input.is_action_just_pressed("skill_2"):
		if _weapon_mode == 0:
			# 太刀: stance中 → 大居合, 否则 → 进入居合構え
			if _ls_in_stance:
				_start_grand_iai()
				return
			elif _can_act() and _ls_spirit >= 30:
				_enter_ls_stance()
				return
		elif _weapon_mode == 1:
			# 大剑: 崩山裂地斩
			if _can_act() and _crash_cooldown <= 0.0:
				_start_crash_slash()
				return

	# Attack (J)
	if Input.is_action_just_pressed("attack"):
		if _weapon_mode == 0:
			_handle_longsword_attack()
		elif _weapon_mode == 1:
			_handle_greatsword_attack_press()

	# Great sword release
	if Input.is_action_just_released("attack") and _weapon_mode == 1:
		_handle_greatsword_attack_release()


# ===== Dodge =====

func _start_dodge() -> void:
	_dodging = true
	_dodge_timer = DODGE_DURATION
	_dodge_cooldown_timer = DODGE_COOLDOWN
	_invincible = true
	_invincible_timer = iframes_duration
	var input_x: float = Input.get_axis("move_left", "move_right")
	_dodge_dir = facing if input_x == 0.0 else (1.0 if input_x > 0.0 else -1.0)


func _update_dodge(delta: float) -> void:
	if _dodging:
		_dodge_timer -= delta
		if _dodge_timer <= 0.0:
			_dodging = false


# ===== 太刀 (Long Sword) =====

func _handle_longsword_attack() -> void:
	if _ls_in_stance:
		# Stance + J = 小居合
		_execute_mini_iai()
		return
	if not _can_act() and not (_ls_combo_timer > 0.0 and not _ls_attacking):
		return
	if _in_recovery:
		return

	_ls_attacking = true
	_ls_attack_timer = 0.1
	_ls_combo_timer = 0.5

	var dmg: int = LS_COMBO_DAMAGE[_ls_combo_index]
	_do_melee_hit(LS_COMBO_RANGE * skill_range_mult, dmg)
	combo_hit.emit(_ls_combo_index, dmg)

	# Spirit gain
	_ls_spirit = min(LS_SPIRIT_MAX, _ls_spirit + LS_SPIRIT_PER_HIT)
	spirit_changed.emit(_ls_spirit)

	_ls_combo_index = (_ls_combo_index + 1) % LS_COMBO_DAMAGE.size()


func _enter_ls_stance() -> void:
	_ls_in_stance = true
	_ls_stance_timer = LS_STANCE_DURATION
	skill_used.emit("居合構え")


func _execute_mini_iai() -> void:
	_ls_in_stance = false
	_ls_attacking = true
	_ls_attack_timer = 0.12
	var dmg: int = LS_MINI_IAI_DAMAGE
	_do_melee_hit(LS_MINI_IAI_RANGE * skill_range_mult, dmg)
	combo_hit.emit(-1, dmg)
	_ls_spirit = max(0, _ls_spirit - 15)
	spirit_changed.emit(_ls_spirit)
	skill_used.emit("小居合")


func _start_grand_iai() -> void:
	_ls_in_stance = false
	_ls_grand_iai_dashing = true
	_ls_grand_iai_timer = LS_GRAND_IAI_DURATION
	_ls_grand_iai_frame_counter = 0
	_ls_grand_iai_absorbed = false
	_invincible = true
	_invincible_timer = LS_GRAND_IAI_DURATION
	skill_used.emit("大居合")


func _update_longsword(delta: float) -> void:
	# Combo timer
	if _ls_combo_timer > 0.0:
		_ls_combo_timer -= delta
		if _ls_combo_timer <= 0.0:
			_ls_combo_index = 0

	# Attack duration
	if _ls_attacking:
		_ls_attack_timer -= delta
		if _ls_attack_timer <= 0.0:
			_ls_attacking = false
			_in_recovery = true
			_recovery_timer = LS_COMBO_RECOVERY

	# Stance timeout
	if _ls_in_stance:
		_ls_stance_timer -= delta
		if _ls_stance_timer <= 0.0:
			_ls_in_stance = false

	# Grand Iai dash
	if _ls_grand_iai_dashing:
		_ls_grand_iai_timer -= delta
		_ls_grand_iai_frame_counter += 1
		if _ls_grand_iai_timer <= 0.0:
			_ls_grand_iai_dashing = false
			_invincible = false
			if _ls_grand_iai_absorbed:
				# Counter hit!
				_do_melee_hit(LS_MINI_IAI_RANGE * 1.5 * skill_range_mult, LS_GRAND_IAI_COUNTER_DAMAGE)
				combo_hit.emit(-2, LS_GRAND_IAI_COUNTER_DAMAGE)
				_ls_spirit = min(LS_SPIRIT_MAX, _ls_spirit + 30)
				spirit_changed.emit(_ls_spirit)
				skill_used.emit("大居合·成功!")
			else:
				# Failed — punish
				_ls_grand_iai_fail_recovery = true
				_ls_grand_iai_recovery_timer = LS_GRAND_IAI_FAIL_RECOVERY

	# Grand Iai fail recovery
	if _ls_grand_iai_fail_recovery:
		_ls_grand_iai_recovery_timer -= delta
		if _ls_grand_iai_recovery_timer <= 0.0:
			_ls_grand_iai_fail_recovery = false

	# Spirit decay
	if not _ls_in_stance and not _ls_attacking and _ls_spirit > 0:
		_ls_spirit = max(0, _ls_spirit - int(LS_SPIRIT_DECAY * delta + 0.5))
		spirit_changed.emit(_ls_spirit)


func try_grand_iai_absorb(source_x: float) -> bool:
	if not _ls_grand_iai_dashing:
		return false
	if _ls_grand_iai_frame_counter > ls_grand_iai_window_frames:
		return false
	_ls_grand_iai_absorbed = true
	return true


# ===== 大剑 (Great Sword) =====

func _handle_greatsword_attack_press() -> void:
	if not _can_act():
		return
	_gs_charging = true
	_gs_charge_time = 0.0
	_gs_charge_level = 1


func _handle_greatsword_attack_release() -> void:
	if not _gs_charging:
		return
	_gs_charging = false
	var level: int = _get_gs_charge_level()
	_gs_charge_level = level
	_gs_swinging = true
	_gs_swing_timer = 0.12

	var dmg: int = int(GS_BASE_DAMAGE * GS_DAMAGE_MULT[level - 1])
	_do_melee_hit(GS_RANGE[level - 1] * skill_range_mult, dmg)
	combo_hit.emit(level + 10, dmg)  # 10+ = greatsword
	skill_used.emit("大剑Lv%d" % level)


func _start_gs_tackle() -> void:
	_gs_tackle_saved_charge = _gs_charge_level
	_gs_charging = false
	_gs_tackling = true
	_gs_tackle_timer = GS_TACKLE_DURATION
	_gs_tackle_dir = facing
	_invincible = true  # Super armor (reduced damage handled in take_damage)
	_invincible_timer = GS_TACKLE_DURATION
	skill_used.emit("肩撞")


func _update_greatsword(delta: float) -> void:
	# Charging
	if _gs_charging:
		_gs_charge_time += delta
		_gs_charge_level = _get_gs_charge_level()

	# Swinging
	if _gs_swinging:
		_gs_swing_timer -= delta
		if _gs_swing_timer <= 0.0:
			_gs_swinging = false
			_in_recovery = true
			_recovery_timer = GS_RECOVERY[_gs_charge_level - 1]

	# Tackling
	if _gs_tackling:
		_gs_tackle_timer -= delta
		# Try to hit during tackle
		_do_melee_hit(70.0, GS_TACKLE_DAMAGE)
		if _gs_tackle_timer <= 0.0:
			_gs_tackling = false
			_invincible = false
			# Resume charge
			_gs_charging = true
			_gs_charge_time = _get_gs_time_for_level(_gs_tackle_saved_charge)
			_gs_charge_level = _gs_tackle_saved_charge


func _get_gs_charge_level() -> int:
	if _gs_charge_time >= GS_CHARGE_TIME_L3:
		return 3
	elif _gs_charge_time >= GS_CHARGE_TIME_L2:
		return 2
	return 1


func _get_gs_time_for_level(level: int) -> float:
	match level:
		3: return GS_CHARGE_TIME_L3
		2: return GS_CHARGE_TIME_L2
		_: return 0.0


# ===== 三段斩 (Triple Slash) — 共通技能 =====

func _start_triple_slash() -> void:
	_triple_active = true
	_triple_index = 0
	_triple_phase = 0
	_triple_timer = TRIPLE_SLASH_HIT_DURATION
	_triple_cooldown = TRIPLE_SLASH_COOLDOWN
	skill_used.emit("三段斩")
	_do_melee_hit(TRIPLE_SLASH_RANGE * skill_range_mult, TRIPLE_SLASH_DAMAGE[0])


func _update_triple_slash(delta: float) -> void:
	if not _triple_active:
		return
	_triple_timer -= delta
	if _triple_timer <= 0.0:
		if _triple_phase == 0:
			_triple_phase = 1
			_triple_timer = TRIPLE_SLASH_GAP
		else:
			_triple_index += 1
			if _triple_index >= 3:
				_triple_active = false
				_in_recovery = true
				_recovery_timer = TRIPLE_SLASH_RECOVERY
				return
			_triple_phase = 0
			_triple_timer = TRIPLE_SLASH_HIT_DURATION
			_do_melee_hit(TRIPLE_SLASH_RANGE * skill_range_mult, TRIPLE_SLASH_DAMAGE[_triple_index])


# ===== 崩山裂地斩 (Crash Slash) — 共通技能 =====

func _start_crash_slash() -> void:
	_crash_active = true
	_crash_phase = 0
	_crash_timer = CRASH_SLASH_DURATION * 0.4
	_crash_cooldown = CRASH_SLASH_COOLDOWN
	is_grounded = false
	skill_used.emit("崩山裂地斩")


func _update_crash_slash(delta: float) -> void:
	if not _crash_active:
		return
	_crash_timer -= delta

	match _crash_phase:
		0:  # Jump up
			var t: float = 1.0 - (_crash_timer / (CRASH_SLASH_DURATION * 0.4))
			air_height = lerpf(0.0, CRASH_SLASH_JUMP_HEIGHT, t)
			if _crash_timer <= 0.0:
				_crash_phase = 1
				_crash_timer = CRASH_SLASH_DURATION * 0.3
		1:  # Slam down
			var t: float = 1.0 - (_crash_timer / (CRASH_SLASH_DURATION * 0.3))
			air_height = lerpf(CRASH_SLASH_JUMP_HEIGHT, 0.0, t * t)
			if _crash_timer <= 0.0 or air_height <= 0.0:
				air_height = 0.0
				is_grounded = true
				_crash_phase = 2
				_crash_timer = CRASH_SLASH_DURATION * 0.3
				_do_aoe_hit(CRASH_SLASH_AOE_RADIUS * skill_range_mult, CRASH_SLASH_DAMAGE)
		2:  # Linger
			if _crash_timer <= 0.0:
				_crash_active = false
				_in_recovery = true
				_recovery_timer = CRASH_SLASH_RECOVERY


# ===== Hit detection =====

func _do_melee_hit(hit_range: float, damage: int) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue
		var dx: float = enemy.ground_x - ground_x
		var dz: float = enemy.ground_z - ground_z
		# Must be in front
		if facing == 1 and dx < -20:
			continue
		if facing == -1 and dx > 20:
			continue
		var dist: float = sqrt(dx * dx + dz * dz)
		if dist <= hit_range and abs(dz) < 50.0:
			var height_diff: float = abs(enemy.air_height - air_height)
			if height_diff < 60.0:
				enemy.take_damage(damage, ground_x)


func _do_aoe_hit(radius: float, damage: int) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue
		var dx: float = enemy.ground_x - ground_x
		var dz: float = enemy.ground_z - ground_z
		var dist: float = sqrt(dx * dx + dz * dz)
		if dist <= radius:
			enemy.take_damage(damage, ground_x)


# ===== Damage =====

func take_damage(amount: int, source_x: float) -> void:
	if _invincible or _dodging:
		return
	# Grand Iai absorb check
	if _ls_grand_iai_dashing:
		if try_grand_iai_absorb(source_x):
			return
	# Tackle super armor — half damage, no interrupt
	if _gs_tackling:
		var reduced: int = max(1, amount / 2)
		_hp = max(0, _hp - reduced)
		health_changed.emit(_hp, MAX_HP)
		if _hp <= 0:
			died.emit()
		return

	_hp = max(0, _hp - amount)
	health_changed.emit(_hp, MAX_HP)
	_start_iframes()
	if _hp <= 0:
		died.emit()


func _start_iframes() -> void:
	_invincible = true
	_invincible_timer = iframes_duration


func _update_invincibility(delta: float) -> void:
	if _invincible and not _dodging and not _ls_grand_iai_dashing and not _gs_tackling:
		_invincible_timer -= delta
		if _invincible_timer <= 0.0:
			_invincible = false


func _update_cooldowns(delta: float) -> void:
	if _dodge_cooldown_timer > 0.0:
		_dodge_cooldown_timer -= delta
	if _triple_cooldown > 0.0:
		_triple_cooldown -= delta
	if _crash_cooldown > 0.0:
		_crash_cooldown -= delta


func _update_recovery(delta: float) -> void:
	if _in_recovery:
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			_in_recovery = false


# ===== Visual =====

func _update_visual() -> void:
	# Body color
	if _invincible and _dodging:
		_body.color = COLOR_DODGE
	elif _crash_active:
		_body.color = COLOR_CRASH
	elif _triple_active:
		_body.color = COLOR_TRIPLE
	elif _ls_grand_iai_dashing:
		_body.color = COLOR_GRAND_IAI
	elif _ls_in_stance:
		var pulse: float = sin(Engine.get_physics_frames() * 0.2) * 0.3 + 0.7
		_body.color = COLOR_STANCE * pulse + COLOR_LONGSWORD * (1.0 - pulse)
	elif _gs_tackling:
		_body.color = COLOR_TACKLE
	elif _gs_charging:
		var charge_color: Color = COLOR_GREATSWORD.lerp(Color.WHITE, float(_gs_charge_level) / 3.0)
		_body.color = charge_color
	elif _weapon_mode == 0:
		_body.color = COLOR_LONGSWORD
	else:
		_body.color = COLOR_GREATSWORD

	# Shadow on ground
	_shadow.position.y = air_height - 7

	# Spirit bar (太刀)
	_spirit_bar_bg.visible = (_weapon_mode == 0)
	_spirit_bar.visible = (_weapon_mode == 0)
	if _weapon_mode == 0:
		_spirit_bar.size.x = 36.0 * float(_ls_spirit) / float(LS_SPIRIT_MAX)
		if _ls_spirit >= LS_SPIRIT_MAX:
			_spirit_bar.color = Color(1.0, 0.3, 0.2)
		elif _ls_spirit >= 67:
			_spirit_bar.color = Color(1.0, 1.0, 0.3)
		else:
			_spirit_bar.color = Color(1.0, 1.0, 0.8)

	# Z-sorting
	z_index = int(ground_z)


# ===== Queries =====

func get_hp() -> int:
	return _hp

func get_max_hp() -> int:
	return MAX_HP

func get_triple_cooldown() -> float:
	return _triple_cooldown

func get_crash_cooldown() -> float:
	return _crash_cooldown

func get_weapon_mode() -> int:
	return _weapon_mode

func get_spirit() -> int:
	return _ls_spirit

func is_charging_gs() -> bool:
	return _gs_charging

func get_gs_charge_level() -> int:
	return _gs_charge_level

func reset_hp() -> void:
	_hp = MAX_HP
	health_changed.emit(_hp, MAX_HP)

func heal(amount: int) -> void:
	_hp = min(MAX_HP, _hp + amount)
	health_changed.emit(_hp, MAX_HP)
