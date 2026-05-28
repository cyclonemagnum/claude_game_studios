# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## Boss敌人 — 更强的敌人，有更多HP和攻击模式
## 使用与mob相同的2.5D坐标系

const MOVE_SPEED: float = 100.0
const HP_DEFAULT: int = 200
const ATTACK_RANGE: float = 100.0
const ATTACK_DAMAGE: int = 20
const ATTACK_COOLDOWN: float = 2.0
const ATTACK_TELEGRAPH: float = 0.6
const SLAM_DAMAGE: int = 35
const SLAM_RANGE: float = 150.0
const SLAM_TELEGRAPH: float = 0.8

const COLOR_IDLE: Color = Color(0.6, 0.1, 0.1)
const COLOR_TELEGRAPH: Color = Color(1.0, 0.5, 0.0)
const COLOR_SLAM: Color = Color(1.0, 0.0, 0.0)

signal enemy_died(enemy: Node2D)

enum State { IDLE, CHASE, TELEGRAPH, ATTACK, SLAM_TELEGRAPH, SLAM, HURT, DEAD }

var ground_x: float = 0.0
var ground_z: float = 0.0
var air_height: float = 0.0

var _hp: int = HP_DEFAULT
var _max_hp: int = HP_DEFAULT
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _attack_count: int = 0
var _player_ref: Node2D = null
var _facing: int = -1
var _knockback_vel: float = 0.0

var _body: ColorRect = null
var _shadow: ColorRect = null
var _hp_bar: ColorRect = null
var _hp_bg: ColorRect = null
var _label: Label = null


func _ready() -> void:
	add_to_group("enemies")
	_build_visual()
	_state_timer = 1.0


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
	_shadow.size = Vector2(60, 20)
	_shadow.position = Vector2(-30, -10)
	_shadow.color = Color(0, 0, 0, 0.35)
	add_child(_shadow)

	_body = ColorRect.new()
	_body.size = Vector2(55, 80)
	_body.position = Vector2(-27, -80)
	_body.color = COLOR_IDLE
	add_child(_body)

	_hp_bg = ColorRect.new()
	_hp_bg.size = Vector2(55, 6)
	_hp_bg.position = Vector2(-27, -90)
	_hp_bg.color = Color(0.2, 0.2, 0.2)
	add_child(_hp_bg)

	_hp_bar = ColorRect.new()
	_hp_bar.size = Vector2(55, 6)
	_hp_bar.position = Vector2(-27, -90)
	_hp_bar.color = Color(0.9, 0.2, 0.2)
	add_child(_hp_bar)

	_label = Label.new()
	_label.position = Vector2(-30, -105)
	_label.add_theme_font_size_override("font_size", 14)
	_label.text = "BOSS"
	add_child(_label)


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return

	_attack_cooldown -= delta

	if abs(_knockback_vel) > 10.0:
		ground_x += _knockback_vel * delta
		_knockback_vel *= 0.9

	match _state:
		State.IDLE:
			_state_timer -= delta
			if _state_timer <= 0.0:
				_state = State.CHASE
		State.CHASE:
			_tick_chase(delta)
		State.TELEGRAPH:
			_state_timer -= delta
			_body.color = COLOR_TELEGRAPH
			if _state_timer <= 0.0:
				_execute_attack()
		State.SLAM_TELEGRAPH:
			_state_timer -= delta
			_body.color = COLOR_SLAM
			_label.text = "! 重击 !"
			if _state_timer <= 0.0:
				_execute_slam()
		State.HURT:
			_state_timer -= delta
			if _state_timer <= 0.0:
				_state = State.CHASE
				_body.color = COLOR_IDLE

	_update_position()


func _tick_chase(delta: float) -> void:
	if _player_ref == null:
		return
	var dx: float = _player_ref.ground_x - ground_x
	var dz: float = _player_ref.ground_z - ground_z
	var dist: float = sqrt(dx * dx + dz * dz)

	_facing = 1 if dx > 0 else -1

	if dist <= ATTACK_RANGE and _attack_cooldown <= 0.0:
		# Every 3rd attack is a slam
		_attack_count += 1
		if _attack_count % 3 == 0:
			_state = State.SLAM_TELEGRAPH
			_state_timer = SLAM_TELEGRAPH
		else:
			_state = State.TELEGRAPH
			_state_timer = ATTACK_TELEGRAPH
		return

	ground_x += (dx / max(dist, 1.0)) * MOVE_SPEED * delta
	ground_z += (dz / max(dist, 1.0)) * MOVE_SPEED * 0.5 * delta


func _execute_attack() -> void:
	_state = State.CHASE
	_attack_cooldown = ATTACK_COOLDOWN
	_body.color = COLOR_IDLE
	_label.text = "BOSS"

	if _player_ref:
		var dx: float = abs(_player_ref.ground_x - ground_x)
		var dz: float = abs(_player_ref.ground_z - ground_z)
		if dx < ATTACK_RANGE * 1.5 and dz < 50.0:
			_player_ref.take_damage(ATTACK_DAMAGE, ground_x)


func _execute_slam() -> void:
	_state = State.CHASE
	_attack_cooldown = ATTACK_COOLDOWN * 1.5
	_body.color = COLOR_IDLE
	_label.text = "BOSS"

	if _player_ref:
		var dx: float = abs(_player_ref.ground_x - ground_x)
		var dz: float = abs(_player_ref.ground_z - ground_z)
		if dx < SLAM_RANGE and dz < 60.0:
			_player_ref.take_damage(SLAM_DAMAGE, ground_x)


func take_damage(amount: int, source_x: float) -> void:
	if _state == State.DEAD:
		return
	_hp -= amount
	_knockback_vel = 100.0 * (1.0 if ground_x > source_x else -1.0)
	_state = State.HURT
	_state_timer = 0.15
	_body.color = Color.WHITE

	if _hp <= 0:
		_die()
	else:
		_update_hp_bar()


func _die() -> void:
	_state = State.DEAD
	_body.color = Color(0.3, 0.3, 0.3)
	_label.text = "DEFEATED!"
	_hp_bg.visible = false
	_hp_bar.visible = false
	enemy_died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


func _update_position() -> void:
	position.x = ground_x
	position.y = ground_z - air_height
	z_index = int(ground_z)


func _update_hp_bar() -> void:
	if _hp_bar:
		_hp_bar.size.x = 55.0 * (float(_hp) / float(_max_hp))
