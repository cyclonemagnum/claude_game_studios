# Game Concept: Tide Hunter (猎潮)

*Created: 2026-04-17*
*Status: Draft*

---

## Elevator Pitch

> 一款以 Boss 战为核心的俯视角动作 Roguelite——没有怪海，每一波都是一场真正的狩猎。选择大剑或太刀两种截然不同的流派，读懂 Boss 的行为模式，用预判或反应惩罚每一个破绽。怪物猎人的狩猎哲学，装在 Brotato 的快节奏单局里。

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | 动作 Roguelite / Boss Rush |
| **Platform** | PC (Steam) |
| **Target Audience** | 动作游戏爱好者，追求技术成长的中核-硬核玩家 |
| **Player Count** | 单人 |
| **Session Length** | 20-30 分钟 |
| **Monetization** | 买断制，50 元人民币以内 |
| **Estimated Scope** | 中型（4-5 个月，solo 开发） |
| **Comparable Titles** | Brotato, Hades, Furi |

---

## Core Fantasy

你不是一个在怪潮中苟延残喘的幸存者——你是一个**猎人**。每一个 Boss 都是一头有智慧、有模式、有弱点的猎物。你通过观察、试错、理解来征服它们。每一次讨伐都不是数值碾压，而是你的技术和认知的胜利。

大剑在手，你是一个**预言者**——在 Boss 出招之前就站在了正确的位置，满蓄一击如同宣判。

太刀出鞘，你是一个**对弈者**——贴身缠斗、见招拆招，用完美时机的见切把敌人的攻势变成自己的伤害。

---

## Unique Hook

像 Brotato 一样快节奏的 Roguelite 单局，**但也**每个敌人都是一场有独特行为模式和破绽窗口的真正 Boss 战——你需要像怪物猎人一样"学习"每个对手，而不是无脑清屏。

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 2 | 满蓄命中的屏幕震动和时间冻结、见切成功的刀光闪烁和音效反馈 |
| **Fantasy** (make-believe) | 3 | "我是一个读懂怪物的猎人"——每次讨伐都是智慧与技术的胜利 |
| **Narrative** (drama) | 6 | 碎片化世界观通过 Boss 图鉴和环境叙事传达，不强制 |
| **Challenge** (mastery) | 1 | Boss 三阶段设计、帧精确的反击窗口、逐步升级的行为模式 |
| **Fellowship** (social) | N/A | 单人游戏，社区互动通过构建分享和录像 |
| **Discovery** (exploration) | 4 | 每个 Boss 的隐藏规律、强化词条之间的协同效应、新流派的发现 |
| **Expression** (self-expression) | 5 | 大剑vs太刀流派选择、构建路线自由度、同一 Boss 多种攻略方式 |
| **Submission** (relaxation) | N/A | 不提供低压力的放松体验——每一秒都需要注意力 |

### Key Dynamics (Emergent player behaviors)

- 玩家会自然地开始"背招"——记忆每个 Boss 的攻击前摇和安全惩罚窗口
- 玩家会围绕自己的流派探索不同的强化构建路线
- 玩家会在社区中分享"完美讨伐"录像和独特构建
- 玩家会在第二流派体验到"同一个Boss完全不同的攻略方式"的新鲜感

### Core Mechanics (Systems we build)

1. **双流派战斗系统**——大剑（预判蓄力）和太刀（见切反击）各有独立的操作逻辑和成长曲线
2. **Boss 行为模式系统**——每个 Boss 有 3 阶段、5-8 个招式、明确的前摇和破绽窗口
3. **Roguelite 构建系统**——每次讨伐后三选一强化，改变博弈方式而非单纯提升数值
4. **永久解锁系统**——跨 Run 解锁新词条进入奖池，拓宽选择面不提升数值天花板

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | 双流派选择 + 每次强化都是有意义的策略决策 + Boss 攻略方式自由 | Core |
| **Competence** (mastery, skill growth) | 从"看不懂招式"到"无伤讨伐"的清晰成长弧 + 见切/蓄力的操作精度反馈 | Core |
| **Relatedness** (connection, belonging) | Boss 图鉴记录狩猎历史 + 成就系统 + 社区分享构建和录像 | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — 全 Boss 讨伐、无伤挑战、词条全收集、挑战模式全清
- [x] **Explorers** (discovery, understanding systems) — 发现 Boss 隐藏招式规律、寻找最优构建、发掘 synergy 组合
- [ ] **Socializers** (relationships, cooperation) — 单人为主，通过社区间接满足
- [ ] **Killers/Competitors** (domination, PvP) — 速通排行榜和挑战模式提供竞争舞台

