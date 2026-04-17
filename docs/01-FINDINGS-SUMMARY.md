# 🎮 Tide Hunter (猎潮) — Exploration Findings Summary

**Explored**: 2026-04-17  
**Status**: Design Phase Complete, Ready for System Design → Prototyping

---

## 📊 QUICK FACTS

| Aspect | Detail |
|--------|--------|
| **Project Name** | Tide Hunter (猎潮) |
| **Genre** | Action Roguelite / Boss Rush |
| **Engine** | Godot 4.6 (GDScript) |
| **Platform** | PC (Steam) |
| **Scope** | Medium (4-5 months solo) |
| **Dev Stage** | Pre-Production (Design Complete) |
| **Session Length** | 20-30 minutes per run |
| **Code Status** | None yet (template ready) |
| **Design Status** | Main GDD complete (~280 lines) |
| **Prototypes** | Zero (ready to start) |

---

## 🎯 CORE CONCEPT

> **No enemy waves. Each boss is a true hunt.**
> 
> Overhead action Roguelite where players learn boss patterns and exploit breakwindows using two distinct weapon archetypes. Combines the fast Roguelite loop of Brotato with the tactical depth of Monster Hunter.

### Unique Selling Points
1. ✅ **Pure Boss Rush** — No trash mobs, no auto-attack, no passive survival
2. ✅ **Dual Archetypes** — Completely different playstyles (prediction vs reaction)
3. ✅ **Read-Reward System** — All damage comes from exploiting telegraphed breakwindows
4. ✅ **No Stat Scaling Endgame** — Difficulty never escalates, only options expand

---

## 🗡️ COMBAT SYSTEM: THE TWO WEAPONS

### GREAT SWORD (大剣) — "The Predictor"
**Core Loop**: Observe → Predict → Position → Charge → Release → Massive Damage

| Aspect | Detail |
|--------|--------|
| **Playstyle** | Positioning-based prediction |
| **Challenge** | Reading attack wind-ups (0.2-0.5s tells) |
| **Main Action** | Charge attack while moving (60% move speed penalty) |
| **Damage Range** | Light tap (1x) → Full charge (3x multiplier) |
| **Time Commitment** | 2.0s charge time for full damage |
| **Risk** | Vulnerable during charge; missed reads = long recovery |
| **Skill Expression** | Perfect timing to land full charge during breakwindow |
| **Synergy Example** | "Momentum" → gains move speed after full charge, enables aggressive repositioning |

**Frame Details**:
- Charge multiplier: 1.0x + (held_time / 2.0s), capped at 3.0x
- Base damage: 50 per hit
- Full charge damage: 150 (3x multiplier)
- Recovery on miss: 0.8s vulnerability window

---

### LONG SWORD (太刀) — "The Duelist"
**Core Loop**: Accumulate Stance → Boss Attacks → Parry (6-10 frames) → Combo → Reset

| Aspect | Detail |
|--------|--------|
| **Playstyle** | Reaction-based defense-counter |
| **Challenge** | Frame-perfect parry timing (6-10 frame window = 100-167ms) |
| **Main Action** | React to attack startup with parry input |
| **Stance Mechanic** | Gauge 0-100; light hits +20 stance; parry costs -25; fail costs -100 |
| **Parry Window** | 6-10 frames @ 60fps during attack startup |
| **Risk** | Must stay close (high damage intake if fail); stamina decay on inaction |
| **Skill Expression** | Reading tells; perfect frame timing; chaining parries |
| **Synergy Example** | "Razor Instinct" → window expands to 8-12 frames, enabling more frequent parries |

**Frame Details**:
- Parry active window: 6-10 frames (demanding but learnable; ~150ms reaction time)
- Parry damage reflection: 50% of incoming attack as counter
- Counter-stance (full meter): 2.0x damage multiplier on reflected hit
- Combo stun after parry: 0.8s window for guaranteed damage
- Light attack damage: 20 base

---

## 💪 BOSS DESIGN STRUCTURE

### Phase System
Every boss has **3 Phases**, each escalating challenge:

| Phase | HP Range | Attack Speed | Breakwindow | Challenge |
|-------|----------|--------------|-------------|-----------|
| **Phase 1** | 100-67% | 1.0x | 1.0s (generous) | Learning period; slow attacks, large windows |
| **Phase 2** | 66-34% | 1.25x | 0.85s | Introduces new attack; windows shrink |
| **Phase 3** | 33-0% | 1.5x | 0.7s (or 1.5s after berserk) | Fastest attacks; BUT kill window appears after berserk chain |

