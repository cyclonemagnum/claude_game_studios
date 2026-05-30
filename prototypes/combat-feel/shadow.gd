# PROTOTYPE - Simple ground shadow that draws a circle
extends Node2D

var radius: float = 24.0
var alpha: float = 0.0


func set_alpha(a: float) -> void:
	alpha = clampf(a, 0.0, 1.0)
	queue_redraw()


func set_radius(r: float) -> void:
	radius = max(0.0, r)
	queue_redraw()


func _draw() -> void:
	if alpha <= 0.001:
		return
	# 椭圆阴影 — 横扁更像投影
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, alpha * 0.55))