### Flow State Design

- **Onboarding curve**: 第一个 Boss 就是教学——招式慢、破绽大、容错高。通过玩来学，不通过读来学
- **Difficulty scaling**: Boss 序列逐步引入新机制，每个 Boss 都在前一个的基础上增加一层复杂度
- **Feedback clarity**: 满蓄命中/见切成功有强烈视听反馈；Boss 受伤有明确阶段转换动画
- **Recovery from failure**: 单局 20-30 分钟，失败成本低；每次失败都能学到 Boss 的新招式规律

---

## Core Loop

### Moment-to-Moment (30 seconds)

**大剑**：观察 Boss 动作 → 预判破绽窗口 → 提前站位蓄力 → 满蓄重击命中 → 巨额伤害 + 屏幕震动 → 脱离 → 回到观察

**太刀**：贴身轻攻积攒气槽 → Boss 攻击 → 见切弹反 → 气槽升阶 → 连斩加速 → 气槽满 → 居合终结技 → 重新积攒

### Short-Term (5 minutes — 一场 Boss 战)

Boss 登场（展示名字 + 威胁动作）→ Phase 1 学习期（基础招式，破绽明显）→ Phase 2 压力期（加速+新招，破绽缩短）→ Phase 3 狂暴期（最强连招，但露出最大破绽）→ 讨伐完成 → 素材掉落 → 强化选择（三选一）

### Session-Level (20-30 minutes — 一次 Run)

选择流派（大剑 or 太刀）→ Boss 1（入门）→ 强化 → Boss 2（引入新机制）→ 强化 → Boss 3-4（难度爬升）→ ... → Boss 6-8（最终 Boss，综合考验）→ 通关结算 → 永久解锁

### Long-Term Progression

永久解锁拓宽选择面，不提升数值天花板：新强化词条进入奖池、新 Boss 解锁、新流派变体解锁（后续更新）。第 1 次通关和第 100 次通关，Boss 难度不变——变的是你的技术和构建理解。

### Retention Hooks

- **Curiosity**: "那个 Boss 第三阶段到底怎么打？" / "这两个词条叠在一起会怎样？"
- **Investment**: 从被 Boss 3 虐杀到无伤通关的成长记录
- **Social**: 社区分享完美讨伐录像和独特构建
- **Mastery**: 全 Boss 无伤、速通挑战、限制条件挑战

---

## Game Pillars

### Pillar 1: 每一战都是一场对话
Boss 不是血条——是有行为逻辑的对手。战斗深度来自认知成长，不是数值碾压。

*Design test*: 纠结"加更多血量还是加新招式"时，**加新招式**。血量只是拖时间，新招式才是新的对话。

### Pillar 2: 出手即承诺
每一次攻击都有后果——大剑的蓄力让你赌上站位和时间，太刀的见切让你赌上受击风险。没有无脑输出，没有安全的 spam。每一刀都是一个决策。

*Design test*: 纠结"要不要加无后摇的安全小攻击"时，**不加**。如果一个动作没有风险，它就没有意义。

### Pillar 3: 易学难精，两分钟入门两百小时精通
新手第一局就能理解"闪避→攻击→闪避"的基本循环，但完美蓄力时机、见切帧窗口、构建协同效应的天花板极高。上手零门槛，精通无止境。

