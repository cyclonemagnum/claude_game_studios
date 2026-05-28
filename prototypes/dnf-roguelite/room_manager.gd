# PROTOTYPE - DNF 2.5D + Roguelite
extends Node2D

## 关卡管理器 — 3关: 杂兵1 → 商店 → 杂兵2 → 商店 → Boss
## 肉鸽元素: 关卡间商店可选择强化

signal room_cleared()
signal run_complete()
signal run_failed()

enum RoomType { MOB, SHOP, BOSS }
enum RunState { PLAYING, SHOP, VICTORY, DEFEAT }

const ROOMS: Array[Dictionary] = [
	{"type": "mob", "enemy_count": 4, "title": "第一关 — 杂兵"},
	{"type": "shop", "title": "商店 — 选择强化"},
	{"type": "mob", "enemy_count": 6, "title": "第二关 — 杂兵"},
	{"type": "shop", "title": "商店 — 选择强化"},
	{"type": "boss", "title": "第三关 — Boss"},
]

var _current_room: int = 0
var _run_state: RunState = RunState.PLAYING
var _enemies_alive: int = 0
var _player: Node2D = null
var _hud: CanvasLayer = null
var _shop_ui: CanvasLayer = null
var _enemies: Array[Node2D] = []

# Enemy scene (we build dynamically)
var _enemy_script: GDScript = preload("res://enemy_mob.gd")
var _boss_script: GDScript = preload("res://boss.gd")


func _ready() -> void:
	pass


func setup(player: Node2D, hud: CanvasLayer, shop: CanvasLayer) -> void:
	_player = player
	_hud = hud
	_shop_ui = shop
	_player.died.connect(_on_player_died)
	_start_room()


func _start_room() -> void:
	var room: Dictionary = ROOMS[_current_room]

	if _hud.has_method("set_room_title"):
		_hud.set_room_title(room["title"])

	match room["type"]:
		"mob":
			_spawn_mob_room(room["enemy_count"])
		"shop":
			_open_shop()
		"boss":
			_spawn_boss_room()


func _spawn_mob_room(count: int) -> void:
	_run_state = RunState.PLAYING
	_enemies.clear()
	_enemies_alive = count

	for i in range(count):
		var enemy: Node2D = Node2D.new()
		enemy.set_script(_enemy_script)
		add_child(enemy)

		# Spread enemies across arena
		var spawn_x: float = randf_range(200.0, 500.0) * (1 if randf() > 0.5 else -1)
		var spawn_z: float = randf_range(-80.0, 80.0)
		enemy.setup(spawn_x, spawn_z, 30 + _current_room * 10)
		enemy.set_player(_player)
		enemy.enemy_died.connect(_on_enemy_died)
		_enemies.append(enemy)


func _spawn_boss_room() -> void:
	_run_state = RunState.PLAYING
	_enemies.clear()
	_enemies_alive = 1

	var boss: Node2D = Node2D.new()
	boss.set_script(_boss_script)
	add_child(boss)
	boss.setup(400.0, 0.0, 200)
	boss.set_player(_player)
	boss.enemy_died.connect(_on_enemy_died)
	_enemies.append(boss)


func _open_shop() -> void:
	_run_state = RunState.SHOP
	if _shop_ui:
		_shop_ui.visible = true
		_shop_ui.open_shop(_player)


func shop_closed() -> void:
	_run_state = RunState.PLAYING
	_current_room += 1
	_start_room()


func _on_enemy_died(_enemy: Node2D) -> void:
	_enemies_alive -= 1
	if _enemies_alive <= 0:
		_on_room_cleared()


func _on_room_cleared() -> void:
	room_cleared.emit()
	# Wait a moment then advance
	var timer: SceneTreeTimer = get_tree().create_timer(1.0)
	timer.timeout.connect(_advance_room)


func _advance_room() -> void:
	_current_room += 1
	if _current_room >= ROOMS.size():
		_run_state = RunState.VICTORY
		run_complete.emit()
		return
	_start_room()


func _on_player_died() -> void:
	_run_state = RunState.DEFEAT
	run_failed.emit()


func get_current_room_index() -> int:
	return _current_room


func get_run_state() -> RunState:
	return _run_state


func restart_run() -> void:
	# Clean up enemies
	for enemy in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()
	_current_room = 0
	_run_state = RunState.PLAYING
	_player.reset_hp()
	_start_room()
