# PROTOTYPE - DNF 2.5D + Roguelite
extends CanvasLayer

## HUD — 玩家HP, 武器状态, 气槽, 技能冷却, 关卡信息

var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _room_label: Label = null
var _weapon_label: Label = null
var _spirit_label: Label = null
var _skill1_label: Label = null
var _skill2_label: Label = null
var _charge_label: Label = null
var _state_label: Label = null
var _controls_label: Label = null
var _combo_label: Label = null

var _player_ref: Node2D = null


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Player HP
	_hp_bar = ProgressBar.new()
	_hp_bar.position = Vector2(50, 30)
	_hp_bar.size = Vector2(300, 25)
	_hp_bar.max_value = 100
	_hp_bar.value = 100
	_hp_bar.show_percentage = false
	add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.position = Vector2(50, 56)
	_hp_label.add_theme_font_size_override("font_size", 16)
	add_child(_hp_label)

	# Weapon indicator
	_weapon_label = Label.new()
	_weapon_label.position = Vector2(50, 80)
	_weapon_label.add_theme_font_size_override("font_size", 20)
	_weapon_label.text = "⚔️ 太刀"
	add_child(_weapon_label)

	# Spirit gauge label
	_spirit_label = Label.new()
	_spirit_label.position = Vector2(200, 80)
	_spirit_label.add_theme_font_size_override("font_size", 16)
	add_child(_spirit_label)

	# Charge indicator (大剑)
	_charge_label = Label.new()
	_charge_label.position = Vector2(200, 80)
	_charge_label.add_theme_font_size_override("font_size", 16)
	add_child(_charge_label)

	# Room title
	_room_label = Label.new()
	_room_label.position = Vector2(760, 20)
	_room_label.size = Vector2(400, 40)
	_room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_room_label.add_theme_font_size_override("font_size", 28)
	add_child(_room_label)

	# Skill cooldowns
	_skill1_label = Label.new()
	_skill1_label.position = Vector2(50, 1000)
	_skill1_label.add_theme_font_size_override("font_size", 18)
	add_child(_skill1_label)

	_skill2_label = Label.new()
	_skill2_label.position = Vector2(350, 1000)
	_skill2_label.add_theme_font_size_override("font_size", 18)
	add_child(_skill2_label)

	# State label
	_state_label = Label.new()
	_state_label.position = Vector2(800, 100)
	_state_label.add_theme_font_size_override("font_size", 22)
	_state_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	add_child(_state_label)

	# Combo counter
	_combo_label = Label.new()
	_combo_label.position = Vector2(900, 480)
	_combo_label.add_theme_font_size_override("font_size", 36)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	add_child(_combo_label)

	# Controls help
	_controls_label = Label.new()
	_controls_label.position = Vector2(50, 1040)
	_controls_label.add_theme_font_size_override("font_size", 13)
	_controls_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_controls_label.text = "WASD移动 | Space跳 | J攻击 | K三段斩 | L居合(太刀)/崩山(大剑) | Shift闪避 | Tab切武器 | R重开"
	add_child(_controls_label)


func set_player(player: Node2D) -> void:
	_player_ref = player
	player.health_changed.connect(_on_hp_changed)
	player.weapon_switched.connect(_on_weapon_switched)
	player.combo_hit.connect(_on_combo_hit)
	player.skill_used.connect(_on_skill_used)
	player.spirit_changed.connect(_on_spirit_changed)
	_on_hp_changed(player.get_hp(), player.get_max_hp())


func _on_hp_changed(current: int, maximum: int) -> void:
	if _hp_bar:
		_hp_bar.max_value = maximum
		_hp_bar.value = current
	if _hp_label:
		_hp_label.text = "HP: %d / %d" % [current, maximum]


func _on_weapon_switched(weapon_name: String) -> void:
	if _weapon_label:
		var icon := "🗡️" if weapon_name == "太刀" else "⚔️"
		_weapon_label.text = "%s %s" % [icon, weapon_name]


func _on_spirit_changed(value: int) -> void:
	if _spirit_label and _player_ref and _player_ref.get_weapon_mode() == 0:
		_spirit_label.text = "气: %d/100" % value


func _on_combo_hit(index: int, damage: int) -> void:
	if _combo_label:
		var name_str: String
		if index == -1:
			name_str = "小居合"
		elif index == -2:
			name_str = "大居合!"
		elif index > 10:
			name_str = "大剑Lv%d" % (index - 10)
		else:
			name_str = "%d Hit" % (index + 1)
		_combo_label.text = "%s  %d dmg" % [name_str, damage]
		_combo_label.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_interval(0.6)
		tween.tween_property(_combo_label, "modulate:a", 0.0, 0.3)


func _on_skill_used(skill_name: String) -> void:
	if _state_label:
		_state_label.text = skill_name
		_state_label.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_interval(0.8)
		tween.tween_property(_state_label, "modulate:a", 0.0, 0.3)


func set_room_title(title: String) -> void:
	if _room_label:
		_room_label.text = title


func _process(_delta: float) -> void:
	if _player_ref == null:
		return

	# Skill cooldowns
	var cd1: float = _player_ref.get_triple_cooldown()
	var cd2: float = _player_ref.get_crash_cooldown()

	if _skill1_label:
		if cd1 > 0.0:
			_skill1_label.text = "[K] 三段斩 (%.1fs)" % cd1
			_skill1_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			_skill1_label.text = "[K] 三段斩 ✓"
			_skill1_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))

	if _skill2_label:
		var mode := _player_ref.get_weapon_mode()
		if mode == 0:
			_skill2_label.text = "[L] 居合構え (需30气)"
			_skill2_label.add_theme_color_override("font_color", Color(0.3, 0.5, 1.0))
		else:
			if cd2 > 0.0:
				_skill2_label.text = "[L] 崩山裂地斩 (%.1fs)" % cd2
				_skill2_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			else:
				_skill2_label.text = "[L] 崩山裂地斩 ✓"
				_skill2_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))

	# Weapon specific info
	var mode := _player_ref.get_weapon_mode()
	if mode == 0:
		_spirit_label.visible = true
		_charge_label.visible = false
		_spirit_label.text = "气: %d/100" % _player_ref.get_spirit()
	else:
		_spirit_label.visible = false
		_charge_label.visible = true
		if _player_ref.is_charging_gs():
			var lvl := _player_ref.get_gs_charge_level()
			var pips := "●" .repeat(lvl) + "○".repeat(3 - lvl)
			_charge_label.text = "蓄力: %s" % pips
			_charge_label.add_theme_color_override("font_color", Color.WHITE if lvl == 3 else Color(0.8, 0.8, 0.8))
		else:
			_charge_label.text = "蓄力: ○○○"
			_charge_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
