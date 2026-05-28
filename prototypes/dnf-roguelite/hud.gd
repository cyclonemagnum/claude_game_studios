# PROTOTYPE - DNF 2.5D + Roguelite
extends CanvasLayer

## HUD — 玩家HP, 技能冷却, 关卡信息, 操作提示

var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _room_label: Label = null
var _skill1_label: Label = null
var _skill2_label: Label = null
var _state_label: Label = null
var _controls_label: Label = null
var _combo_label: Label = null

var _player_ref: Node2D = null


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Player HP bar
	_hp_bar = ProgressBar.new()
	_hp_bar.position = Vector2(50, 30)
	_hp_bar.size = Vector2(300, 25)
	_hp_bar.max_value = 100
	_hp_bar.value = 100
	_hp_bar.show_percentage = false
	add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.position = Vector2(50, 55)
	_hp_label.add_theme_font_size_override("font_size", 16)
	add_child(_hp_label)

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
	_skill2_label.position = Vector2(300, 1000)
	_skill2_label.add_theme_font_size_override("font_size", 18)
	add_child(_skill2_label)

	# State label (current action)
	_state_label = Label.new()
	_state_label.position = Vector2(50, 80)
	_state_label.add_theme_font_size_override("font_size", 14)
	_state_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(_state_label)

	# Combo counter
	_combo_label = Label.new()
	_combo_label.position = Vector2(900, 500)
	_combo_label.add_theme_font_size_override("font_size", 40)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	add_child(_combo_label)

	# Controls help
	_controls_label = Label.new()
	_controls_label.position = Vector2(50, 1040)
	_controls_label.add_theme_font_size_override("font_size", 14)
	_controls_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_controls_label.text = "WASD移动 | Space跳跃 | J攻击 | K三段斩 | L崩山裂地斩 | Shift闪避 | R重开"
	add_child(_controls_label)


func set_player(player: Node2D) -> void:
	_player_ref = player
	player.health_changed.connect(_on_hp_changed)
	player.combo_hit.connect(_on_combo_hit)
	player.skill_used.connect(_on_skill_used)


func _on_hp_changed(current: int, maximum: int) -> void:
	if _hp_bar:
		_hp_bar.max_value = maximum
		_hp_bar.value = current
	if _hp_label:
		_hp_label.text = "HP: %d / %d" % [current, maximum]


func set_room_title(title: String) -> void:
	if _room_label:
		_room_label.text = title


func _on_combo_hit(index: int, damage: int) -> void:
	if _combo_label:
		_combo_label.text = "%d Hit! (%d)" % [index + 1, damage]
		# Fade out combo label
		var tween := create_tween()
		tween.tween_property(_combo_label, "modulate:a", 1.0, 0.0)
		tween.tween_interval(0.5)
		tween.tween_property(_combo_label, "modulate:a", 0.0, 0.3)


func _on_skill_used(skill_name: String) -> void:
	if _state_label:
		_state_label.text = skill_name + "!"
		var tween := create_tween()
		tween.tween_interval(0.8)
		tween.tween_callback(func(): _state_label.text = "")


func _process(_delta: float) -> void:
	if _player_ref == null:
		return

	# Update skill cooldowns
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
		if cd2 > 0.0:
			_skill2_label.text = "[L] 崩山裂地斩 (%.1fs)" % cd2
			_skill2_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			_skill2_label.text = "[L] 崩山裂地斩 ✓"
			_skill2_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
