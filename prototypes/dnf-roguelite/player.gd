# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## DNF风格2.5D玩家控制器
## X轴 = 水平移动, Y轴 = Z轴纵深(上下移动在地面), 跳跃 = 视觉跳跃
## 攻击: J普攻连段, K三段斩, L崩山裂地斩, Shift闪避

const MOVE_SPEED: float = 350.0
const Z_MOVE_SPEED: float = 180.0  # Z轴(上下)移动速度较慢
const JUMP_FORCE: float = 600.0
const GRAVITY: float = 1800.0
const MAX_HP: int = 100
var DODGE_SPEED: float = 700.0
const DODGE_DURATION: float = 0.25
const DODGE_COOLDOWN: float = 0.5

# 普攻连段
var COMBO_DAMAGE: Array[int] = [8, 10, 12, 18]
const COMBO_RANGE: float = 80.0
const COMBO_WINDOW: float = 0.5
const COMBO_HIT_DURATION: float = 0.1
const COMBO_RECOVERY: float = 0.15

# 三段斩 (参考DNF三段斩)
var TRIPLE_SLASH_DAMAGE: Array[int] = [15, 20, 30]
var TRIPLE_SLASH_RANGE: float = 120.0
var TRIPLE_SLASH_ADVANCE: float = 150.0  # 每段前进距离
var TRIPLE_SLASH_HIT_DURATION: float = 0.12
var TRIPLE_SLASH_GAP: float = 0.1
var TRIPLE_SLASH_RECOVERY: float = 0.4
var TRIPLE_SLASH_COOLDOWN: float = 3.0

# 崩山裂地斩 (参考狂战士崩山裂地斩) — 跳起来向前下方劈砍,砸地AOE
var CRASH_SLASH_DAMAGE: int = 60
var CRASH_SLASH_RANGE: float = 150.0
var CRASH_SLASH_JUMP_HEIGHT: float = 200.0
var CRASH_SLASH_DURATION: float = 0.6
var CRASH_SLASH_RECOVERY: float = 0.6
var CRASH_SLASH_COOLDOWN: float = 8.0
var CRASH_SLASH_AOE_RADIUS: float = 130.0

# 无敌帧
var iframes_duration: float = 0.15  # 可被肉鸽升级增加
var skill_range_mult: float = 1.0    # 可被肉鸽升级增加

# Signals
signal health_changed(current: int, maximum: int)
signal died()
signal combo_hit(hit_index: int, damage: int)
signal skill_used(skill_name: String)

# 2.5D position
var ground_x: float = 0.0   # 水平位置
var ground_z: float = 0.0   # 纵深位置 (屏幕上下)
var air_height: float = 0.0  # 跳跃高度 (>0 = 空中)
var velocity_x: float = 0.0
var velocity_z: float = 0.0
var velocity_air: float = 0.0
var is_grounded: bool = true
var facing: int = 1  # 1 = right, -1 = left

# State
var _hp: int = MAX_HP
var _invincible: bool = false
var _invincible_timer: float = 0.0

# Dodge
var _dodging: bool = false
var _dodge_timer: float = 0.0
var _dodge_cooldown_timer: float = 0.0
var _dodge_dir: float = 1.0

# Combo
var _combo_index: int = 0
var _combo_timer: float = 0.0
var _attacking: bool = false
var _attack_timer: float = 0.0
var _in_recovery: bool = false
var _recovery_timer: float = 0.0

# Triple Slash state
var _triple_active: bool = false
var _triple_index: int = 0
var _triple_timer: float = 0.0
var _triple_phase: int = 0  # 0=hit, 1=gap
var _triple_cooldown: float = 0.0

# Crash Slash state
var _crash_active: bool = false
var _crash_timer: float = 0.0
var _crash_phase: int = 0  # 0=jump up, 1=slam down, 2=impact
var _crash_cooldown: float = 0.0
var _crash_start_height: float = 0.0

# Visual nodes
var _body: ColorRect = null
var _shadow: ColorRect = null
var _weapon_indicator: ColorRect = null

# Arena bounds
var arena_min_x: float = -600.0
var arena_max_x: float = 600.0
var arena_min_z: float = -100.0
var arena_max_z: float = 100.0


func _ready() -> void:
	_build_visual()
	ground_x = 0.0
	ground_z = 0.0


func _build_visual() -> void:
	# Shadow (on ground)
	_shadow = ColorRect.new()
	_shadow.size = Vector2(40, 14)
	_shadow.position = Vector2(-20, -7)
	_shadow.color = Color(0, 0, 0, 0.3)
	add_child(_shadow)

	# Body
	_body = ColorRect.new()
	_body.size = Vector2(36, 60)
	_body.position = Vector2(-18, -60)
	_body.color = Color(0.2, 0.5, 1.0)
	add_child(_body)

	# Weapon indicator
	_weapon_indicator = ColorRect.new()
	_weapon_indicator.size = Vector2(50, 6)
	_weapon_indicator.position = Vector2(10, -35)
	_weapon_indicator.color = Color(0.8, 0.8, 0.8, 0.0)
	add_child(_weapon_indicator)


