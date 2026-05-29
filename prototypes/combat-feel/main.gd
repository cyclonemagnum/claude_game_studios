# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D

## Main scene — combat arena. Spawns player and boss, wires everything together.

var _player: CharacterBody2D = null
var _boss: CharacterBody2D = null
var _camera: Camera2D = null
var _hud: CanvasLayer = null
var _hit_effects: Node2D = null
var _sword_trail: Line2D = null

var _frame_count: int = 0


func _ready() -> void:
	_player = $Player
	_boss = $Boss
	_camera = $Camera2D
	_hud = $HUD
	_hit_effects = $HitEffects

	# Wire camera
	_camera.set_target(_player)

	# Build sword trail
	_sword_trail = Line2D.new()
	_sword_trail.set_script(preload("res://sword_trail.gd"))
	add_child(_sword_trail)
	_sword_trail.set_player(_player)

	# Wire player refs
	_player.camera = _camera
	_player.hit_effects = _hit_effects
	_player.get_great_sword().camera = _camera
	_player.get_great_sword().hit_effects = _hit_effects
	_player.get_long_sword().camera = _camera
	_player.get_long_sword().hit_effects = _hit_effects

	# Wire boss
	_boss.set_player(_player)

	# Wire HUD initial state
	_hud.set_player_hp(_player.get_hp(), 100)
	_hud.set_boss_hp(500, 500)
	_hud.set_weapon("Long Sword (太刀)", 0)
	_hud.set_spirit(0)
	_hud.set_spirit_level(0)
	_hud.set_charge_level(0)

	# Connect signals — player
	_player.health_changed.connect(_on_player_health_changed)
	_player.weapon_switched.connect(_on_weapon_switched)
	_player.died.connect(_on_player_died)

	# Connect signals — boss
	_boss.health_changed.connect(_on_boss_health_changed)
	_boss.defeated.connect(_on_boss_defeated)
	_boss.phase_changed.connect(_on_boss_phase_changed)

	# Connect signals — long sword
	var ls: Node = _player.get_long_sword()
	ls.spirit_changed.connect(_hud.set_spirit)
	ls.spirit_level_changed.connect(_hud.set_spirit_level)
	ls.grand_iai_success.connect(_on_grand_iai_success)

	# Connect signals — great sword
	var gs: Node = _player.get_great_sword()
	gs.charge_level_changed.connect(_hud.set_charge_level)

	# HUD parry window changes → long sword grand iai window
	_hud.parry_window_changed.connect(_on_parry_window_changed)
	ls.grand_iai_window_frames = _hud.get_parry_frames()


func _physics_process(delta: float) -> void:
	_frame_count += 1

	if Input.is_action_just_pressed("restart"):
		_restart()

	# Update debug label
	var ls: Node = _player.get_long_sword()
	var stance_str: String = ls.get_stance_state()
	var debug := "帧: %d  |  气: %d  |  状态: %s  |  Boss P%d  |  U=後跳見切, 大居合命中后L=登龍" % [
		_frame_count,
		ls.get_spirit(),
		stance_str,
		_boss.get_phase() + 1,
	]
	_hud.update_debug(debug)

	# Update sword trail highlight based on player action
	_update_sword_trail()


func _update_sword_trail() -> void:
	if _sword_trail == null:
		return
	var ls: Node = _player.get_long_sword()
	var gs: Node = _player.get_great_sword()
	var mode: int = _player.get_weapon_mode()

	var alpha: float = 0.0
	var color: Color = Color.WHITE

	if mode == 0:
		# 太刀
		if ls.is_toryu_active():
			alpha = 1.0
			color = Color(1.0, 0.85, 0.3)   # 金色
		elif ls.is_grand_iai_dashing():
			alpha = 1.0
			color = Color(0.6, 0.95, 1.0)   # 浅蓝
		elif ls.is_counter_dashing():
			alpha = 1.0
			color = Color(0.7, 1.0, 0.9)
		elif ls.is_back_stepping():
			alpha = 0.4
			color = Color(0.5, 0.7, 1.0)
		elif ls.is_in_stance():
			alpha = 0.35
			color = Color(0.4, 0.5, 1.0)
		else:
			# 普攻挥砍时短暂高亮 — 通过 hit_active 状态判定
			# (long_sword 没有 public 接口, 用气槽近期增加做近似 — 简化为玩家在动)
			if _player.velocity.length() > 50.0:
				alpha = 0.3
			else:
				alpha = 0.15
			color = Color(0.85, 0.95, 1.0)
	else:
		# 大剑
		var charge_lv: int = gs.get_charge_level() if gs.has_method("get_charge_level") else 0
		if gs.is_shoulder_tackling() if gs.has_method("is_shoulder_tackling") else false:
			alpha = 0.9
			color = Color(1.0, 0.5, 0.2)
		elif charge_lv == 3:
			alpha = 0.8
			color = Color(1.0, 1.0, 0.6)
		elif charge_lv == 2:
			alpha = 0.5
			color = Color(1.0, 0.85, 0.3)
		elif charge_lv == 1:
			alpha = 0.3
			color = Color(1.0, 0.7, 0.2)
		else:
			alpha = 0.15
			color = Color(0.9, 0.55, 0.15)

	_sword_trail.set_highlight(alpha, color)


func _on_player_health_changed(current: int, maximum: int) -> void:
	_hud.set_player_hp(current, maximum)


func _on_weapon_switched(weapon_name: String) -> void:
	var mode := 1 if "Great" in weapon_name else 0
	_hud.set_weapon(weapon_name, mode)


func _on_player_died() -> void:
	print("--- FIGHT OVER: Player died. Press R to restart. ---")


func _on_boss_health_changed(current: int, maximum: int) -> void:
	_hud.set_boss_hp(current, maximum)


func _on_boss_defeated() -> void:
	print("--- FIGHT OVER: Boss defeated! Press R to restart. ---")


func _on_grand_iai_success(frame_hit: int, window: int) -> void:
	_hud.flash_iai_success()
	_boss.notify_parried()


func _on_boss_phase_changed(new_phase: int) -> void:
	_hud.set_boss_phase(new_phase)


func _on_parry_window_changed(new_frames: int) -> void:
	_player.get_long_sword().grand_iai_window_frames = new_frames
	print("Grand Iai window set to %d frames (%.0fms)" % [new_frames, new_frames * (1000.0 / 60.0)])


func _restart() -> void:
	print("--- RESTARTING ---")
	get_tree().reload_current_scene()
