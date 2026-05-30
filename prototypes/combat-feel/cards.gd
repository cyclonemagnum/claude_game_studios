# PROTOTYPE - Roguelite Cards
extends Node

## 卷轴卡定义 — 3 类: 属性/机制/破坏
## 数据驱动: 每张卡描述自己, 由 Run 系统在选中时调用 apply()
## 使用 callable 而非硬编码 if/else 是为了后续好扩展

enum CardType { ATTRIBUTE, MECHANIC, BREAK }

const CARD_TYPE_NAMES: Array[String] = ["属性", "机制", "破坏"]
const CARD_TYPE_COLORS: Array[Color] = [
	Color(0.55, 0.85, 1.00),   # 蓝 — 属性
	Color(0.95, 0.75, 0.30),   # 金 — 机制
	Color(1.00, 0.40, 0.50),   # 红粉 — 破坏
]

# 卡库 — 每张卡是一个 Dictionary
const CARDS: Array[Dictionary] = [
	{
		"id": "sharp",
		"name": "锋利",
		"type": CardType.ATTRIBUTE,
		"desc": "太刀普攻伤害 +25%",
		"detail": "稳健的强化, 让连段更具威胁",
	},
	{
		"id": "stamina",
		"name": "持久",
		"type": CardType.ATTRIBUTE,
		"desc": "最大HP +30 (并立即回满)",
		"detail": "更多容错空间",
	},
	{
		"id": "afterbreath",
		"name": "残气",
		"type": CardType.MECHANIC,
		"desc": "闪避后 0.4s 内, 普攻伤害 +50%",
		"detail": "鼓励'闪避→反击'的高风险走位",
	},
	{
		"id": "resonance",
		"name": "共鸣",
		"type": CardType.MECHANIC,
		"desc": "大居合命中时, 周围范围内敌人受到 60% 伤害",
		"detail": "把'1对1见切'扩展为AOE",
	},
	{
		"id": "demonform",
		"name": "鬼神化",
		"type": CardType.BREAK,
		"desc": "受击不掉气, 但HP上限 -30%",
		"detail": "邪道build: 用脆皮换无尽气槽",
	},
]


static func get_card_by_id(card_id: String) -> Dictionary:
	for card in CARDS:
		if card["id"] == card_id:
			return card
	return {}


static func get_random_choices(count: int, exclude_ids: Array[String] = []) -> Array[Dictionary]:
	# 平衡型权重: 早期偏属性, 后期偏机制/破坏
	# 这版本简化: 随机不重复抽取
	var pool: Array[Dictionary] = []
	for card in CARDS:
		if card["id"] in exclude_ids:
			continue
		pool.append(card)
	pool.shuffle()
	var result: Array[Dictionary] = []
	for i in range(min(count, pool.size())):
		result.append(pool[i])
	return result


static func get_type_color(type: int) -> Color:
	if type < 0 or type >= CARD_TYPE_COLORS.size():
		return Color.WHITE
	return CARD_TYPE_COLORS[type]


static func get_type_name(type: int) -> String:
	if type < 0 or type >= CARD_TYPE_NAMES.size():
		return "?"
	return CARD_TYPE_NAMES[type]
