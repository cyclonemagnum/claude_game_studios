# PROTOTYPE - SFX manager (autoload-style, attached to main scene)
extends Node

## 简易音效管理器: 池化 AudioStreamPlayer, 通过 id 播放
## 用法: Sfx.play("hit_light")

const SFX_FILES: Dictionary = {
	"hit_light": "res://sfx/hit_light.wav",
	"hit_heavy": "res://sfx/hit_heavy.wav",
	"whoosh": "res://sfx/whoosh.wav",
	"dodge": "res://sfx/dodge.wav",
	"stance": "res://sfx/stance.wav",
	"iai_success": "res://sfx/iai_success.wav",
	"toryu_launch": "res://sfx/toryu_launch.wav",
	"toryu_impact": "res://sfx/toryu_impact.wav",
	"player_hurt": "res://sfx/player_hurt.wav",
	"telegraph": "res://sfx/telegraph.wav",
	"charge_up": "res://sfx/charge_up.wav",
	"card_pick": "res://sfx/card_pick.wav",
	"boss_defeated": "res://sfx/boss_defeated.wav",
}

const POOL_SIZE: int = 12

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0
var _master_volume_db: float = -4.0


func _ready() -> void:
	# 加载所有音频
	for id in SFX_FILES:
		var path: String = SFX_FILES[id]
		var stream: AudioStream = load(path) as AudioStream
		if stream:
			_streams[id] = stream
		else:
			print("WARN: Failed to load SFX: ", path)

	# 池化播放器
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		p.volume_db = _master_volume_db
		add_child(p)
		_players.append(p)


func play(id: String, pitch: float = 1.0, volume_db_offset: float = 0.0) -> void:
	if not id in _streams:
		return
	var p: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	p.stream = _streams[id]
	p.pitch_scale = pitch
	p.volume_db = _master_volume_db + volume_db_offset
	p.play()


func play_random_pitch(id: String, low: float = 0.92, high: float = 1.08) -> void:
	play(id, randf_range(low, high))
