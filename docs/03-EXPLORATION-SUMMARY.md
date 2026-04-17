# Tide Hunter (猎潮) — Project Exploration Report
**Date**: 2026-04-17  
**Project Stage**: Pre-Production (Design Phase)  
**Engine**: Godot 4.6 (GDScript)

---

## PROJECT OVERVIEW

**Game Title**: Tide Hunter (猎潮)  
**Genre**: Action Roguelite / Boss Rush  
**Platform**: PC (Steam)  
**Scope**: Medium (4-5 months, solo development)  
**Monetization**: Buy-once (≤50 CNY)  
**Session Length**: 20-30 minutes per run

### Comparable Titles
- Brotato (fast Roguelite loop)
- Monster Hunter (weapon mastery, boss patterns)
- Hades (action Roguelite + boss combat)
- Furi (pure boss rush)
- Celeste (frame-perfect input, high skill ceiling)

---

## CORE CONCEPT

> 一款以 Boss 战为核心的俯视角动作 Roguelite——没有怪海，每一波都是一场真正的狩猎。

**Translation**: An overhead action Roguelite centered on boss fights — no enemy waves, every encounter is a true hunt.

### Unique Hook
- **NOT** enemy waves/auto-attack survival (Brotato-style)
- **IS** each boss is a unique puzzle with behavior patterns and exploitable weaknesses
- Players must "learn" each boss like in Monster Hunter, but compressed into 20-30 min runs
- Roguelite build system adds strategic layer to pure boss-rushing

---

## COMBAT & WEAPON DESIGN

### Dual-Archetype System

#### **大剣 (Great Sword) — The Predictor**
- **Core Mechanic**: Charge-attack prediction
- **Loop**: Observe → Predict breakwindow → Pre-position → Charge full hit → Massive damage + screen shake → Retreat → Observe
- **Player Fantasy**: Pre-positioning as omniscience; every fully-charged strike is a judgment declared
- **Risk Profile**: High commitment (charge time = vulnerability); read must be correct
- **Skill Expression**: Timing the charge start to land at the exact moment boss enters breakwindow

#### **太刀 (Long Sword) — The Duelist**
- **Core Mechanic**: Parry-counter (見切 "Miiire") with stance system
- **Loop**: Light attacks accumulate stance gauge → Boss attacks → Parry on precise frame → Stance upgrades → Combo acceleration → Stance full → Special finisher → Reset cycle
- **Player Fantasy**: Close-quarters grappling; turning enemy offense into your offense through perfect timing
- **Risk Profile**: Close range = higher damage intake potential; frame-perfect parry window (6-10 frames)
- **Skill Expression**: Reading boss tells and reacting with 1-3 frame input precision

### Key Design Philosophy

**Pillar 1: "Each battle is a dialogue"**
- Bosses are intelligent opponents, not HP bars
- Combat depth comes from cognitive growth, not stat escalation
- Design choice: Add new boss attacks instead of more health

**Pillar 2: "Output is commitment"**
- Every attack has consequences
- Great Sword: Risk positioning + charge time for reward
- Long Sword: Risk damage intake for parry rewards
- Anti-pattern: NO safe, consequence-free spam attacks

**Pillar 3: "Ease-to-learn, hard-to-master"**
- 2-minute onboarding (first boss is the tutorial)
- 200+ hour mastery ceiling (perfect timing, build synergies, multi-approach strats)
- NO forced tutorial levels

**Pillar 4: "Build changes playstyle, not balance"**
- Upgrades modify how you interact with bosses, not just stat numbers
- Example: "+30% damage" is bad; "mark weak points on hit" is good (changes strategy)

---

## BOSS & COMBAT SYSTEMS

### Boss Structure
Each Boss has **3 Phases**:
1. **Phase 1** (Learning) — Basic attacks, large breakwindows, high tolerance for errors
2. **Phase 2** (Pressure) — Increased speed + new attack introduced, breakwindows shrink
3. **Phase 3** (Berserk) — Most powerful combo chains, BUT reveals largest breakwindow for the killing blow

