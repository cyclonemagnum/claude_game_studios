# Tide Hunter — Project Exploration Reports

Generated: 2026-04-17  
Project Stage: Pre-Production (Design Complete)

---

## 📖 Quick Navigation

Read in this order:

1. **00-EXPLORATION-INDEX.md** — Navigation guide & FAQ
2. **01-FINDINGS-SUMMARY.md** — 10-minute overview (START HERE)
3. **02-COMBAT-MECHANICS-DETAILED.md** — Technical deep-dive (for designers & programmers)
4. **03-EXPLORATION-SUMMARY.md** — Full project state audit (for project planning)

---

## 📊 What's Covered

### ✅ Complete Analysis
- Dual-archetype combat system (Great Sword + Long Sword)
- Boss design structure (3-phase progression, breakwindow mechanics)
- Roguelite build system (25 traits, synergy mechanics)
- Player learning progression (4 skill stages)
- Project state inventory (what exists, what's missing)
- Development roadmap (3-phase plan)
- Critical validation needs (Godot 4.6 input latency)

### 📋 File Breakdown

| File | Size | Content | Best For |
|------|------|---------|----------|
| **00-EXPLORATION-INDEX.md** | 11KB | Navigation, FAQ, reading paths by role | Getting oriented |
| **01-FINDINGS-SUMMARY.md** | 12KB | Overview, pillars, mechanics summary | Quick understanding |
| **02-COMBAT-MECHANICS-DETAILED.md** | 20KB | Frame-by-frame mechanics, formulas, tuning knobs | Implementation reference |
| **03-EXPLORATION-SUMMARY.md** | 12KB | Project structure, gaps, roadmap | Development planning |

---

## 🎯 Key Findings Summary

### Status
- **Design Phase**: ✅ COMPLETE (280-line GDD exists)
- **System GDDs**: ❌ NOT STARTED (5-6 needed)
- **Prototypes**: ❌ ZERO CODE (ready to build)
- **Timeline**: 3-4 months solo development (MVP)

### Core Concept
Boss-rush Roguelite where players learn patterns and exploit breakwindows using two weapon archetypes. Combines Brotato speed with Monster Hunter depth.

### Combat System
- **Great Sword (大剣)**: Charge-prediction + positioning (2.0s charge → 3x damage)
- **Long Sword (太刀)**: Frame-perfect parry (6-10 frames = 100-167ms) + stance combos

### MVP Scope
- 5 bosses (3 phases each)
- 2 weapon archetypes
- 25 traits (8-10 per archetype + universal)
- 20-30 minute runs

### Critical Validation
⚠️ **#1 Priority**: Godot 4.6 input latency for frame-perfect parries (Week 3-4)

---

## 🚀 Next Steps

### Phase 1: Design Completion (Week 1-2)
```
[ ] /art-bible            → Visual identity spec
[ ] /map-systems          → Decompose into systems
[ ] /design-system        → Write detailed GDDs
[ ] /design-review        → Validate against pillars
[ ] /create-architecture  → Godot blueprint
```

### Phase 2: Core Prototype (Week 3-4)
```
[ ] Implement Great Sword + 1 boss
[ ] Implement Long Sword + 1 boss
[ ] CRITICAL: Test 6-10 frame parry window on Godot 4.6
[ ] Early playtest
```

### Phase 3: Vertical Slice (Week 5-8)
```
[ ] Add 2-3 more bosses
[ ] Implement 15-20 traits with synergies
[ ] Test emergent strategies
[ ] Create asset pipeline
```

---

## 💡 Key Insights

### Design Strengths
- ✅ Two deeply different playstyles (prediction vs reaction)
- ✅ Clear design pillars guiding all decisions
- ✅ Boss learning core provides replayability depth
- ✅ Minimal content needs (5-8 bosses can sustain hundreds of hours)
- ✅ Trait synergies enable emergent community strategies

### Development Risks
- ⚠️ Godot 4.6 input latency (frame-perfect parries may not be feasible)
- ⚠️ Boss AI complexity (each boss = 120-150 hours of work)
- ⚠️ Dual archetype balance (must feel equally viable)
- ⚠️ Trait synergy power creep (unintended combinations)

---

## 👥 Reading by Role

### Game Designers
1. Start: **01-FINDINGS-SUMMARY.md**
2. Deep dive: **02-COMBAT-MECHANICS-DETAILED.md** (sections 1-4)
3. Plan: **03-EXPLORATION-SUMMARY.md**

### Programmers
1. Start: **01-FINDINGS-SUMMARY.md**
2. Technical: **02-COMBAT-MECHANICS-DETAILED.md** (sections 1-2, 7)
3. Architecture: **03-EXPLORATION-SUMMARY.md** (Technical Considerations)

### Project Leads / Producers
1. Start: **01-FINDINGS-SUMMARY.md**
2. Status: **03-EXPLORATION-SUMMARY.md** (Project State, Risks, Roadmap)
3. FAQ: **00-EXPLORATION-INDEX.md**

### QA / Playtesters
1. Start: **01-FINDINGS-SUMMARY.md**
2. Mechanics: **02-COMBAT-MECHANICS-DETAILED.md** (sections 5-6)
3. Reference: **02-COMBAT-MECHANICS-DETAILED.md** (section 7)

---

## 🔍 Quick FAQ

**Q: What makes this game different?**  
A: Pure boss rush (no trash) + dual archetypes (prediction vs reaction) + no stat scaling. See 01-FINDINGS-SUMMARY.md.

**Q: How do the parry mechanics work?**  
A: 6-10 frame window @ 60fps = 100-167ms reaction time. See 02-COMBAT-MECHANICS-DETAILED.md section 2.

**Q: What's the MVP scope?**  
A: 5 bosses, 2 weapons, 25 traits, 20-30 min runs. See 01-FINDINGS-SUMMARY.md "Project State".

**Q: What are the 4 design pillars?**  
A: See 01-FINDINGS-SUMMARY.md "Combat Design Pillars" section.

**Q: What's the critical risk?**  
A: Godot 4.6 frame-perfect input latency. See 03-EXPLORATION-SUMMARY.md "Biggest Risks".

---

## 📚 Additional References

**Original GDD**: `design/gdd/game-concept.md` (280 lines)
- Full game vision, MDA analysis, player psychology
- Complete inspiration references, open questions

**Project Infrastructure**: 49 agents, 72 skills ready in `.claude/`

---

## ✅ Document Status

- [x] Exploration complete
- [x] 4 comprehensive reports (12,000+ words)
- [x] 100% coverage of combat/design
- [x] 100% coverage of project state
- [x] Ready for system design phase

**Next Action**: Read 01-FINDINGS-SUMMARY.md, then run `/map-systems`

---

*Generated by Claude Code Game Studios exploration workflow*  
*Date: 2026-04-17*
