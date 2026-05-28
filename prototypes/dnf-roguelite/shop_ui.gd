# PROTOTYPE - DNF 2.5D + Roguelite
extends CanvasLayer

## 商店UI — 关卡间选择强化
## 肉鸽核心: 每次选择3个随机buff中的1个

signal shop_closed()

const UPGRADES: Array[Dictionary] = [
	{"id": "iframes", "name": "延长无敌帧", "desc": "+0.05s 闪避无敌时间", "icon": "🛡️"},
	{"id": "range", "name": "扩大技能范围", "desc": "+20% 所有技能攻击范围", "icon": "⚔️"},
	{"id": "heal", "name": "生命恢复", "desc": "回复30点HP", "icon": "❤️"},
	{"id": "triple_cd", "name": "三段斩冷却缩减", "desc": "三段斩冷却-1s", "icon": "🔥"},
	{"id": "crash_cd", "name": "崩山冷却缩减", "desc": "崩山裂地斩冷却-2s", "icon": "💥"},
	{"id": "combo_dmg", "name": "普攻强化", "desc": "普攻伤害+3", "icon": "👊"},
	{"id": "dodge_speed", "name": "闪避加速", "desc": "闪避距离+15%", "icon": "💨"},
]

var _player_ref: Node2D = null
var _options: Array[Dictionary] = []
var _buttons: Array[Button] = []
var _panel: Panel = null
var _title_label: Label = null
var _desc_labels: Array[Label] = []


func _ready() -> void:
	visible = false
	_build_ui()


func _build_ui() -> void:
	# Background overlay
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)

	# Title
	_title_label = Label.new()
	_title_label.text = "⚔️ 选择强化 ⚔️"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(760, 150)
	_title_label.size = Vector2(400, 50)
	_title_label.add_theme_font_size_override("font_size", 36)
	add_child(_title_label)

	# Create 3 option buttons
	for i in range(3):
		var btn: Button = Button.new()
		btn.position = Vector2(310 + i * 440, 350)
		btn.size = Vector2(380, 250)
		btn.add_theme_font_size_override("font_size", 20)
		btn.pressed.connect(_on_option_selected.bind(i))
		add_child(btn)
		_buttons.append(btn)

		var desc: Label = Label.new()
		desc.position = Vector2(310 + i * 440, 610)
		desc.size = Vector2(380, 40)
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.add_theme_font_size_override("font_size", 16)
		desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		add_child(desc)
		_desc_labels.append(desc)


func open_shop(player: Node2D) -> void:
	_player_ref = player
	visible = true
	_generate_options()
	_update_buttons()
	# Pause game
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS


func _generate_options() -> void:
	_options.clear()
	var available: Array = UPGRADES.duplicate()
	available.shuffle()
	for i in range(min(3, available.size())):
		_options.append(available[i])


func _update_buttons() -> void:
	for i in range(3):
		if i < _options.size():
			var opt: Dictionary = _options[i]
			_buttons[i].text = "%s\n%s" % [opt["icon"], opt["name"]]
			_buttons[i].visible = true
			_desc_labels[i].text = opt["desc"]
		else:
			_buttons[i].visible = false
			_desc_labels[i].text = ""


func _on_option_selected(index: int) -> void:
	if index >= _options.size():
		return

	var opt: Dictionary = _options[index]
	_apply_upgrade(opt["id"])

	visible = false
	get_tree().paused = false
	shop_closed.emit()


func _apply_upgrade(upgrade_id: String) -> void:
	if _player_ref == null:
		return

	match upgrade_id:
		"iframes":
			_player_ref.iframes_duration += 0.05
			print("UPGRADE: 无敌帧 → %.2fs" % _player_ref.iframes_duration)
		"range":
			_player_ref.skill_range_mult += 0.2
			print("UPGRADE: 技能范围 → %.0f%%" % (_player_ref.skill_range_mult * 100))
		"heal":
			_player_ref.heal(30)
			print("UPGRADE: 回复30HP")
		"triple_cd":
			_player_ref.TRIPLE_SLASH_COOLDOWN = max(1.0, _player_ref.TRIPLE_SLASH_COOLDOWN - 1.0)
			print("UPGRADE: 三段斩CD → %.1fs" % _player_ref.TRIPLE_SLASH_COOLDOWN)
		"crash_cd":
			_player_ref.CRASH_SLASH_COOLDOWN = max(2.0, _player_ref.CRASH_SLASH_COOLDOWN - 2.0)
			print("UPGRADE: 崩山CD → %.1fs" % _player_ref.CRASH_SLASH_COOLDOWN)
		"combo_dmg":
			for i in range(_player_ref.COMBO_DAMAGE.size()):
				_player_ref.COMBO_DAMAGE[i] += 3
			print("UPGRADE: 普攻伤害+3")
		"dodge_speed":
			_player_ref.DODGE_SPEED *= 1.15
			print("UPGRADE: 闪避速度+15%%")
