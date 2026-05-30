# PROTOTYPE - Run / Roguelite state
extends Node

## Run 状态: 已收集卡片 + 应用到玩家/武器的实时修改
## 直接修改 player/long_sword/great_sword 的 var 字段

const Cards = preload("res://cards.gd")

var collected_card_ids: Array[String] = []
var wave_index: int = 0

# 机制卡查询缓存 — 武器代码每帧问"我有这张卡吗"
var has_afterbreath: bool = false
var has_resonance: bool = false
var has_demonform: bool = false


func reset() -> void:
	collected_card_ids.clear()
	wave_index = 0
	has_afterbreath = false
	has_resonance = false
	has_demonform = false


func add_card(card_id: String, player: Node, ls: Node, gs: Node) -> void:
	if card_id in collected_card_ids:
		return
	collected_card_ids.append(card_id)
	_apply_card(card_id, player, ls, gs)


func _apply_card(card_id: String, player: Node, ls: Node, _gs: Node) -> void:
	match card_id:
		"sharp":
			# 太刀普攻 +25%
			ls.combo_damage_mult *= 1.25
			print("CARD: 锋利 应用, 太刀普攻倍率 = %.2f" % ls.combo_damage_mult)
		"stamina":
			# 最大HP +30 并回满
			player.MAX_HP_BONUS += 30
			player.heal_full()
			print("CARD: 持久 应用, 最大HP = %d" % player.get_effective_max_hp())
		"afterbreath":
			has_afterbreath = true
			print("CARD: 残气 激活")
		"resonance":
			has_resonance = true
			print("CARD: 共鸣 激活")
		"demonform":
			has_demonform = true
			# HP上限砍到 70%
			player.MAX_HP_MULT *= 0.7
			# Cap current HP at new max
			var new_max: int = player.get_effective_max_hp()
			if player._hp > new_max:
				player._hp = new_max
				player.health_changed.emit(player._hp, new_max)
			print("CARD: 鬼神化 激活, 最大HP = %d" % player.get_effective_max_hp())


func has_card(card_id: String) -> bool:
	return card_id in collected_card_ids
