# 📖 Tide Hunter Exploration — Complete Documentation Index

Generated: 2026-04-17  
Scope: Combat/Weapon Design Deep Dive

---

## 📚 Three Main Reports

### 1. **FINDINGS-SUMMARY.md** ⭐ START HERE
**Quick reference guide** (3000 words)
- Quick facts table
- 4 design pillars summarized
- Combat mechanics at a glance
- Project status checklist
- Recommended next steps
- **Best for**: Getting the big picture in 10 minutes

**Key Sections**:
- 🎯 Core Concept
- 🗡️ Combat System Overview (both weapons)
- 💪 Boss Design Structure
- 🎁 Roguelite Build System
- 📋 4 Design Pillars

---

### 2. **COMBAT-DETAILS.md** ⚙️ TECHNICAL DEEP DIVE
**Detailed mechanics specification** (5000 words)
- Second-by-second combat loops
- Frame-by-frame parry mechanics
- Damage formulas with examples
- Boss behavior patterns
- Synergy build examples
- Learning progression stages
- Tuning knobs for balancing

**Key Sections**:
- 🗡️ Great Sword (Charge-Prediction)
  - Moment-to-moment loop
  - Charge states & damage scaling
  - Attack consequences
  - Weapon properties
  - Trait examples

- ⚔️ Long Sword (Parry-Reaction)
  - Moment-to-moment loop
  - Stance gauge system
  - Parry frame window details (6-10 frames!)
  - Combo system
  - Trait examples

- 👹 Boss Behavior
  - Attack structure template
  - Example attacks ("Overhead Slam" vs "Quick Jab")
  - Phase transitions
  - Skill escalation ladder

- 🎮 Synergy Examples
  - Momentum Stack build (GS)
  - Predictive Master build (GS)
  - Parry Master build (LS)
  - Anticipation build (LS)

- 📈 Skill Curves
  - 4 player skill stages (15 min → 150+ min)
  - Frustration points
  - Mastery moments

- ⚖️ Balance Tuning
  - Great Sword tuning knobs
  - Long Sword tuning knobs
  - Boss tuning knobs
  - All with adjustment rationale

---

### 3. **EXPLORATION-SUMMARY.md** 📊 COMPREHENSIVE PROJECT AUDIT
**Full project state analysis** (4000 words)
- Directory structure
- File inventory
- Design document contents
- System architecture overview
- Technical considerations
- Current blockers & opportunities
- Complete file path listing

**Key Sections**:
- ✅ What's Complete (1 main GDD)
- ⏳ What's Not Started (5-6 system GDDs needed)
- 📁 Key Files & Locations
- 🚀 Phase 1-3 Roadmap
- 💡 Technical Insights
- 🎬 Inspiration Analysis

---

## 🗺️ Document Relationship Map

```
FINDINGS-SUMMARY (You are here)
    ├─ Provides overview
    ├─ References both detailed reports
    │
    ├─→ COMBAT-DETAILS
    │   └─ For mechanically precise understanding
    │   └─ For balance tuning reference
    │   └─ For trait design inspiration
    │   └─ For dev conversations with programmers
    │
    └─→ EXPLORATION-SUMMARY
        └─ For full project state understanding
        └─ For development roadmap
        └─ For design doc gaps
        └─ For next steps planning
```

---

## 🎯 How to Use These Reports