func _physics_process(delta: float) -> void:
	_update_cooldowns(delta)
	_update_invincibility(delta)
	_update_dodge(delta)
	_update_triple_slash(delta)
	_update_crash_slash(delta)
	_update_attack(delta)
	_update_recovery(delta)

	if _can_move():
		_handle_movement(delta)
		_handle_jump()

	if _can_act():
		_handle_combat_input()

	_apply_gravity(delta)
	_apply_movement(delta)
	_update_visual()


func _can_move() -> bool:
	return not _attacking and not _triple_active and not _crash_active and not _dodging and not _in_recovery


func _can_act() -> bool:
	return not _attacking and not _triple_active and not _crash_active and not _dodging and not _in_recovery


func _handle_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	var input_z := Input.get_axis("move_up", "move_down")

	velocity_x = input_x * MOVE_SPEED
	velocity_z = input_z * Z_MOVE_SPEED

	if input_x != 0.0:
		facing = 1 if input_x > 0.0 else -1


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_grounded:
		velocity_air = -JUMP_FORCE
		is_grounded = false


func _handle_combat_input() -> void:
	# Dodge
	if Input.is_action_just_pressed("dodge") and _dodge_cooldown_timer <= 0.0:
		_start_dodge()
		return

	# Normal attack combo
	if Input.is_action_just_pressed("attack"):
		_start_attack()
		return

	# Skill 1: 三段斩
	if Input.is_action_just_pressed("skill_1") and _triple_cooldown <= 0.0:
		_start_triple_slash()
		return

	# Skill 2: 崩山裂地斩
	if Input.is_action_just_pressed("skill_2") and _crash_cooldown <= 0.0:
		_start_crash_slash()
		return


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
	elif _triple_active and _triple_phase == 0:
		# Advance during triple slash hits
		ground_x += facing * TRIPLE_SLASH_ADVANCE * delta * 3.0
	elif not _crash_active:
		ground_x += velocity_x * delta
		ground_z += velocity_z * delta

	# Clamp to arena
	ground_x = clampf(ground_x, arena_min_x, arena_max_x)
	ground_z = clampf(ground_z, arena_min_z, arena_max_z)

	# Update node position: X = ground_x, Y = ground_z - air_height
	position.x = ground_x
	position.y = ground_z - air_height


func _update_visual() -> void:
	# Flip body based on facing
	_body.scale.x = facing
	_body.position.x = -18 if facing == 1 else -18

	# Shadow stays on ground (at ground_z, ignoring air_height)
	_shadow.position.y = air_height - 7

	# Body rises with air_height (already handled by position.y)
	# But we need body to stay fixed relative to us, shadow to "drop"

	# Weapon indicator during attacks
	if _attacking or _triple_active:
		_weapon_indicator.color.a = 0.8
		_weapon_indicator.position.x = 10 * facing
		_weapon_indicator.scale.x = facing
	else:
		_weapon_indicator.color.a = 0.0

	# Color based on state
	if _invincible:
		_body.color = Color(1, 1, 1, 0.5)
	elif _crash_active:
		_body.color = Color(1.0, 0.3, 0.1)
	elif _triple_active:
		_body.color = Color(0.8, 0.2, 0.8)
	elif _dodging:
		_body.color = Color(0.8, 0.8, 0.8, 0.4)
	else:
		_body.color = Color(0.2, 0.5, 1.0)

	# Z-sorting
	z_index = int(ground_z)


# --- Dodge ---
func _start_dodge() -> void:
	_dodging = true
	_dodge_timer = DODGE_DURATION
	_dodge_cooldown_timer = DODGE_COOLDOWN
	_invincible = true
	_invincible_timer = iframes_duration
	var input_x := Input.get_axis("move_left", "move_right")
	_dodge_dir = facing if input_x == 0.0 else (1.0 if input_x > 0.0 else -1.0)


func _update_dodge(delta: float) -> void:
	if _dodging:
		_dodge_timer -= delta
		if _dodge_timer <= 0.0:
			_dodging = false


# --- Normal Combo ---
func _start_attack() -> void:
	_attacking = true
	_attack_timer = COMBO_HIT_DURATION
	_combo_timer = COMBO_WINDOW

	# Check hit
	var dmg: int = COMBO_DAMAGE[_combo_index]
	_do_melee_hit(COMBO_RANGE * skill_range_mult, dmg)
	combo_hit.emit(_combo_index, dmg)

	_combo_index = (_combo_index + 1) % COMBO_DAMAGE.size()


func _update_attack(delta: float) -> void:
	if _attacking:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attacking = false
			_in_recovery = true
			_recovery_timer = COMBO_RECOVERY

	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_index = 0


func _update_recovery(delta: float) -> void:
	if _in_recovery:
		_recovery_timer -= delta
		if _recovery_timer <= 0.0:
			_in_recovery = false