*Design test*: 纠结"需不需要强制教学关"时，**不要**——第一个 Boss 本身就是教学。它的招式慢、破绽大、容错高。玩家通过玩来学，不是通过读来学。

### Pillar 4: 构建改变博弈方式，不改变数值天花板
每次强化选择应该改变你和 Boss 的交互方式，不只是让数字变大。好的构建让你用不同的策略打同一个 Boss，而不是让 Boss 变得无关紧要。

*Design test*: 纠结"+30%攻击力还是命中后标记弱点"时，**标记弱点**。前者只是快了，后者改变了你的打法。

### Anti-Pillars (What This Game Is NOT)

- **NOT 数值碾压游戏**：永远不会出现"刷够了就能无脑过"的状态。永久进阶解锁选项，不提升数值。会破坏支柱 1 和 2。
- **NOT 怪海清屏幸存者**：没有满屏小怪、没有自动攻击、没有"站着就能赢"。每个敌人都值得认真对待。会破坏支柱 2。
- **NOT 叙事驱动游戏**：有世界观、有氛围、有碎片化叙事——但玩家永远不会被迫看剧情。故事是发现的奖励，不是推进的门槛。保护支柱 3 的上手零门槛。

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Brotato | 短单局 Roguelite 循环、构建多样性、"再来一把"节奏 | Boss 战替代怪海，操作深度替代自动射击 | 验证了短单局 Roguelite 的市场潜力 |
| Monster Hunter (Rise/Wilds) | 武器承诺感、读怪哲学、讨伐→制作循环 | 压缩到 20 分钟单局，去掉准备/探索阶段 | 验证了"学习怪物"是一种持久的核心乐趣 |
| Hades | 动作 Roguelite + Boss 战、叙事融入重复游玩 | 纯 Boss Rush（无普通战斗房）、双流派博弈深度 | 验证了动作 Roguelite 可以达到年度最佳级别 |
| Furi | 纯 Boss Rush、高精度操控、每个 Boss 是独特谜题 | 加入 Roguelite 构建层、多流派选择 | 验证了纯 Boss Rush 品类有受众 |
| Celeste | 帧级精确操控、失败是学习、手感打磨 | 战斗而非平台跳跃，构建系统增加策略维度 | 验证了"精确操控+高难度+低定价"的商业模式 |

**Non-game inspirations**: 武士电影的"一刀定胜负"张力（黑泽明《七武士》《用心棒》）；怪物生态纪录片中"捕食者等待时机"的耐心与爆发；中国武侠"以静制动、后发先至"的哲学。

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-35 |
| **Gaming experience** | 中核-硬核，有动作游戏经验 |
| **Time availability** | 碎片时间 20-30 分钟，周末可更长 |
| **Platform preference** | PC (Steam) |
| **Current games they play** | Brotato, Hades, Monster Hunter, Elden Ring, Celeste |
| **What they're looking for** | "像 Brotato 一样快但像怪猎一样有深度"的体验 |
| **What would turn them away** | 无脑刷怪、数值碾压、自动战斗、强制剧情 |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Engine** | Godot 4.6 (GDScript) |
| **Key Technical Challenges** | Boss AI 状态机复杂度、帧精确输入检测（见切 6-10 帧窗口）、hitbox/hurtbox 系统 |
| **Art Style** | 待定（建议简约风格，优先动作可读性——由 /art-bible 决定） |
| **Art Pipeline Complexity** | 中（2D 动画 Boss + 特效） |
| **Audio Needs** | 中（Boss 招式音效是读招的关键信息源 + 满蓄/见切的反馈音效极重要） |
| **Networking** | 无 |
| **Content Volume** | MVP: 5 Boss x 3 阶段 + 25 词条; 完整版: 15+ Boss + 100 词条 |
| **Procedural Systems** | Boss 出场顺序可随机、强化词条随机三选一、Boss 招式组合可有随机变体 |

---

## Risks and Open Questions