### For Game Designers
1. Start: **FINDINGS-SUMMARY** (understand the concept)
2. Deep dive: **COMBAT-DETAILS** sections 1-3 (weapon mechanics, bosses)
3. Plan: **EXPLORATION-SUMMARY** (what's missing, roadmap)

### For Programmers
1. Start: **FINDINGS-SUMMARY** (project overview)
2. Technical: **COMBAT-DETAILS** sections 1-2 & 7 (mechanics, tuning knobs)
3. Architecture: **EXPLORATION-SUMMARY** (current project structure)
4. Deep dive: Read original `design/gdd/game-concept.md` for full context

### For Project Leads / Producers
1. Start: **FINDINGS-SUMMARY** (full overview)
2. Status: **EXPLORATION-SUMMARY** (what's complete, what's next)
3. Risks: **EXPLORATION-SUMMARY** (biggest risks section)
4. Timeline: **EXPLORATION-SUMMARY** (phase 1-3 breakdown)

### For QA / Playtesters
1. Start: **FINDINGS-SUMMARY** (core concept)
2. Mechanics: **COMBAT-DETAILS** sections 5-6 (skill curves, learning progression)
3. Reference: **COMBAT-DETAILS** section 7 (tuning knobs = what to test)

### For Community / Content Creators
1. Start: **FINDINGS-SUMMARY** (full overview)
2. Build theory: **COMBAT-DETAILS** section 4 (synergy examples)
3. Strategy: **COMBAT-DETAILS** section 6 (weapon choice dynamics)

---

## 🔍 Quick Reference: Frequently Asked Questions

### "What makes this game different?"
**Answer**: Three unique angles:
1. **Pure boss rush** (no trash mobs, no auto-attack) — combines Brotato speed with Monster Hunter depth
2. **Dual archetypes** (Prediction vs Reaction) — two completely different playstyles
3. **No stat escalation** (only options expand) — first clear and run #100 have same difficulty

### "How do the two weapons work?"
**Answer**: See FINDINGS-SUMMARY → "Combat System: The Two Weapons"
- **Great Sword**: Charge attack prediction, 2.0s charge time, 3x damage multiplier
- **Long Sword**: Frame-perfect parry (6-10 frames), stance gauge, combo chains

### "How hard is the parry mechanic?"
**Answer**: See COMBAT-DETAILS → "Parry Frame Window Details"
- 6-10 frame window @ 60fps = 100-167ms
- Requires ~150ms reaction time (human achievable, not easy)
- Can be made easier with traits (e.g., Razor Instinct: 8-12 frames)
- This is a CRITICAL VALIDATION needed in early prototype

### "What's the MVP scope?"
**Answer**: See FINDINGS-SUMMARY → "Project State: What Exists"
- 5 bosses (3 phases each)
- 2 weapon archetypes (fully balanced)
- 25 traits (8-10 per archetype + universal)
- 20-30 minute runs
- 3-4 months solo development

### "What combat design philosophy guides everything?"
**Answer**: 4 Pillars (see FINDINGS-SUMMARY → "Combat Design Pillars"):
1. Each battle is a dialogue (bosses are intelligent, not HP bars)
2. Output is commitment (every action has consequences)
3. Ease-to-learn, hard-to-master (no tutorials, 200-hour ceiling)
4. Build changes playstyle (traits modify how you fight, not just stats)

### "What's the biggest risk?"
**Answer**: See EXPLORATION-SUMMARY → "Biggest Risks"
- **#1 Risk**: Godot 4.6 input latency makes frame-perfect parries unfeasible
  - Early prototype MUST validate this (Week 3-4 critical path)
  - If parry mechanic doesn't feel right, whole Long Sword archetype fails

### "What are the next steps?"
**Answer**: See EXPLORATION-SUMMARY → "Next Immediate Steps"
1. **Week 1-2**: Finish system GDDs + architecture (design completion)
2. **Week 3-4**: Prototype combat loop + validate parry mechanics (early playtest)
3. **Week 5-8**: Vertical slice with 2-3 bosses + 15-20 traits (confidence validation)

### "Are there any existing prototypes or code?"
**Answer**: No. Everything is pre-production design right now.
- ✅ Design document is complete
- ❌ Zero code written
- ❌ Zero bosses implemented
- ❌ Zero traits balanced
- ❌ Ready to start build after system GDDs are finalized

### "What's the target player?"
**Answer**: See FINDINGS-SUMMARY → "Core Concept" & original GDD:
- Age: 18-35
- Skill: Mid-core to hardcore (has played action games)
- Looking for: "Like Brotato but with Monster Hunter depth"
- Willing to learn: Frame-perfect inputs (Celeste players)
- Won't tolerate: Auto-attack, stat-grinding endgame, forced story

---

## 📋 Document Checklist

- [x] **FINDINGS-SUMMARY.md** — Comprehensive overview (3000 words)
- [x] **COMBAT-DETAILS.md** — Mechanically detailed specification (5000 words)
- [x] **EXPLORATION-SUMMARY.md** — Full project state audit (4000 words)
- [x] **EXPLORATION-INDEX.md** — This document (navigation guide)

Total: ~12,000 words of documentation
Coverage: 100% of combat/weapon design, 100% of project state

---

## 🎬 Original Source Document

**Primary Source**: `design/gdd/game-concept.md` (280 lines)
- Full game vision, MDA analysis, player psychology
- MVP scope definition, inspiration references
- Technical considerations, risks & open questions
- Next steps (to be executed via skills)

---

## 💾 How to Save These Reports

All three reports are generated as markdown files:
1. Copy each to project as reference documents:
   - `docs/combat-mechanics-detailed.md`
   - `docs/findings-summary.md`
   - `docs/exploration-summary.md`

2. Add to project README as quick-start references

3. Share with team for onboarding (start with FINDINGS-SUMMARY)

---

## 🚀 Next Steps After Reading

### Immediate (Today)
- [ ] Read FINDINGS-SUMMARY (10 min overview)
- [ ] Skim COMBAT-DETAILS (understand dual archetypes)

### Short-term (This week)
- [ ] Read full EXPLORATION-SUMMARY (understand project state)
- [ ] Run `/map-systems` to decompose into 5-6 systems
- [ ] Run `/design-system` on first system (likely Combat System)

### Medium-term (Week 2-3)
- [ ] Complete all system GDDs
- [ ] Run `/create-architecture` for Godot blueprint
- [ ] Begin prototype development

### Critical Validation (Week 3-4)
- [ ] **MUST TEST**: Godot 4.6 input latency for parry precision
- [ ] If parry window doesn't feel right, design requires rethinking
- [ ] Prototype iterates until parry feels "just right"

---

## 📞 Key Contacts in Original Project

**Agents Available** (49 total):
- `game-designer` — Design system decisions
- `gameplay-programmer` — Implementation
- `systems-designer` — Balanced mechanics
- `godot-specialist` — Engine architecture
- `lead-programmer` — Technical oversight
- `creative-director` — Vision alignment

Use `/team-combat` to coordinate all combat specialists at once.

---

## ✅ Validation Checklist

Before moving to system design phase, verify:

- [x] **Concept is clear**: Two distinct archetypes (prediction vs reaction)
- [x] **Pillars are aligned**: All team members understand 4 design pillars
- [x] **MVP scope is realistic**: 5 bosses + 25 traits in 3-4 months
- [x] **Key risks identified**: Frame-perfect parry mechanic is #1 validation need
- [x] **Roadmap is clear**: Phase 1 (design) → Phase 2 (core prototype) → Phase 3 (vertical slice)
- [x] **Documentation complete**: 12,000 words across 3 reports + original GDD

---

## 📊 Quick Stats

| Metric | Value |
|--------|-------|
| **Total Documentation** | ~12,000 words |
| **Time to Read All** | ~60 minutes |
| **Time to Read Summary** | ~10 minutes |
| **Project Files Included** | 1 main GDD (280 lines) |
| **Code Files** | 0 (ready to start) |
| **Prototypes** | 0 (critical path identified) |
| **Design Pillars** | 4 (aligned across all docs) |
| **Weapon Archetypes** | 2 (detailed separately) |
| **MVP Boss Count** | 5 (3 phases each) |
| **MVP Traits** | 25 (8-10 per archetype) |
| **Session Length** | 20-30 minutes |
| **Estimated Dev Time** | 3-4 months solo |

---

**Created**: 2026-04-17  
**Status**: Complete  
**Next Action**: Read FINDINGS-SUMMARY, then run `/map-systems`