### Boss Design Requirements
- **5-8 unique attacks per boss** (hand-crafted, not randomized)
- **Clear wind-up animations** for visual readability (<300ms to diagnose)
- **Exploitable breakwindows** (telegraphed by attack recovery or special stance transitions)
- **Varied combat pacing** — different bosses favor different archetype strengths

### MVP Boss Count
- **5 Bosses** minimum for MVP (feasible solo in 2-3 months)
- **15+ Bosses** full vision (requires team or 8-12 months)

---

## ROGUELITE & BUILD SYSTEMS

### Core Loop: Session-Level (20-30 min)
```
Choose Archetype (Great Sword or Long Sword)
    ↓
Boss 1 (Onboarding, simple patterns)
    ↓ [Defeat] → 3-choice Upgrade (Pick 1 of 3 random traits)
    ↓
Boss 2 (Introduce new mechanic)
    ↓ [Defeat] → 3-choice Upgrade
    ↓
Boss 3-4 (Difficulty ramp)
    ↓ [Defeats] → Upgrades
    ↓
Boss 6-8 (Final Boss — synthesis of all mechanics)
    ↓ [Defeat] → Run Complete
    ↓
Permanent Unlock + Meta Progression
```

### Upgrade/Build System

**25 Traits (MVP Target)**:
- 8-10 Great Sword-specific traits
- 8-10 Long Sword-specific traits
- 5 Universal traits

**Design Philosophy**:
- Traits **change playstyle**, not just scale stats
- Example good traits:
  - "After full charge hit, gain 20% move speed for 3s" (changes positioning)
  - "Parries reduce boss stagger recovery by 25%" (synergizes with long sword chain)
  - "Each archetype combo extends boss phase timer" (risk/reward decision)
  
- Example bad traits:
  - "+30% all damage" (just numbers)
  - "+50 max health" (defensive bloat)
  - "Attacks apply random debuffs" (removes read-reward connection)

