# PROTOTYPE - NOT FOR PRODUCTION
extends CharacterBody2D

## Player controller — movement, dodge, weapon switching.
## Long Sword: combo → 居合構え → 小居合/大居合/dodge cancel
## Great Sword: hold charge → release swing, shoulder tackle during charge

const MOVE_SPEED: float = 300.0
const DODGE_SPEED: float = 600.0
const DODGE_DURATION: float = 0.3
const DODGE_COOLDOWN: float = 0.6
const MAX_HP: int = 100

const COLOR_LONG_SWORD: Color = Color(0.3, 0.5, 1.0)
const COLOR_GREAT_SWORD: Color = Color(1.0, 0.55, 0.1)
const COLOR_DODGE: Color = Color(0.8, 0.8, 0.8, 0.4)
const COLOR_FULL_CHARGE: Color = Color.WHITE
const COLOR_STANCE: Color = Color(0.2, 0.3, 0.9, 0.9)
const COLOR_GRAND_IAI: Color = Color(0.5, 0.8, 1.0)
const COLOR_SHOULDER: Color = Color(1.0, 0.7, 0.2)

# Signals
signal health_changed(current: int, maximum: int)
signal weapon_switched(weapon_name: String)
signal died()

# State
var _hp: int = MAX_HP
var _weapon_mode: int = 0   # 0 = long sword, 1 = great sword
var _dodging: bool = false
var _dodge_timer: float = 0.0
var _dodge_cooldown_timer: float = 0.0
var _dodge_direction: Vector2 = Vector2.ZERO
var _invincible: bool = false
var _facing: Vector2 = Vector2.RIGHT

# Weapon components
var _great_sword: Node = null
var _long_sword: Node = null

# Camera + effects refs
var camera: Camera2D = null
var hit_effects: Node2D = null

# Visual
var _body_rect: ColorRect = null
var _flash_tween: Tween = null


func _ready() -> void:
	_body_rect = $BodyRect
	_great_sword = $GreatSword
	_long_sword = $LongSword

	_great_sword.player = self
	_long_sword.player = self

	_great_sword.charge_level_changed.connect(_on_charge_level_changed)
	_long_sword.stance_entered.connect(_on_stance_entered)
	_long_sword.stance_exited.connect(_on_stance_exited)
	_update_color()


func _physics_process(delta: float) -> void:
	_handle_dodge(delta)
	_handle_movement(delta)
	_handle_weapon_input()
	_handle_facing()
	move_and_slide()


func _handle_movement(delta: float) -> void:
	if _dodging:
		velocity = _dodge_direction * DODGE_SPEED
		return

	# Grand iai dash overrides movement (handled by long_sword)
	if _long_sword.is_grand_iai_dashing():
		# velocity is set by long_sword._update_grand_iai
		return

	# Great sword shoulder tackle overrides movement
	if _great_sword.is_shoulder_tackling() if _great_sword.has_method("is_shoulder_tackling") else false:
		return

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	# Slower movement during stance
	var speed_mult: float = 0.4 if _weapon_mode == 0 and _long_sword.is_in_stance() else 1.0
	velocity = input_dir * MOVE_SPEED * speed_mult


func _handle_facing() -> void:
	# Don't change facing during grand iai dash or stance
	if _long_sword.is_grand_iai_dashing():
		return
	if velocity.length() > 10.0:
		_facing = velocity.normalized()
		rotation = _facing.angle()


func _handle_dodge(delta: float) -> void:
	if _dodge_cooldown_timer > 0.0:
		_dodge_cooldown_timer -= delta

	if _dodging:
		_dodge_timer -= delta
		if _dodge_timer <= 0.0:
			_dodging = false
			_invincible = false
			_update_color()
			_dodge_cooldown_timer = DODGE_COOLDOWN
		return

	if Input.is_action_just_pressed("dodge") and _dodge_cooldown_timer <= 0.0:
		# Long sword stance → dodge cancel
		if _weapon_mode == 0 and _long_sword.is_in_stance():
			if _long_sword.request_dodge_cancel():
				_start_dodge()
			return
		# Great sword charging → shoulder tackle
		if _weapon_mode == 1 and _great_sword.is_charging():
			if _great_sword.has_method("start_shoulder_tackle"):
				_great_sword.start_shoulder_tackle()
			return
		# Normal dodge
		_start_dodge()


func _start_dodge() -> void:
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	if dir == Vector2.ZERO:
		dir = _facing
	_dodge_direction = dir
	_dodging = true
	_dodge_timer = DODGE_DURATION
	_invincible = true
	if _body_rect:
		_body_rect.color = COLOR_DODGE