### Design Risks
- Boss AI 行为模式设计极度耗时——每个 Boss 需 3 阶段 x 5-8 招式的手工设计和调试
- 大剑蓄力/太刀见切的帧级手感需要大量 playtest 迭代才能"感觉对"

### Technical Risks
- Godot 4.6 的输入延迟能否支撑帧精确的见切窗口（需要早期原型验证）
- 复杂 Boss AI 状态机的可维护性（需要良好的架构设计）

### Market Risks
- Roguelite 在 Steam 上极度拥挤——需要通过 Boss Rush 卖点和美术差异化突围
- "纯 Boss Rush"可能让偏休闲的 Brotato 玩家觉得太硬核

### Scope Risks
- 8 个高质量 Boss 在 3-6 个月内对 solo 开发者是巨大挑战
- 两个流派都需要独立打磨手感，工作量接近做两个游戏的战斗系统

### Open Questions
- 美术风格是什么？→ 通过 /art-bible 解决
- 见切帧窗口到底设多少帧才"有挑战但不折磨"？→ 通过早期原型 playtest 解决
- Boss 之间是否需要休息/商店环节？→ 通过原型验证节奏感
- 永久解锁的节奏如何控制才能既有成就感又不破坏核心体验？→ 通过系统 GDD 详细设计

---

## MVP Definition

**Core hypothesis**: 玩家会觉得"用大剑/太刀读懂 Boss 行为模式并惩罚破绽"这件事本身足够有趣，愿意反复挑战不同 Boss 和构建路线。

**Required for MVP**:
1. 2 个流派（大剑 + 太刀），手感打磨到位
2. 5 个 Boss（各 3 阶段），行为模式各不相同
3. 20-25 个强化词条（每流派 8-10 个 + 通用 5 个）
4. 完整的一次 Run 循环（选流派 → 连续讨伐 → 通关结算）
5. 基础的永久解锁系统（解锁新词条进入奖池）

**Explicitly NOT in MVP** (defer to later):
- 额外流派（战锤、薙刀等）→ 后续更新
- 挑战模式/排行榜 → 后续更新
- 完整叙事/世界观 → 后续更新
- 多人/联机 → 不在计划内

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 5 Boss + 2 流派 + 25 词条 | 核心循环 + 基础 Meta | 2-3 个月 |
| **Vertical Slice** | 8 Boss + 2 流派 + 40 词条 | 核心 + 图鉴 + 解锁系统 | 3-4 个月 |
| **EA Launch** | 10 Boss + 2 流派 + 50 词条 | 全功能 + 挑战模式 | 4-5 个月 |
| **Full Vision** | 15+ Boss + 4 流派 + 100 词条 | 全内容 + 排行榜 + 社区功能 | 8-12 个月 |

---

## Visual Identity Anchor

*待定——运行 /art-bible 后填充。*

初始方向建议：优先服务于**动作可读性**——Boss 的每一个招式前摇必须在视觉上清晰可辨，玩家在 0.3 秒内能判断"这是什么招、我该怎么应对"。

---

## Next Steps

- [ ] 运行 `/setup-engine` 配置 Godot 4.6 引擎并填充版本感知参考文档
- [ ] 运行 `/art-bible` 创建视觉身份规范——在写 GDD 之前完成
- [ ] 使用 `/design-review design/gdd/game-concept.md` 验证概念完整性
- [ ] 与 `creative-director` agent 讨论支柱优化
- [ ] 运行 `/map-systems` 将概念分解为独立系统并映射依赖关系
- [ ] 使用 `/design-system` 为每个系统编写详细 GDD
- [ ] 运行 `/create-architecture` 规划技术架构蓝图
- [ ] 使用 `/architecture-decision` 记录关键架构决策
- [ ] 运行 `/gate-check` 验证是否可以进入生产阶段
- [ ] 使用 `/prototype [core-mechanic]` 原型验证核心循环
- [ ] 运行 `/playtest-report` 验证核心假设
- [ ] 验证通过后，使用 `/sprint-plan new` 规划第一个迭代
