# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D

## Main scene — combat arena. Spawns player and boss, wires everything together.

var _player: CharacterBody2D = null
var _boss: CharacterBody2D = null
var _camera: Camera2D = null
var _hud: CanvasLayer = null
var _hit_effects: Node2D = null

var _frame_count: int = 0


func _ready() -> void:
	_player = $Player
	_boss = $Boss
	_camera = $Camera2D
	_hud = $HUD
	_hit_effects = $HitEffects

	# Wire camera
	_camera.set_target(_player)

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

	# Connect signals
	_player.health_changed.connect(_on_player_health_changed)
	_player.weapon_switched.connect(_on_weapon_switched)
	_player.died.connect(_on_player_died)

	_boss.health_changed.connect(_on_boss_health_changed)
	_boss.defeated.connect(_on_boss_defeated)

	var ls := _player.get_long_sword()
	ls.spirit_changed.connect(_hud.set_spirit)
	ls.spirit_level_changed.connect(_hud.set_spirit_level)
	ls.iai_success.connect(_on_iai_success)

	var gs := _player.get_great_sword()
	gs.charge_level_changed.connect(_hud.set_charge_level)

	# HUD parry window changes → long sword
	_hud.parry_window_changed.connect(_on_parry_window_changed)
	# Sync initial value
	ls.iai_window_frames = _hud.get_parry_frames()


func _physics_process(delta: float) -> void:
	_frame_count += 1

	if Input.is_action_just_pressed("restart"):
		_restart()

	# Update debug label
	var ls := _player.get_long_sword()
	var debug := "Frame: %d  |  Spirit: %d  |  Iai active: %s  |  Press [/] to change parry window" % [
		_frame_count,
		ls.get_spirit(),
		str(ls.is_iai_active())
	]
	_hud.update_debug(debug)


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


func _on_iai_success(frame_hit: int, window: int) -> void:
	_hud.flash_iai_success()


func _on_parry_window_changed(new_frames: int) -> void:
	_player.get_long_sword().iai_window_frames = new_frames
	print("Parry window set to %d frames (%.0fms)" % [new_frames, new_frames * (1000.0 / 60.0)])


func _restart() -> void:
	print("--- RESTARTING ---")
	get_tree().reload_current_scene()
