# PROTOTYPE - 剑光拖尾系统
extends Line2D

## 跟随武器剑尖, 留下渐隐拖尾.
## 主动攻击/闪避/招式时高亮, 平时半透明甚至隐藏.
## 用 top_level = true 使其在世界空间绘制, 不受 player rotation 影响.

const MAX_POINTS: int = 14            # 拖尾节数
const SAMPLE_INTERVAL: float = 0.012  # 采样间隔, 越小越平滑
const POINT_LIFETIME: float = 0.18    # 每个点存活时间

# 武器尖端相对玩家的本地偏移 (剑刃右端)
const TIP_LOCAL_OFFSET: Vector2 = Vector2(78, 0)

var _player: Node2D = null
var _samples: Array[Dictionary] = []   # {pos: Vector2, age: float}
var _sample_timer: float = 0.0
var _highlight_alpha: float = 0.0      # 0~1, 攻击时拉高
var _highlight_color: Color = Color(1, 1, 1, 1)


func _ready() -> void:
	top_level = true                    # 不继承 player 旋转
	width = 4.0
	default_color = Color(1, 1, 1, 0)
	z_index = 5
	# Width curve: 头部宽, 尾部窄
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1, 0.1))
	width_curve = curve


func set_player(p: Node2D) -> void:
	_player = p


func set_highlight(level: float, color: Color = Color.WHITE) -> void:
	_highlight_alpha = clampf(level, 0.0, 1.0)
	_highlight_color = color


func _physics_process(delta: float) -> void:
	if _player == null:
		clear_points()
		return

	# 采样剑尖位置
	_sample_timer -= delta
	if _sample_timer <= 0.0:
		_sample_timer = SAMPLE_INTERVAL
		var tip_global: Vector2 = _player.global_position + TIP_LOCAL_OFFSET.rotated(_player.rotation)
		_samples.append({"pos": tip_global, "age": 0.0})
		if _samples.size() > MAX_POINTS:
			_samples.pop_front()

	# 衰老 + 移除
	var keep: Array[Dictionary] = []
	for s in _samples:
		s["age"] += delta
		if s["age"] < POINT_LIFETIME:
			keep.append(s)
	_samples = keep

	# 重建 Line2D 点
	clear_points()
	if _samples.size() < 2 or _highlight_alpha < 0.05:
		return
	for s in _samples:
		add_point(s["pos"])

	# 渐隐: modulate 整条线
	default_color = Color(_highlight_color.r, _highlight_color.g, _highlight_color.b, _highlight_alpha)
