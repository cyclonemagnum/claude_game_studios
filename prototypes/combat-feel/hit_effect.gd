# PROTOTYPE - NOT FOR PRODUCTION
extends Node2D

## Hit effect spawner — expanding circles and flashes.

const BASE_DURATION: float = 0.3
const IAI_FLASH_DURATION: float = 0.4


func spawn_hit(pos: Vector2, damage: int) -> void:
	var color := _damage_color(damage)
	_spawn_ring(pos, color, 20.0, 60.0, BASE_DURATION)


func spawn_iai_success(pos: Vector2) -> void:
	# Blue-white ring at hit point
	_spawn_ring(pos, Color(0.4, 0.8, 1.0), 30.0, 120.0, 0.5)
	# Screen-edge flash
	_spawn_screen_flash(Color(0.3, 0.7, 1.0, 0.5), IAI_FLASH_DURATION)


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