# --- 三段斩 (Triple Slash) ---
func _start_triple_slash() -> void:
	_triple_active = true
	_triple_index = 0
	_triple_phase = 0  # hit phase
	_triple_timer = TRIPLE_SLASH_HIT_DURATION
	_triple_cooldown = TRIPLE_SLASH_COOLDOWN
	skill_used.emit("三段斩")

	# First hit
	_do_melee_hit(TRIPLE_SLASH_RANGE * skill_range_mult, TRIPLE_SLASH_DAMAGE[0])


func _update_triple_slash(delta: float) -> void:
	if not _triple_active:
		return

	_triple_timer -= delta
	if _triple_timer <= 0.0:
		if _triple_phase == 0:
			# Hit done → gap
			_triple_phase = 1
			_triple_timer = TRIPLE_SLASH_GAP
		else:
			# Gap done → next hit or finish
			_triple_index += 1
			if _triple_index >= 3:
				# All 3 slashes done
				_triple_active = false
				_in_recovery = true
				_recovery_timer = TRIPLE_SLASH_RECOVERY
				return
			_triple_phase = 0
			_triple_timer = TRIPLE_SLASH_HIT_DURATION
			_do_melee_hit(TRIPLE_SLASH_RANGE * skill_range_mult, TRIPLE_SLASH_DAMAGE[_triple_index])


# --- 崩山裂地斩 (Crash Slash) ---
func _start_crash_slash() -> void:
	_crash_active = true
	_crash_phase = 0  # Jump up
	_crash_timer = CRASH_SLASH_DURATION * 0.4  # 40% of time going up
	_crash_cooldown = CRASH_SLASH_COOLDOWN
	_crash_start_height = air_height
	is_grounded = false
	skill_used.emit("崩山裂地斩")


func _update_crash_slash(delta: float) -> void:
	if not _crash_active:
		return

	_crash_timer -= delta

	match _crash_phase:
		0:  # Jumping up + forward
			air_height = lerpf(_crash_start_height, CRASH_SLASH_JUMP_HEIGHT, 1.0 - (_crash_timer / (CRASH_SLASH_DURATION * 0.4)))
			ground_x += facing * 200.0 * delta  # Move forward while jumping
			if _crash_timer <= 0.0:
				_crash_phase = 1
				_crash_timer = CRASH_SLASH_DURATION * 0.3  # 30% slamming down
		1:  # Slamming down
			var t: float = 1.0 - (_crash_timer / (CRASH_SLASH_DURATION * 0.3))
			air_height = lerpf(CRASH_SLASH_JUMP_HEIGHT, 0.0, t * t)  # Accelerate down
			ground_x += facing * 100.0 * delta
			if _crash_timer <= 0.0 or air_height <= 0.0:
				# IMPACT
				air_height = 0.0
				is_grounded = true
				_crash_phase = 2
				_crash_timer = CRASH_SLASH_DURATION * 0.3  # 30% impact linger
				# AOE damage
				_do_aoe_hit(CRASH_SLASH_AOE_RADIUS * skill_range_mult, CRASH_SLASH_DAMAGE)
		2:  # Impact recovery (still in crash state)
			if _crash_timer <= 0.0:
				_crash_active = false
				_in_recovery = true
				_recovery_timer = CRASH_SLASH_RECOVERY


# --- Hit detection ---
func _do_melee_hit(range: float, damage: int) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue
		var dx: float = enemy.ground_x - ground_x
		var dz: float = enemy.ground_z - ground_z
		# Check if in front and in range
		if facing == 1 and dx < 0:
			continue
		if facing == -1 and dx > 0:
			continue
		var dist: float = sqrt(dx * dx + dz * dz)
		if dist <= range:
			# Check Z-axis proximity (must be close on Z)
			if abs(dz) < 50.0:
				# Check air height difference
				var height_diff: float = abs(enemy.air_height - air_height)
				if height_diff < 60.0:
					enemy.take_damage(damage, ground_x)


func _do_aoe_hit(radius: float, damage: int) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue
		var dx: float = enemy.ground_x - ground_x
		var dz: float = enemy.ground_z - ground_z
		var dist: float = sqrt(dx * dx + dz * dz)
		if dist <= radius:
			enemy.take_damage(damage, ground_x)


# --- Damage ---
func take_damage(amount: int, _source_x: float) -> void:
	if _invincible or _dodging:
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
	if _invincible and not _dodging:
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


# --- Queries ---
func get_hp() -> int:
	return _hp

func get_max_hp() -> int:
	return MAX_HP

func get_triple_cooldown() -> float:
	return _triple_cooldown

func get_crash_cooldown() -> float:
	return _crash_cooldown

func reset_hp() -> void:
	_hp = MAX_HP
	health_changed.emit(_hp, MAX_HP)

func heal(amount: int) -> void:
	_hp = min(MAX_HP, _hp + amount)
	health_changed.emit(_hp, MAX_HP)
