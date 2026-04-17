# PROTOTYPE - NOT FOR PRODUCTION
extends CanvasLayer

## Minimal HUD: HP bars, weapon indicator, spirit gauge, charge pips, iai window display.

signal parry_window_changed(new_frames: int)

const SPIRIT_COLORS: Array[Color] = [
	Color.WHITE,
	Color.YELLOW,
	Color(1.0, 0.3, 0.2)
]
const SPIRIT_LEVEL_NAMES: Array[String] = ["白 White", "黄 Yellow", "赤 Red"]

var _player_hp_bar: ProgressBar = null
var _boss_hp_bar: ProgressBar = null
var _weapon_label: Label = null
var _spirit_container: Control = null
var _spirit_bar: ProgressBar = null
var _spirit_level_label: Label = null
var _charge_container: Control = null
var _charge_pips: Array[ColorRect] = []
var _iai_window_label: Label = null
var _debug_label: Label = null
var _iai_flash_rect: ColorRect = null

var _current_parry_frames: int = 6


func _ready() -> void:
	_player_hp_bar = $PlayerHP
	_boss_hp_bar = $BossHP
	_weapon_label = $WeaponLabel
	_spirit_container = $SpiritContainer
	_spirit_bar = $SpiritContainer/SpiritBar
	_spirit_level_label = $SpiritContainer/SpiritLevelLabel
	_charge_container = $ChargeContainer
	_charge_pips = [
		$ChargeContainer/Pip1,
		$ChargeContainer/Pip2,
		$ChargeContainer/Pip3,
	]
	_iai_window_label = $IaiWindowLabel
	_debug_label = $DebugLabel
	_iai_flash_rect = $IaiFlash

	_update_iai_label()
	_spirit_container.visible = true
	_charge_container.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("parry_window_increase"):
		_current_parry_frames = min(20, _current_parry_frames + 1)
		_update_iai_label()
		parry_window_changed.emit(_current_parry_frames)
	elif event.is_action_pressed("parry_window_decrease"):
		_current_parry_frames = max(1, _current_parry_frames - 1)
		_update_iai_label()
		parry_window_changed.emit(_current_parry_frames)


func set_player_hp(current: int, maximum: int) -> void:
	if _player_hp_bar:
		_player_hp_bar.max_value = maximum
		_player_hp_bar.value = current


func set_boss_hp(current: int, maximum: int) -> void:
	if _boss_hp_bar:
		_boss_hp_bar.max_value = maximum
		_boss_hp_bar.value = current


func set_weapon(name_str: String, mode: int) -> void:
	if _weapon_label:
		_weapon_label.text = name_str
	# mode 0 = long sword, 1 = great sword
	if _spirit_container:
		_spirit_container.visible = (mode == 0)
	if _charge_container:
		_charge_container.visible = (mode == 1)


func set_spirit(value: int) -> void:
	if _spirit_bar:
		_spirit_bar.value = value


func set_spirit_level(level: int) -> void:
	var color := SPIRIT_COLORS[clamp(level, 0, 2)]
	if _spirit_bar:
		# Tint bar
		var style := StyleBoxFlat.new()
		style.bg_color = color
		_spirit_bar.add_theme_stylebox_override("fill", style)
	if _spirit_level_label:
		_spirit_level_label.text = SPIRIT_LEVEL_NAMES[clamp(level, 0, 2)]
		_spirit_level_label.add_theme_color_override("font_color", color)


func set_charge_level(level: int) -> void:
	for i in range(3):
		if _charge_pips[i]:
			_charge_pips[i].color = Color.WHITE if i < level else Color(0.3, 0.3, 0.3)


func flash_iai_success() -> void:
	if _iai_flash_rect:
		_iai_flash_rect.visible = true
		_iai_flash_rect.color = Color(0.3, 0.7, 1.0, 0.6)
		var tween := create_tween()
		tween.tween_property(_iai_flash_rect, "color:a", 0.0, 0.4)
		tween.tween_callback(func(): _iai_flash_rect.visible = false)


func update_debug(text: String) -> void:
	if _debug_label:
		_debug_label.text = text


func _update_iai_label() -> void:
	if _iai_window_label:
		_iai_window_label.text = "見切窗口: %d帧 (%.0fms)" % [_current_parry_frames, _current_parry_frames * (1000.0 / 60.0)]


func get_parry_frames() -> int:
	return _current_parry_frames
