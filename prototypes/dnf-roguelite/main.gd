# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## Main scene — 组装所有系统: 玩家, 关卡管理, 商店, HUD
## DNF风格2.5D竞技场 + 肉鸽关卡循环

var _player: Node2D = null
var _hud: CanvasLayer = null
var _shop: CanvasLayer = null
var _room_manager: Node2D = null
var _arena_bg: Node2D = null
var _camera: Camera2D = null

var _result_label: Label = null


func _ready() -> void:
	_build_arena()
	_setup_camera()
	_spawn_player()
	_setup_hud()
	_setup_shop()
	_setup_room_manager()
	_show_result_label()


func _build_arena() -> void:
	_arena_bg = Node2D.new()
	add_child(_arena_bg)

	# Ground plane (DNF style — flat ground with some Z depth)
	var ground := ColorRect.new()
	ground.size = Vector2(1400, 250)
	ground.position = Vector2(-700, -125)
	ground.color = Color(0.15, 0.15, 0.2)
	_arena_bg.add_child(ground)

	# Ground lines to show Z-depth
	for i in range(6):
		var line := ColorRect.new()
		line.size = Vector2(1400, 1)
		line.position = Vector2(-700, -100 + i * 40)
		line.color = Color(0.25, 0.25, 0.3, 0.5)
		_arena_bg.add_child(line)

	# Arena borders (left/right walls)
	var wall_l := ColorRect.new()
	wall_l.size = Vector2(8, 280)
	wall_l.position = Vector2(-704, -140)
	wall_l.color = Color(0.4, 0.3, 0.2)
	_arena_bg.add_child(wall_l)

	var wall_r := ColorRect.new()
	wall_r.size = Vector2(8, 280)
	wall_r.position = Vector2(696, -140)
	wall_r.color = Color(0.4, 0.3, 0.2)
	_arena_bg.add_child(wall_r)


func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.3, 1.3)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 5.0
	add_child(_camera)
	_camera.make_current()


func _spawn_player() -> void:
	_player = Node2D.new()
	_player.set_script(preload("res://player.gd"))
	add_child(_player)
	_player.ground_x = -300.0
	_player.ground_z = 0.0
	_player.arena_min_x = -650.0
	_player.arena_max_x = 650.0
	_player.arena_min_z = -100.0
	_player.arena_max_z = 100.0


func _setup_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.set_script(preload("res://hud.gd"))
	add_child(_hud)
	# Wait a frame for _ready
	_hud.call_deferred("set_player", _player)


func _setup_shop() -> void:
	_shop = CanvasLayer.new()
	_shop.set_script(preload("res://shop_ui.gd"))
	_shop.layer = 5
	add_child(_shop)
	_shop.shop_closed.connect(_on_shop_closed)


func _setup_room_manager() -> void:
	_room_manager = Node2D.new()
	_room_manager.set_script(preload("res://room_manager.gd"))
	add_child(_room_manager)
	_room_manager.setup(_player, _hud, _shop)
	_room_manager.room_cleared.connect(_on_room_cleared)
	_room_manager.run_complete.connect(_on_run_complete)
	_room_manager.run_failed.connect(_on_run_failed)


func _show_result_label() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	_result_label = Label.new()
	_result_label.position = Vector2(660, 450)
	_result_label.size = Vector2(600, 100)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_font_size_override("font_size", 48)
	_result_label.visible = false
	canvas.add_child(_result_label)


func _physics_process(delta: float) -> void:
	# Camera follows player
	if _player:
		_camera.position = _camera.position.lerp(
			Vector2(_player.ground_x * 0.5, 0), delta * 3.0
		)

	if Input.is_action_just_pressed("restart"):
		_restart()


func _on_room_cleared() -> void:
	print("ROOM CLEARED!")


func _on_shop_closed() -> void:
	_room_manager.shop_closed()


func _on_run_complete() -> void:
	_result_label.text = "🎉 通关! 按R重开 🎉"
	_result_label.visible = true
	_result_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))


func _on_run_failed() -> void:
	_result_label.text = "💀 失败... 按R重开 💀"
	_result_label.visible = true
	_result_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))


func _restart() -> void:
	get_tree().reload_current_scene()
