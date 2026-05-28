# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## 杂兵敌人 — 简单AI，走向玩家并攻击
## 同样使用2.5D坐标系: ground_x, ground_z, air_height

const MOVE_SPEED: float = 120.0
const ATTACK_RANGE: float = 60.0
const ATTACK_DAMAGE: int = 10
const ATTACK_COOLDOWN: float = 1.5
const ATTACK_TELEGRAPH: float = 0.4
const HP_DEFAULT: int = 40
const AGGRO_RANGE: float = 500.0

const COLOR_IDLE: Color = Color(0.8, 0.2, 0.2)
const COLOR_TELEGRAPH: Color = Color(1.0, 0.7, 0.0)
const COLOR_HURT: Color = Color(1.0, 1.0, 1.0)

signal enemy_died(enemy: Node2D)

enum State { IDLE, CHASE, TELEGRAPH, ATTACK, HURT, DEAD }

var ground_x: float = 0.0
var ground_z: float = 0.0
var air_height: float = 0.0

var _hp: int = HP_DEFAULT
var _max_hp: int = HP_DEFAULT
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _player_ref: Node2D = null
var _facing: int = 1
var _knockback_vel: float = 0.0

# Visual
var _body: ColorRect = null
var _shadow: ColorRect = null
var _hp_bar: ColorRect = null
var _hp_bg: ColorRect = null


func _ready() -> void:
	add_to_group("enemies")
	_build_visual()
	_state_timer = randf_range(0.3, 1.0)


func setup(pos_x: float, pos_z: float, hp: int = HP_DEFAULT) -> void:
	ground_x = pos_x
	ground_z = pos_z
	_hp = hp
	_max_hp = hp
	position.x = ground_x
	position.y = ground_z


func set_player(p: Node2D) -> void:
	_player_ref = p


func _build_visual() -> void:
	_shadow = ColorRect.new()
	_shadow.size = Vector2(32, 12)
	_shadow.position = Vector2(-16, -6)
	_shadow.color = Color(0, 0, 0, 0.25)
	add_child(_shadow)

	_body = ColorRect.new()
	_body.size = Vector2(30, 45)
	_body.position = Vector2(-15, -45)
	_body.color = COLOR_IDLE
	add_child(_body)

	# HP bar background
	_hp_bg = ColorRect.new()
	_hp_bg.size = Vector2(30, 4)
	_hp_bg.position = Vector2(-15, -52)
	_hp_bg.color = Color(0.2, 0.2, 0.2)
	add_child(_hp_bg)

	# HP bar
	_hp_bar = ColorRect.new()
	_hp_bar.size = Vector2(30, 4)
	_hp_bar.position = Vector2(-15, -52)
	_hp_bar.color = Color(0.1, 0.8, 0.1)
	add_child(_hp_bar)


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return

	_attack_cooldown -= delta

	# Knockback
	if abs(_knockback_vel) > 10.0:
		ground_x += _knockback_vel * delta
		_knockback_vel *= 0.85

	match _state:
		State.IDLE:
			_tick_idle(delta)
		State.CHASE:
			_tick_chase(delta)
		State.TELEGRAPH:
			_tick_telegraph(delta)
		State.HURT:
			_tick_hurt(delta)

	_update_position()
	_update_visual()


func _tick_idle(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		if _player_ref:
			_state = State.CHASE


func _tick_chase(delta: float) -> void:
	if _player_ref == null:
		return

	var dx: float = _player_ref.ground_x - ground_x
	var dz: float = _player_ref.ground_z - ground_z
	var dist: float = sqrt(dx * dx + dz * dz)

	_facing = 1 if dx > 0 else -1

	if dist <= ATTACK_RANGE and _attack_cooldown <= 0.0:
		_state = State.TELEGRAPH
		_state_timer = ATTACK_TELEGRAPH
		return

	# Move toward player
	var dir_x: float = dx / max(dist, 1.0)
	var dir_z: float = dz / max(dist, 1.0)
	ground_x += dir_x * MOVE_SPEED * delta
	ground_z += dir_z * MOVE_SPEED * 0.6 * delta


func _tick_telegraph(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_execute_attack()
		_state = State.CHASE
		_attack_cooldown = ATTACK_COOLDOWN


func _tick_hurt(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_state = State.CHASE


func _execute_attack() -> void:
	if _player_ref == null:
		return
	var dx: float = abs(_player_ref.ground_x - ground_x)
	var dz: float = abs(_player_ref.ground_z - ground_z)
	if dx < ATTACK_RANGE * 1.3 and dz < 40.0:
		_player_ref.take_damage(ATTACK_DAMAGE, ground_x)


func take_damage(amount: int, source_x: float) -> void:
	if _state == State.DEAD:
		return
	_hp -= amount
	_knockback_vel = 200.0 * (1.0 if ground_x > source_x else -1.0)
	_state = State.HURT
	_state_timer = 0.2

	if _hp <= 0:
		_die()
	else:
		_update_hp_bar()


func _die() -> void:
	_state = State.DEAD
	_body.color = Color(0.3, 0.3, 0.3, 0.5)
	_hp_bg.visible = false
	_hp_bar.visible = false
	enemy_died.emit(self)
	# Fade out
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func _update_position() -> void:
	position.x = ground_x
	position.y = ground_z - air_height
	z_index = int(ground_z)


func _update_visual() -> void:
	match _state:
		State.TELEGRAPH:
			_body.color = COLOR_TELEGRAPH
		State.HURT:
			_body.color = COLOR_HURT
		State.DEAD:
			pass
		_:
			_body.color = COLOR_IDLE

	_shadow.position.y = air_height - 6


func _update_hp_bar() -> void:
	if _hp_bar:
		var ratio: float = float(_hp) / float(_max_hp)
		_hp_bar.size.x = 30.0 * ratio
