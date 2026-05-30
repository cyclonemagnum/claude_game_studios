# PROTOTYPE - Reward screen
extends CanvasLayer

## 战胜后弹出的卷轴选择界面 — 3 选 1
## 暂停游戏 → 玩家选 → 应用 buff → 关闭 → 进入下一波

const Cards = preload("res://cards.gd")

signal card_selected(card_id: String)

var _options: Array[Dictionary] = []
var _buttons: Array[Button] = []
var _bg_overlay: ColorRect = null
var _title_label: Label = null


func _ready() -> void:
	visible = false
	layer = 8
	_build_ui()


func _build_ui() -> void:
	_bg_overlay = ColorRect.new()
	_bg_overlay.color = Color(0, 0, 0, 0.78)
	_bg_overlay.anchor_right = 1.0
	_bg_overlay.anchor_bottom = 1.0
	add_child(_bg_overlay)

	_title_label = Label.new()
	_title_label.text = "◆  选择一张卷轴  ◆"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(660, 130)
	_title_label.size = Vector2(600, 60)
	_title_label.add_theme_font_size_override("font_size", 42)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	add_child(_title_label)

	# 3 张卡按钮
	for i in range(3):
		var btn: Button = Button.new()
		btn.position = Vector2(280 + i * 470, 320)
		btn.size = Vector2(420, 380)
		btn.add_theme_font_size_override("font_size", 22)
		btn.flat = false
		btn.pressed.connect(_on_card_pressed.bind(i))
		add_child(btn)
		_buttons.append(btn)


func open(options: Array[Dictionary]) -> void:
	_options = options
	for i in range(_buttons.size()):
		var btn: Button = _buttons[i]
		if i < _options.size():
			var card: Dictionary = _options[i]
			var color: Color = Cards.get_type_color(card["type"])
			var type_name: String = Cards.get_type_name(card["type"])
			btn.text = "[%s]\n\n%s\n\n%s\n\n· %s" % [
				type_name,
				card["name"],
				card["desc"],
				card["detail"],
			]
			# 按类型染色
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(color.r * 0.25, color.g * 0.25, color.b * 0.25, 0.95)
			sb.border_width_top = 4
			sb.border_width_bottom = 4
			sb.border_width_left = 4
			sb.border_width_right = 4
			sb.border_color = color
			sb.corner_radius_top_left = 8
			sb.corner_radius_top_right = 8
			sb.corner_radius_bottom_left = 8
			sb.corner_radius_bottom_right = 8
			btn.add_theme_stylebox_override("normal", sb)
			var sb_hover := sb.duplicate() as StyleBoxFlat
			sb_hover.bg_color = Color(color.r * 0.45, color.g * 0.45, color.b * 0.45, 1.0)
			btn.add_theme_stylebox_override("hover", sb_hover)
			btn.add_theme_color_override("font_color", color)
			btn.visible = true
		else:
			btn.visible = false
	visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	for b in _buttons:
		b.process_mode = Node.PROCESS_MODE_ALWAYS
	_bg_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_title_label.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_card_pressed(index: int) -> void:
	if index >= _options.size():
		return
	var card: Dictionary = _options[index]
	visible = false
	get_tree().paused = false
	card_selected.emit(card["id"])
