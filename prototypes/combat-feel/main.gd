# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D

## Main scene — combat arena. Spawns player and boss, wires everything together.

const Cards = preload("res://cards.gd")
const RewardScreenScript = preload("res://reward_screen.gd")
const RunStateScript = preload("res://run_state.gd")

var _player: CharacterBody2D = null
var _boss: CharacterBody2D = null
var _camera: Camera2D = null
var _hud: CanvasLayer = null
var _hit_effects: Node2D = null
var _sword_trail: Line2D = null
var _reward_screen: CanvasLayer = null
var _run_state: Node = null
var _sfx: Node = null

var _frame_count: int = 0
var _wave_index: int = 0           # 0/1/2 — 共 3 波 Boss
const TOTAL_WAVES: int = 3
const WAVE_HP_SCALE: Array[float] = [1.0, 1.4, 1.8]


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

	# Build run state
	_run_state = Node.new()
	_run_state.set_script(RunStateScript)
	_run_state.name = "RunState"
	add_child(_run_state)

	# Build SFX manager
	_sfx = Node.new()
	_sfx.set_script(preload("res://sfx_manager.gd"))
	_sfx.name = "Sfx"
	add_child(_sfx)

	# Build reward screen
	_reward_screen = CanvasLayer.new()
	_reward_screen.set_script(RewardScreenScript)
	_reward_screen.name = "RewardScreen"
	add_child(_reward_screen)
	_reward_screen.card_selected.connect(_on_card_selected)

	# Wire player refs
	_player.camera = _camera
	_player.hit_effects = _hit_effects
	_player.get_great_sword().camera = _camera
	_player.get_great_sword().hit_effects = _hit_effects
	_player.get_long_sword().camera = _camera
	_player.get_long_sword().hit_effects = _hit_effects
	_player.get_long_sword().run_state_ref = _run_state

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
	if _player.has_signal("dodge_started"):
		_player.dodge_started.connect(func(): _sfx.play_random_pitch("dodge"))

	# Connect signals — boss
	_boss.health_changed.connect(_on_boss_health_changed)
	_boss.defeated.connect(_on_boss_defeated)
	_boss.phase_changed.connect(_on_boss_phase_changed)
	_boss.attack_telegraphed.connect(_on_boss_telegraph)

	# Connect signals — long sword
	var ls: Node = _player.get_long_sword()
	ls.spirit_changed.connect(_hud.set_spirit)
	ls.spirit_level_changed.connect(_hud.set_spirit_level)
	ls.grand_iai_success.connect(_on_grand_iai_success)
	ls.combo_hit.connect(_on_combo_hit)
	ls.stance_entered.connect(func(): _sfx.play("stance"))
	if ls.has_signal("toryu_started"):
		ls.toryu_started.connect(func(): _sfx.play("toryu_launch"))
	if ls.has_signal("toryu_landed"):
		ls.toryu_landed.connect(func(_d, _p): _sfx.play("toryu_impact"))
	if ls.has_signal("back_step_started"):
		ls.back_step_started.connect(func(): _sfx.play("dodge", 1.15))
	if ls.has_signal("back_step_absorbed"):
		ls.back_step_absorbed.connect(func(_f, _w): _sfx.play("iai_success", 1.15))

	# Connect signals — great sword
	var gs: Node = _player.get_great_sword()
	gs.charge_level_changed.connect(_hud.set_charge_level)
	gs.charge_level_changed.connect(_on_charge_level_for_sfx)
	if gs.has_signal("attacked"):
		gs.attacked.connect(_on_gs_swing)

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
	var cards_str: String = ""
	if _run_state.collected_card_ids.size() > 0:
		var names: Array[String] = []
		for cid in _run_state.collected_card_ids:
			var c: Dictionary = Cards.get_card_by_id(cid)
			names.append(c["name"])
		cards_str = "  |  卷轴: " + ", ".join(names)
	var debug := "波次 %d/%d  |  气: %d  |  状态: %s  |  Boss P%d%s" % [
		_wave_index + 1,
		TOTAL_WAVES,
		ls.get_spirit(),
		stance_str,
		_boss.get_phase() + 1,
		cards_str,
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
	# 受击音效 (HP减少时)
	if _last_player_hp > current and _sfx:
		_sfx.play_random_pitch("player_hurt")
	_last_player_hp = current


var _last_player_hp: int = 100


func _on_weapon_switched(weapon_name: String) -> void:
	var mode := 1 if "Great" in weapon_name else 0
	_hud.set_weapon(weapon_name, mode)


func _on_player_died() -> void:
	print("--- FIGHT OVER: Player died. Press R to restart. ---")


func _on_boss_health_changed(current: int, maximum: int) -> void:
	_hud.set_boss_hp(current, maximum)


func _on_boss_defeated() -> void:
	print("--- WAVE %d CLEARED ---" % (_wave_index + 1))
	if _sfx:
		_sfx.play("boss_defeated")
	if _wave_index >= TOTAL_WAVES - 1:
		print("--- RUN COMPLETE! Press R to restart. ---")
		return
	# 弹出奖励界面
	var existing_ids: Array[String] = []
	for cid in _run_state.collected_card_ids:
		existing_ids.append(cid)
	var choices: Array[Dictionary] = Cards.get_random_choices(3, existing_ids)
	if choices.size() == 0:
		_advance_wave()
		return
	# 延迟一下让Boss死亡动画播放
	await get_tree().create_timer(0.8).timeout
	_reward_screen.open(choices)


func _on_card_selected(card_id: String) -> void:
	var card: Dictionary = Cards.get_card_by_id(card_id)
	print("CARD PICKED: [%s] %s" % [Cards.get_type_name(card["type"]), card["name"]])
	_run_state.add_card(card_id, _player, _player.get_long_sword(), _player.get_great_sword())
	if _sfx:
		_sfx.play("card_pick")
	_advance_wave()


func _advance_wave() -> void:
	_wave_index += 1
	# 重置玩家
	_player.reset_for_next_wave()
	# 重置 Boss + 缩放 HP
	var hp_scale: float = WAVE_HP_SCALE[clampi(_wave_index, 0, WAVE_HP_SCALE.size() - 1)]
	_boss.respawn_for_wave(hp_scale)
	_hud.set_boss_hp(_boss.get_max_hp_scaled(), _boss.get_max_hp_scaled())
	print("--- WAVE %d START (HP scale %.1fx) ---" % [_wave_index + 1, hp_scale])


func _on_grand_iai_success(frame_hit: int, window: int) -> void:
	_hud.flash_iai_success()
	_boss.notify_parried()
	if _sfx:
		_sfx.play("iai_success")


func _on_combo_hit(hit_index: int, damage: int, _pos: Vector2) -> void:
	if _sfx == null:
		return
	# 大居合反击 / 终结技 → 重击音效
	if hit_index == -2:    # grand iai counter
		_sfx.play("hit_heavy")
	elif hit_index == -1:  # mini iai
		_sfx.play_random_pitch("hit_light", 0.85, 0.95)
	elif damage >= 60:
		_sfx.play("hit_heavy")
	else:
		_sfx.play_random_pitch("hit_light")
	# 武器挥动声 — 在普攻时播放
	if hit_index >= 0:
		_sfx.play_random_pitch("whoosh", 0.95, 1.1)


func _on_charge_level_for_sfx(level: int) -> void:
	if _sfx == null or level <= 0:
		return
	_sfx.play("charge_up", 1.0 + (level - 1) * 0.15, -8.0)


func _on_gs_swing(damage: int, _pos: Vector2, charge_level: int) -> void:
	if _sfx == null:
		return
	if charge_level >= 3:
		_sfx.play("hit_heavy", 1.05)
	elif charge_level == 2:
		_sfx.play("hit_heavy", 0.85, -3.0)
	else:
		_sfx.play_random_pitch("hit_light")
	_sfx.play("whoosh", 0.7 + charge_level * 0.1, -2.0)


func _on_boss_phase_changed(new_phase: int) -> void:
	_hud.set_boss_phase(new_phase)


func _on_boss_telegraph(_attack_name: String) -> void:
	if _sfx:
		_sfx.play_random_pitch("telegraph", 0.95, 1.05)


func _on_parry_window_changed(new_frames: int) -> void:
	_player.get_long_sword().grand_iai_window_frames = new_frames
	print("Grand Iai window set to %d frames (%.0fms)" % [new_frames, new_frames * (1000.0 / 60.0)])


func _restart() -> void:
	print("--- RESTARTING ---")
	get_tree().reload_current_scene()
