# Great Sword Combat System

*Status: Section 1 (Overview) — DRAFTED, awaiting user approval*

---

## 1. Overview

The **Great Sword** archetype is the prediction-focused dual-archetype, embodying the "hunter who reads the prey before it strikes." Players charge a devastating attack over 2.0 seconds while positioning in the predicted breakwindow, risking extended vulnerability if their read is incorrect. The core mechanic is **charge-prediction**: predicting where and when a Boss will be vulnerable, pre-positioning the player there, and charging a high-damage attack that must connect during the breakwindow to justify the commitment. A successfully predicted full-charge hit deals 3x base damage with powerful staggers, rewarding read accuracy and positioning skill. Missed predictions incur 0.8s recovery animations and counter-attack risk, embodying the game's "out-hand-is-commitment" pillar. The Great Sword trades mechanical complexity and reaction speed for predictive mastery and positioning reward—players succeed by understanding Boss behavior deeply, not by quick reflexes. The archetype serves players who enjoy methodical prediction-based gameplay with clear causal feedback.

---

## 2. Player Fantasy

[PENDING: Intended feeling, archetype identity, what player imagines themselves doing]

---

## 3. Detailed Rules

[PENDING: Unambiguous mechanics covering: charge states, attack execution, damage consequences, positioning]

---

## 4. Formulas

[PENDING: All mathematical definitions with variables, ranges, and example calculations]

---

## 5. Edge Cases

[PENDING: Unusual situations and explicit handling (not "handle gracefully")]

---

## 6. Dependencies

[PENDING: Other systems this depends on and bidirectional references]

---

## 7. Tuning Knobs

[PENDING: Configurable values with safe ranges and gameplay impact]

---

## 8. Acceptance Criteria

[PENDING: Testable success conditions for QA verification]

---

## Section-by-Section Authoring Log

### Section 1: Overview ✓ DRAFTED
**Status**: Awaiting user approval before proceeding to Section 2.

**Author notes**:
- Captures the prediction vs reaction contrast with Long Sword
- Emphasizes the "out-hand-is-commitment" pillar with risk/reward
- Establishes that success comes from reading Boss behavior, not reaction speed
- References 2.0s charge, 3x damage, 0.8s recovery as key numbers

**Ready for review**: Does this Overview accurately capture the Great Sword identity? Should any emphasis shift?

### Section 2: Player Fantasy
- **Author Note**: Draw from game-concept.md "Player Fantasy" and "Core Loop" sections
- The Great Sword player imagines being a "prophet" — standing in the right place before the Boss even commits to an attack

### Section 3: Detailed Rules
- **Author Note**: Formalize all mechanics from the exploration docs:
  - Charge states (uncharged, charging, charged)
  - Damage multiplier progression during charge
  - Positioning requirements for successful hits
  - Cooldown/recovery consequences of missed charges
  - Interaction with stance gauge (if applicable)

### Section 4: Formulas
- **Author Note**: Extract from 02-COMBAT-MECHANICS-DETAILED.md and expand:
  - Base damage formula
  - Charge multiplier formula
  - Critical strike calculation
  - Positioning-based modifier formula

### Section 5: Edge Cases
- **Author Note**: Anticipate unusual situations:
  - Boss staggers/gets interrupted during Great Sword charge
  - Player gets hit during charge — does it interrupt?
  - Charge completes but Boss moves away — what happens to damage?
  - Multiple bosses present (if ever applicable) — targeting priority?

### Section 6: Dependencies
- **Author Note**: Identify bidirectional relationships:
  - Depends on: Boss AI System (breakwindow timing), Combat Input System, hitbox/hurtbox system
  - Referenced by: Boss AI (designing breakwindows around GS charge time), Build System (traits that modify charge speed)

### Section 7: Tuning Knobs
- **Author Note**: Define all adjustable parameters:
  - charge_duration_seconds (current: 2.0)
  - charge_damage_multiplier (current: 3.0x at full)
  - charge_recovery_frames (downtime after successful hit)
  - charge_interrupt_penalty (cost of getting hit mid-charge)
  - positioning_tolerance (how far off-center is still "valid")

### Section 8: Acceptance Criteria
- **Author Note**: Define testable pass/fail conditions:
  - "QA can charge for exactly 2.0s and observe 3x damage multiplier applied to hit"
  - "Breakwindow timing matches Boss AI spec ±50ms"
  - "Missed charge has 1.5s recovery before next charge starts"
  - "Trait synergies (e.g., +20% charge speed) apply correctly in calculation"

