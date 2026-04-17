# PROTOTYPE - NOT FOR PRODUCTION
extends Camera2D

## Camera with screen shake and hit freeze support.

const FOLLOW_SPEED: float = 8.0
const SHAKE_DECAY: float = 5.0

var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _target: Node2D = null

# Hit freeze
var _freeze_duration: float = 0.0
var _is_frozen: bool = false


func _ready() -> void:
	position_smoothing_enabled = false


func set_target(target: Node2D) -> void:
	_target = target


func shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration


func hit_freeze(duration: float) -> void:
	if _is_frozen:
		return
	_is_frozen = true
	_freeze_duration = duration
	Engine.time_scale = 0.0
	# Use a real-time timer to unfreeze
	var timer := get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(_unfreeze)


func _unfreeze() -> void:
	Engine.time_scale = 1.0
	_is_frozen = false


func _process(delta: float) -> void:
	if _target:
		global_position = global_position.lerp(_target.global_position, FOLLOW_SPEED * delta)

	if _shake_timer > 0.0:
		_shake_timer -= delta
		var ratio: float = _shake_timer / _shake_duration
		var current_intensity: float = _shake_intensity * ratio
		offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
	else:
		offset = Vector2.ZERO
