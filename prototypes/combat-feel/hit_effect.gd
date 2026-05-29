# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D

## Hit effect spawner — expanding circles, sparks, damage numbers, screen flash.

const BASE_DURATION: float = 0.3
const IAI_FLASH_DURATION: float = 0.4
const SPARK_COUNT: int = 8
const SPARK_LIFETIME: float = 0.35
const SPARK_SPEED_MIN: float = 280.0
const SPARK_SPEED_MAX: float = 520.0
const DAMAGE_NUMBER_LIFETIME: float = 0.7
const DAMAGE_NUMBER_RISE: float = 50.0


func spawn_hit(pos: Vector2, damage: int) -> void:
	var color := _damage_color(damage)
	_spawn_ring(pos, color, 20.0, 60.0, BASE_DURATION)
	_spawn_sparks(pos, color, damage)
	_spawn_damage_number(pos, damage, color)


func spawn_iai_success(pos: Vector2) -> void:
	# Blue-white ring at hit point
	_spawn_ring(pos, Color(0.4, 0.8, 1.0), 30.0, 120.0, 0.5)
	_spawn_ring(pos, Color(1, 1, 1), 10.0, 80.0, 0.3)
	# Screen-edge flash
	_spawn_screen_flash(Color(0.3, 0.7, 1.0, 0.5), IAI_FLASH_DURATION)
	# Burst sparks
	var burst_color := Color(0.5, 0.85, 1.0)
	for i in range(16):
		var angle: float = randf() * TAU
		var speed: float = randf_range(400.0, 700.0)
		var vel := Vector2.RIGHT.rotated(angle) * speed
		_spawn_single_spark(pos, vel, burst_color, 0.45)


func _damage_color(damage: int) -> Color:
	if damage < 15:
		return Color.WHITE
	elif damage < 30:
		return Color.YELLOW
	elif damage < 60:
		return Color(1.0, 0.5, 0.0)
	else:
		return Color.RED


func _spawn_ring(pos: Vector2, color: Color, start_radius: float, end_radius: float, duration: float) -> void:
	var ring := _RingEffect.new(pos, color, start_radius, end_radius, duration)
	add_child(ring)


func _spawn_screen_flash(color: Color, duration: float) -> void:
	var vp_size := get_viewport_rect().size
	var flash := ColorRect.new()
	flash.color = color
	flash.size = vp_size
	flash.position = Vector2.ZERO
	# Put in canvas layer so it covers everything
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(flash)
	get_tree().current_scene.add_child(canvas)

	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, duration)
	tween.tween_callback(canvas.queue_free)


func _spawn_sparks(pos: Vector2, color: Color, damage: int) -> void:
	var count: int = SPARK_COUNT
	if damage >= 60:
		count = 14
	elif damage >= 30:
		count = 11
	for i in range(count):
		var angle: float = randf() * TAU
		var speed: float = randf_range(SPARK_SPEED_MIN, SPARK_SPEED_MAX)
		var vel := Vector2.RIGHT.rotated(angle) * speed
		_spawn_single_spark(pos, vel, color, SPARK_LIFETIME)


func _spawn_single_spark(pos: Vector2, velocity: Vector2, color: Color, lifetime: float) -> void:
	var spark := _SparkEffect.new(pos, velocity, color, lifetime)
	add_child(spark)


func _spawn_damage_number(pos: Vector2, damage: int, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = str(damage)
	lbl.add_theme_font_size_override("font_size", 20 + min(damage / 5, 28))
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.position = pos + Vector2(randf_range(-20, 20), -20)
	lbl.z_index = 100
	add_child(lbl)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - DAMAGE_NUMBER_RISE, DAMAGE_NUMBER_LIFETIME).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, DAMAGE_NUMBER_LIFETIME).set_delay(0.3)
	tween.chain().tween_callback(lbl.queue_free)


# Inner class for ring drawing
class _RingEffect extends Node2D:
	var _color: Color
	var _start_radius: float
	var _end_radius: float
	var _duration: float
	var _elapsed: float = 0.0
	var _current_radius: float

	func _init(pos: Vector2, color: Color, start_r: float, end_r: float, dur: float) -> void:
		global_position = pos
		_color = color
		_start_radius = start_r
		_end_radius = end_r
		_duration = dur
		_current_radius = start_r

	func _process(delta: float) -> void:
		_elapsed += delta
		var t: float = _elapsed / _duration
		if t >= 1.0:
			queue_free()
			return
		_current_radius = lerpf(_start_radius, _end_radius, t)
		modulate.a = 1.0 - t
		queue_redraw()

	func _draw() -> void:
		draw_arc(Vector2.ZERO, _current_radius, 0.0, TAU, 32, _color, 3.0)


# Inner class for flying sparks
class _SparkEffect extends Node2D:
	var _vel: Vector2
	var _color: Color
	var _life: float
	var _elapsed: float = 0.0
	var _length: float = 12.0

	func _init(pos: Vector2, vel: Vector2, color: Color, life: float) -> void:
		global_position = pos
		_vel = vel
		_color = color
		_life = life
		z_index = 5

	func _process(delta: float) -> void:
		_elapsed += delta
		var t: float = _elapsed / _life
		if t >= 1.0:
			queue_free()
			return
		# Decelerate
		_vel *= pow(0.05, delta)
		global_position += _vel * delta
		modulate.a = 1.0 - t
		queue_redraw()

	func _draw() -> void:
		var dir: Vector2 = _vel.normalized() * _length
		draw_line(-dir * 0.5, dir * 0.5, _color, 3.0)