### Attack Design Template
```
Wind-up (0.2-0.5s) [VISUAL TELL]
  ↓ Audio cue + stance shift
  ↓
Startup (0.1-0.3s) [LONG SWORD PARRY WINDOW 6-10 FRAMES STARTS]
  ↓
Active (0.1-0.5s) [HITBOX ACTIVE]
  ↓ Damage: 20-40 HP
  ↓
Recovery (0.3-1.2s) [GREAT SWORD BREAKWINDOW — CHARGE AND HIT NOW]
```

### MVP Boss Requirements
- **5 Bosses minimum** (3-4 months solo development)
- **5-8 unique attacks per boss** (hand-crafted, not random)
- **3-phase progression** (clear difficulty ramp)
- **Varied attack timing** (some fast for Long Sword, some slow for Great Sword)
- **Each boss beatable by both archetypes** (but different strategies)

---

## 🎁 ROGUELITE BUILD SYSTEM

### 25 Traits (MVP Target)
- 8-10 Great Sword-specific
- 8-10 Long Sword-specific
- 5 universal traits

### Design Philosophy: PLAYSTYLE, NOT STATS

**✅ GOOD Traits** (Change how you fight):
- "After full charge hit, gain +20% move speed for 3s" (repositioning changes)
- "Parries extend combo window by 0.1s each" (rewards chaining)
- "Each successful hit marks weak points for +30% damage on next hit"

**❌ BAD Traits** (Just numbers):
- "+30% all damage"
- "+50 max health"
- "Random debuffs on hit"

### Build Examples

**Great Sword "Momentum Stack"**:
- Momentum (move speed after charge)
- Swift Preparation (faster charging)
- Delayed Bloom (store bonus charges)
- **Play Pattern**: Rapid repositioning → frequent charges → aggressive cycle

**Long Sword "Parry Master"**:
- Razor Instinct (wider parry window 8-12 frames)
- Cascade (combo extends after each parry)
- Retribution (reflected damage +50%)
- **Play Pattern**: Snowballing parry chains → easier windows over time

---

## 🏗️ PROJECT STATE: What Exists

### ✅ COMPLETE
1. **design/gdd/game-concept.md** (280 lines)
   - Full game vision + mechanics
   - MDA framework analysis
   - Player psychology (Bartle taxonomy)
   - MVP scope defined
   - Inspiration references detailed

2. **Project Infrastructure**
   - Claude Code Game Studios template (49 agents, 72 skills)
   - Godot 4.6 project structure
   - Design/Registry/Source directories
   - Coding standards documented

3. **Entity Registry** (empty, ready for data)
   - Will track bosses, items, formulas cross-document

### ❌ NOT STARTED
1. **System GDDs** (need 5-6 detailed design specs):
   - Combat System GDD
   - Long Sword Combat System GDD
   - Boss AI State Machine GDD
   - Roguelite Build System GDD
   - Progression & Unlock System GDD
   - UI/HUD System GDD

2. **Boss Designs**
   - No behavior trees yet
   - No attack sequences documented
   - No timings specified
   - No visual/audio descriptions

3. **Prototypes**
   - Zero playable code
   - Input latency untested on Godot 4.6
   - No AI state machines
   - No animation systems

4. **Art & Audio**
   - No visual identity spec (art-bible)
   - No boss designs
   - No VFX specifications
   - No sound design document

---

## 📋 COMBAT DESIGN PILLARS (The Commitments)

### Pillar 1: "Each Battle is a Dialogue"
- Bosses are intelligent opponents, not just HP bars
- Combat depth = cognitive growth, NOT stat escalation
- Design test: Add new attacks, not more health

### Pillar 2: "Output is Commitment"
- Every action has consequences
- GS: Risk positioning + charge time
- LS: Risk damage intake for parry reward
- NO consequence-free spam attacks

### Pillar 3: "Ease-to-Learn, Hard-to-Master"
- First boss = tutorial (2-minute onboarding)
- 200+ hour mastery ceiling (synergies, perfect timing, multi-approach strategies)
- NO forced tutorial levels

### Pillar 4: "Build Changes Playstyle"
- Traits modify how you fight, not just stat numbers
- Example: "Mark weak points" > "+30% damage"
- Synergies enable emergent strategies

---

## 🚀 RECOMMENDED NEXT STEPS