func _handle_weapon_input() -> void:
	# Switch weapon — only when not busy
	if Input.is_action_just_pressed("switch_weapon"):
		var can_switch := true
		if _weapon_mode == 0 and _long_sword.is_busy():
			can_switch = false
		elif _weapon_mode == 1 and (not _great_sword.can_act()):
			can_switch = false

		if can_switch:
			_weapon_mode = 1 - _weapon_mode
			_update_color()
			var name_str := "Long Sword (太刀)" if _weapon_mode == 0 else "Great Sword (大剑)"
			weapon_switched.emit(name_str)

	if _weapon_mode == 1:
		_handle_great_sword_input()
	else:
		_handle_long_sword_input()


func _handle_great_sword_input() -> void:
	if not _great_sword.can_act():
		return
	if Input.is_action_just_pressed("attack"):
		_great_sword.press_attack()
	if Input.is_action_just_released("attack"):
		_great_sword.release_attack()


func _handle_long_sword_input() -> void:
	# In stance: J = mini iai, L = grand iai, K = dodge cancel (handled in _handle_dodge)
	if _long_sword.is_in_stance():
		if Input.is_action_just_pressed("attack"):
			_long_sword.press_attack()   # routes to mini iai internally
		if Input.is_action_just_pressed("special"):
			_long_sword.press_special()  # routes to grand iai internally
		return

	# Normal mode
	if Input.is_action_just_pressed("attack") and _long_sword.can_act():
		_long_sword.press_attack()
	if Input.is_action_just_pressed("special") and _long_sword.can_act():
		_long_sword.press_special()


func take_damage(amount: int, source_position: Vector2) -> void:
	if _invincible:
		return

	# Grand iai absorb check — i-frames during dash
	if _weapon_mode == 0 and _long_sword.is_grand_iai_dashing():
		if _long_sword.try_grand_iai_absorb(source_position):
			return   # absorbed, no damage

	# Dodge i-frames
	if _dodging:
		return

	# Great sword shoulder tackle super armor — takes damage but doesn't interrupt
	if _weapon_mode == 1:
		var is_tackling: bool = _great_sword.is_shoulder_tackling() if _great_sword.has_method("is_shoulder_tackling") else false
		if is_tackling:
			# Take reduced damage but don't interrupt
			var reduced: int = max(1, amount / 2)
			_hp = max(0, _hp - reduced)
			health_changed.emit(_hp, MAX_HP)
			_flash_damage()
			if _hp <= 0:
				died.emit()
			return

	_hp = max(0, _hp - amount)
	health_changed.emit(_hp, MAX_HP)

	if camera:
		camera.shake(5.0, 0.15)

	_flash_damage()

	if _hp <= 0:
		died.emit()
		print("Player died.")


func _flash_damage() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(_body_rect, "color", Color.RED, 0.05)
	_flash_tween.tween_property(_body_rect, "color", _get_base_color(), 0.15)


func _on_charge_level_changed(level: int) -> void:
	if level == 3:
		if _flash_tween:
			_flash_tween.kill()
		_flash_tween = create_tween().set_loops()
		_flash_tween.tween_property(_body_rect, "color", COLOR_FULL_CHARGE, 0.1)
		_flash_tween.tween_property(_body_rect, "color", COLOR_GREAT_SWORD, 0.1)
	elif level == 0:
		if _flash_tween:
			_flash_tween.kill()
		_update_color()


func _on_stance_entered() -> void:
	if _body_rect:
		if _flash_tween:
			_flash_tween.kill()
		_flash_tween = create_tween().set_loops()
		_flash_tween.tween_property(_body_rect, "color", COLOR_STANCE, 0.3)
		_flash_tween.tween_property(_body_rect, "color", COLOR_LONG_SWORD, 0.3)


func _on_stance_exited() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_update_color()


func _update_color() -> void:
	if _body_rect:
		_body_rect.color = _get_base_color()


func _get_base_color() -> Color:
	if _weapon_mode == 0:
		return COLOR_LONG_SWORD
	else:
		return COLOR_GREAT_SWORD


func get_weapon_mode() -> int:
	return _weapon_mode


func get_long_sword() -> Node:
	return _long_sword


func get_great_sword() -> Node:
	return _great_sword


func get_hp() -> int:
	return _hp


func reset() -> void:
	_hp = MAX_HP
	_dodging = false
	_invincible = false
	_dodge_timer = 0.0
	_dodge_cooldown_timer = 0.0
	health_changed.emit(_hp, MAX_HP)
	_update_color()