### Permanent Progression (Cross-Run)
- Unlocks new traits into the pool (doesn't raise floor, expands ceiling)
- First clear and run #100 have identical boss difficulty
- Progression = new options, not guaranteed advantage

---

## TECHNICAL CONSIDERATIONS

### Engine & Platforms
- **Engine**: Godot 4.6 with GDScript
- **Key Challenge**: Input latency validation for frame-perfect parry windows (6-10 frames @ 60fps = 100-167ms window)
- **Early Prototype Need**: Godot 4.6 input handling must support this precision without external libraries

### AI & State Machines
- Boss behavior is **deterministic state machine** (not random, but can vary composition)
- Each attack is hand-scripted 3-phase progression
- Attack combinations can have minor randomization (pick 1 of 3 attack chains) for replayability

### Graphics/Art Requirements
- **Visual Readability Priority #1**: Boss wind-ups must be unambiguous in 0.3 seconds
- **Suggested Style**: Minimalist (prioritizes readability over complexity)
- **Art Scope**: 2D animations for 5 bosses + 2 player weapon variations
- **Special Effects**: 
  - Screen shake on full-charge hit (important feedback)
  - Time-freeze flash on parry success (important feedback)
  - Boss stagger animations (signals breakwindow)

### Audio Needs
- Boss attack startup sounds = primary tell source
- Full-charge hit impact sound = critical satisfaction feedback
- Parry-success "clash" sound = frame-perfect feedback
- **Importance**: High (sound design is key to reading attacks)

---

## CURRENT PROJECT STATE

### ✅ COMPLETED
1. **Game Concept Document** (`design/gdd/game-concept.md`)
   - Full design vision with MDA framework analysis
   - Core mechanics detailed
   - Player motivation profiles (Bartle taxonomy)
   - MVP scope clearly defined
   - ~280 lines of comprehensive design

2. **Project Infrastructure**
   - Claude Code Game Studios template set up (49 agents, 72 skills)
   - Godot 4.6 project structure ready
   - Design/Registry/Source directory structure established
   - Coding standards documented

### ⏳ NOT YET STARTED
1. **System GDDs** (detailed design specifications)
   - Combat System GDD (Great Sword mechanics in detail)
   - Long Sword Combat System GDD
   - Boss AI State Machine GDD
   - Roguelite Build System GDD
   - Progression & Unlock System GDD
   - UI/HUD System GDD

2. **Boss & Attack Designs**
   - No boss behavior trees defined yet
   - No attack wind-up/recovery timings documented
   - No breakwindow exploitation sequences defined

3. **Gameplay Prototypes**
   - No playable prototype exists yet
   - No input validation (parry frames) tested on Godot 4.6
   - No boss AI state machines implemented
   - No weapon attack animations/hitboxes

4. **Build/Trait Balancing**
   - Only high-level concept; no math formulas
   - No synergy pairs identified
   - No tuning knobs defined

5. **Art & Audio**
   - No visual identity spec (art-bible) created yet
   - No boss character designs
   - No attack VFX specifications
   - No sound design brief

---

## DESIGN REGISTRY

**Entity Registry** (`design/registry/entities.yaml`):
- Currently empty (ready for population)
- Once system GDDs are written, boss entries will be added here
- Will track boss stats, attack patterns, drop items

**No cross-document entities registered yet** because detailed system GDDs haven't been written.

---

## NEXT IMMEDIATE STEPS (Recommended)

### Phase 1: Design Completion (Week 1-2)
1. [ ] `/art-bible` — Create visual identity spec (minimalist, readable)
2. [ ] `/map-systems` — Decompose into: Combat System, Boss AI System, Build System, Progression System, UI System
3. [ ] `/design-system` — Write detailed GDDs for each system (requires 8-section template per GDD)
4. [ ] `/design-review` — Validate each GDD against game pillars
5. [ ] `/create-architecture` — Technical architecture blueprint for Godot

### Phase 2: Core Prototype (Week 3-4)
1. [ ] `/prototype combat-system` — Implement 1 Great Sword + 1 Simple Boss
   - Goal: Validate charge-attack prediction loop feels good
   - Must test input latency on Godot 4.6
2. [ ] Implement 1 Long Sword boss with parry mechanic
   - Goal: Validate 6-10 frame parry window is achievable
3. [ ] Early playtest feedback

### Phase 3: Vertical Slice (Week 5-8)
1. Build 2-3 more bosses with distinct patterns
2. Implement 15-20 traits
3. Test synergy mechanics
4. Create asset pipeline

---

## KEY FILES & LOCATIONS

```
📁 design/
  📁 gdd/
    📄 game-concept.md ...................... MAIN DESIGN BIBLE (COMPLETE)
  📁 registry/
    📄 entities.yaml ........................ Entity registry (empty, ready)
  📄 CLAUDE.md ............................. Design directory standards

📁 src/
  📄 CLAUDE.md ............................. Source code standards
  📄 .gitkeep ............................. (empty, ready for code)

📁 production/
  📁 session-logs/ ......................... Session records
  📁 session-state/ ........................ State tracking (empty)

📁 docs/
  📁 architecture/ ......................... ADRs (ready)
  📁 engine-reference/ ..................... Engine docs (ready)

📄 CLAUDE.md (root) ........................ Master project config
📄 README.md .............................. Full framework documentation
```

---

## SUMMARY

**Status**: Early-stage design-complete, pre-production ready for system design phase

**What's Done**:
- ✅ Game concept fully articulated (vision, mechanics, player psychology)
- ✅ Unique hook clearly differentiated (boss-learning vs auto-attack)
- ✅ Dual-archetype combat philosophy established
- ✅ MVP scope realistic for solo developer
- ✅ Infrastructure ready

**What's Missing**:
- ❌ Detailed system GDDs (combat, AI, build, progression)
- ❌ Specific boss behavior trees (attack sequences, timings)
- ❌ Trait synergy mechanics (formulas, tuning)
- ❌ Any playable code or prototypes
- ❌ Visual art style spec
- ❌ Audio design brief

**Combat/Weapon Design Highlights**:
- **Two deeply different playstyles**: Prediction vs Reaction
- **Frame-tight input requirements**: 6-10 frame parry windows demand Godot 4.6 validation
- **Zero auto-attack**: Every action is a decision with consequences
- **Boss learning core**: Not about stat grinding, about pattern recognition
- **Two-month technical challenge**: Boss AI complexity + dual-archetype balance

---

**Next Recommended Action**: Run `/map-systems` to decompose into implementation-ready system GDDs, then `/design-system` for each system's detailed specification.