### Phase 1: Design Completion (Week 1-2)
```
[ ] /art-bible            → Create visual identity spec
[ ] /map-systems          → Decompose into 5-6 systems
[ ] /design-system        → Write detailed GDD for each system
[ ] /design-review        → Validate against game pillars
[ ] /create-architecture  → Godot technical blueprint
```

### Phase 2: Core Prototype (Week 3-4)
```
[ ] /prototype combat-system
    └─ Goal: 1 Great Sword player + 1 simple boss
    └─ Must validate charge loop feels good
    └─ CRITICAL: Test Godot 4.6 input latency for parry precision
[ ] Implement Long Sword parry + 1 boss
    └─ Goal: Validate 6-10 frame parry window is achievable
    └─ Playtest feedback on frame precision
```

### Phase 3: Vertical Slice (Week 5-8)
```
[ ] Add 2-3 more bosses with varied patterns
[ ] Implement 15-20 traits with synergies
[ ] Test build emergent strategies
[ ] Create art & audio asset pipeline
```

---

## 💡 KEY TECHNICAL INSIGHTS

### The Frame-Perfect Challenge
- Long Sword parry window: **6-10 frames @ 60fps = 100-167ms**
- This requires ~150ms human reaction time (achievable, not trivial)
- **Early validation needed**: Does Godot 4.6 support this precision?
  - Test input polling frame-by-frame
  - Verify no input queuing delays
  - Consider input buffering strategy

### Boss AI Complexity
- Each boss = 5-8 hand-crafted attacks
- Each attack = 3-phase progression (modified per phase)
- Each boss = ~120-150 hours design + implementation + tuning
- 5 bosses = ~600-750 hours solo work (feasible in 3-4 months with focus)

### Synergy & Balance
- Great Sword: Additive (more charges → more damage stacking)
- Long Sword: Multiplier (chain parries → exponential feedback)
- Each archetype needs 8-10 unique traits minimum
- Cross-archetype balance: Must feel equally viable per boss

---

## 🎬 INSPIRATION REFERENCES

| Title | What We Take | What We Do Differently | Why |
|-------|--------------|------------------------|-----|
| **Brotato** | Fast Roguelite loop, build variety | Boss fights (no auto-attack) | Validates market for short runs |
| **Monster Hunter** | Weapon mastery, read patterns | Compress to 20min run, remove prep | Validates "learning boss" appeal |
| **Hades** | Action Roguelite + boss combat | Dual archetypes, pure boss rush | Validates action Roguelite viability |
| **Furi** | Pure boss rush | Add Roguelite build layer | Validates boss-only appeal |
| **Celeste** | Frame-perfect input, high skill ceiling | Combat vs platforming | Validates hard-input monetization |

---

## 📁 KEY FILE LOCATIONS

```
design/gdd/game-concept.md ............ Main design vision (COMPLETE)
design/registry/entities.yaml ......... Entity registry (empty, ready)
design/CLAUDE.md ...................... Design standards
src/CLAUDE.md ........................ Code standards
src/.gitkeep ......................... (empty, ready for code)
README.md ............................ Framework documentation
CLAUDE.md (root) ..................... Master project config
```

---

## ⚡ EXECUTIVE SUMMARY

**Game**: Boss-rush Roguelite where players learn patterns and exploit breakwindows.  
**Two Weapons**: Great Sword (prediction + positioning) vs Long Sword (reaction + parry timing).  
**MVP**: 5 bosses, 25 traits, dual archetype, 3-phase boss scaling.  
**Current Status**: Design complete, zero code, ready for system design → prototyping.  
**Timeline**: 3-4 months solo development if design is solid.  

**Critical Path**:
1. Validate Godot 4.6 input precision for 6-10 frame parry window (ASAP)
2. Write system GDDs (1-2 weeks)
3. Build first combat prototype (1-2 weeks)
4. Playtest & iterate (ongoing)

**Biggest Risks**:
- Input latency makes frame-perfect parries unfeasible on Godot 4.6
- Boss AI state machine complexity underestimated
- Dual-archetype balance is harder than anticipated
- Trait synergy creates unintended power combinations

**Biggest Opportunities**:
- Clear dual-archetype differentiation (appeals to two player types)
- Boss learning core is inherently replayable (unique vs typical Roguelite)
- Trait synergies enable emergent strategies & community theorycrafting
- Minimal content needs (5-8 bosses can sustain hundreds of hours with mastery focus)

