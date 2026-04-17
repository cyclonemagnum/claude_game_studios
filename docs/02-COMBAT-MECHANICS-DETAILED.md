# DETAILED COMBAT MECHANICS BREAKDOWN
## Tide Hunter (猎潮)

---

## 1. GREAT SWORD (大剣) — CHARGE-PREDICTION ARCHETYPE

### Moment-to-Moment Loop (30 seconds)
```
OBSERVE
  └─> Read boss positioning, anticipate next attack
      └─> Boss shows wind-up (0.3s tell)
          └─> PREDICT BREAKWINDOW
              └─> Player mentally calculates safe window
                  └─> PRE-POSITION
                      └─> Walk to predicted strike location
                          └─> CHARGE ATTACK
                              └─> Hold attack button (1-3s charge time)
                                  └─> Boss completes attack, enters recovery
                                      └─> RELEASE AT OPTIMAL MOMENT
                                          └─> Full charge connects during breakwindow
                                              └─> MASSIVE DAMAGE + FEEDBACK
                                                  └─> Screen shake (0.5s)
                                                  └─> Time freeze flash (0.2s)
                                                  └─> Impact sound (critical audio tell)
                                                  └─> Boss enters stagger state
                                                      └─> RETREAT & RESET
                                                          └─> Back to OBSERVE
```

### Charge States
- **Light tap** (0.3s hold): 1x base damage, fast recovery, safe but weak
- **Medium charge** (1.0s hold): 1.5x base damage, medium startup, medium breakwindow requirement
- **Full charge** (2.0s hold): 3x base damage, slow startup, MUST land during breakwindow or vulnerable

### Damage Scaling Factors
```
Base Damage = 50
Charge Multiplier = 1.0 + (held_time / 2.0 seconds) clamped to 3.0x
Final Damage = Base * Charge Multiplier * (1 + synergy_bonus)

Example:
- 0.5s tap = 50 * 1.25 = 62.5 dmg (fast, weak, safe for learning)
- 1.5s charge = 50 * 1.75 = 87.5 dmg (medium risk/reward)
- 2.0s full charge = 50 * 3.0 = 150 dmg (risky, requires perfect read)
```

### Attack Consequences (The Commitment)
- **During charge**: Player cannot move at full speed (reduced to 60% move speed)
- **During charge**: Player is vulnerable to hits (damage taken = damage during wind-up)
- **If charge missed**: Long recovery animation (0.8s) = extended vulnerability window
- **If charged outside breakwindow**: Boss will often counter-attack during player recovery

**Anti-pattern avoided**: No safe "tap-spam" — every charge decision is a gamble on read accuracy.

### Weapon Properties
- Attack range: 1.5m (melee)
- Attack arc: 180° horizontal (wide, forgiving)
- Knockback on hit: 0.5m (creates distance for next cycle)
- Stagger duration on boss: 0.5s + (charge_multiplier * 0.25s) = 0.625s to 1.25s

### Great Sword Trait Examples (Synergy Vectors)
- "Swift Preparation": Charging speed +30%, encourages more frequent full charges
- "Delayed Bloom": Full charges store 1 bonus charge (max 2 stacked), changes stacking decision
- "Momentum": After full charge lands, gain +20% move speed for 3s (changes positioning)
- "Predictive Stance": Each successful full-charge prediction extends boss phase timer by 0.5s
- "Tenacity": Damage taken while charging reduced by 50% (enables riskier pre-positioning)

---

## 2. LONG SWORD (太刀) — PARRY-REACTION ARCHETYPE

### Moment-to-Moment Loop (30 seconds)
```
ACCUMULATE STANCE
  └─> Light attack (0.4s animation, fast recovery)
      └─> Builds 20 stance per hit (max 100 stance)
          └─> Boss prepares attack
              └─> Watch for startup tell (0.2-0.5s wind-up)
                  └─> REACT: Parry input on exact frame (frame 6-10 window)
                      └─> If SUCCESSFUL
                          ├─> Parry animation plays (0.3s)
                          ├─> Boss is stunned (0.8s)
                          ├─> Stance +25 (total bonus)
                          ├─> Player can combo during stun
                          └─> Return to ACCUMULATE
                      └─> If MISSED (too early/late)
                          ├─> Player takes hit normally
                          ├─> Stance broken (reset to 0)
                          └─> Return to ACCUMULATE (defensive)
                              └─> If stance was full (100+)
                                  ├─> Automatic counter-stance activated
                                  ├─> Negates next attack + launches counter
                                  ├─> Huge damage multiplier (2.0x next hit)
                                  └─> Return to ACCUMULATE
```

### Stance Gauge System
```
Stance Meter: 0-100 (represents counter-readiness)

Stance Building:
  └─> Light attack: +20 stance (0.4s cast, 0.2s recovery)
  └─> Medium attack: +35 stance (0.6s cast, 0.4s recovery)
  └─> Blocked hit (shield): +15 stance (defensive option)

Stance Spending:
  └─> Successful parry (6-10 frame window): -25 stance (consumes parry cost)
  └─> Failed parry (outside window): -100 stance (penalty, plus damage taken)
  └─> Full meter (100+): Automatic trigger on next boss attack
      └─> Trigger conditions:
          ├─> Any attack hits player while stance ≥100
          ├─> Stance immediately consumed (reset to 0)
          ├─> Counter-stance initiated (player invulnerable 0.4s)
          ├─> Automatic damage reflection hit (2.0x multiplier)
          └─> If parry was frame-perfect (±1 frame), bonus +50% reflected damage

Stance Decay:
  └─> If no action taken for 8 seconds: -5 stance/second decay
  └─> Encourages continuous engagement (no "wait and reset" strategy)
```

### Parry Frame Window Details (Critical Precision Mechanic)
```
Boss Attack Wind-up: 0.25-0.5s (visual tell)
  ↓
Attack Startup (recovery frames): 0.1-0.3s (small window)
  ↓
Parry Valid Window: 6-10 frames @ 60fps = 100-167ms
  ├─> Frame 0-5 (too early): Miss, player takes damage
  ├─> Frame 6-10 (HIT): Success, parry plays, stance consumed
  ├─> Frame 11+ (too late): Miss, player takes damage
  ↓
Boss Recovery: 0.3-0.8s (varies by attack)
```

**Design Rationale**: 6-10 frame window is demanding but learnable:
- Too wide (20+ frames) = trivializes parry mechanic
- Too narrow (2-3 frames) = frustration over skill expression
- 6-10 frames @ 60fps = requires ~150ms reaction time (within human capability, not easy)

### Combo System (During Parry Stun)
```
When boss is stunned (0.8s window):

Light Combo: A A A
  └─> 3x light attacks during stun
  └─> Total damage: 3x20 = 60 base + stance building
  └─> Fast, reliable

Medium Combo: A A S
  └─> 2x light + 1x special mid-combo skill
  └─> Requires trait: "Combo Surge"
  └─> Total damage: 40 + special (120-200 range)
  └─> More rewarding, tighter window

Charged Finisher: Hold A during last frame of stun
  └─> Builds into "Blade Cascade" super (costs 100 stance)
  └─> Single massive hit (300-400 damage)
  └─> Sends boss flying, resets encounter phase slightly
  └─> Used strategically to skip boss phase 2 transitions
```

### Long Sword Trait Examples (Synergy Vectors)
- "Razor Instinct": Parry window expands to 8-12 frames (slightly easier), encourages parry-heavy play
- "Cascade": Each successful parry extends next combo window by 0.1s, rewards high parry rates
- "Retribution": Parry damage reflection increased by 50%, makes defensive stance valuable
- "Blur": After successful parry, gain +30% attack speed for 2s (chain parries feel faster)
- "Anticipation": Stance decay disabled while in boss attack wind-up, rewards focused watching
- "Riposte": Each 3rd parry in a row triggers guaranteed critical (2.5x damage) on next hit

---

## 3. BOSS BEHAVIOR & BREAKWINDOW DESIGN

### Boss Attack Structure (Per Attack)
```
Attack Sequence Template:
  ├─ Wind-up animation (0.2-0.5s, visual tell)
  │   └─ Audio cue plays (critical to sound design)
  │   └─ Boss body language changes (stance shift, weapon raise, etc.)
  │   └─ Player reads this to predict attack type
  │
  ├─ Startup frames (0.1-0.3s, commitment point)
  │   └─ Attack cannot be cancelled now
  │   └─ [GREAT SWORD: Parry window starts here for some attacks]
  │   └─ [LONG SWORD: Parry frame window 6-10 during this phase]
  │
  ├─ Active frames (0.1-0.5s, hitbox active)
  │   └─ Attack connects with player if in range
  │   └─ Damage applied (varies by attack)
  │   └─ [GREAT SWORD: Some attacks have no breakwindow, only damage-avoidance]
  │
  ├─ Recovery frames (0.3-1.2s, BREAKWINDOW)
  │   └─ Boss vulnerable, cannot attack
  │   └─ Duration depends on attack power
  │   └─ Weak attacks = short breakwindow (0.3s)
  │   └─ Strong attacks = long breakwindow (1.0s+)
  │   └─ [GREAT SWORD: Charge and hit during this window]
  │   └─ [LONG SWORD: Parry usually happens in startup, combo happens in recovery]
  │
  └─ Boss stance reset, return to attack selection
```

### Example Boss Attack: "Overhead Slam" (Great Sword-exploitable)
```
Wind-up (0.4s):
  └─ Boss raises weapon overhead
  └─ Audio: Deep metallic hum
  └─ Visual: Boss body sinks (loading motion)
  └─ Player reads this as "big attack incoming, breakwindow will be long"

Startup (0.1s):
  └─ Boss begins downward arc motion
  └─ Commitment point (cannot stop now)

Active (0.2s):
  └─ Slam impact zone (2m radius around boss)
  └─ Damage: 40 HP if player caught
  └─ Knockback: 1.5m backwards

Recovery (1.2s) ← BREAKWINDOW FOR GREAT SWORD
  └─ Boss staggers, weapon stuck in ground momentarily
  └─ This is the moment for Great Sword player to:
     ├─ Pre-positioned nearby? → Charge full attack
     ├─ Full charge ready? → Release it now (150dmg = major progress)
     └─ Reward: Boss takes 3x damage, moves to next phase sooner
  └─ Long Sword player response:
     ├─ Attack missed parry window (happened in startup)
     ├─ Took 40 damage
     ├─ Now accumulate stance during recovery (safe to attack)
     └─ Build toward next automatic counter-stance trigger
```

### Example Boss Attack: "Quick Jab" (Long Sword-exploitable)
```
Wind-up (0.2s):
  └─ Boss shifts weight sideways
  └─ Audio: Whispered "hah" breath sound
  └─ Visual: Minor compared to other attacks
  └─ Player reads this as "FAST attack, parry window is NOW"

Startup (0.15s):
  └─ Boss extends weapon forward rapidly
  └─ [PARRY FRAME WINDOW 6-10 STARTS HERE]
  └─ Commitment point

Active (0.1s):
  └─ Jab impact (1m range, fast)
  └─ Damage: 20 HP if not parried
  └─ Cannot knockback (player stance broken if hit)

Recovery (0.4s) ← SHORT BREAKWINDOW (not good for Great Sword)
  └─ Boss pulls back quickly
  └─ Great Sword player: "Not enough time to charge, move on"
  └─ Long Sword player (if parry successful):
     ├─ Parry happened during recovery
     ├─ Boss stunned 0.8s
     ├─ Combo window open (guaranteed 60+ damage if player executes)
     ├─ Stance gauge +25
     └─ Reward: Damage negated, damage dealt instead
```

### Boss Phase Transitions

**Phase 1 → Phase 2**: Boss at 66% HP
- New attack introduced (faster, more complex)
- Existing attacks speed up (+25% animation speed)
- Breakwindows shrink slightly (-15% duration)
- Boss AI now uses 2-3 attack chains instead of single attacks

**Phase 2 → Phase 3**: Boss at 33% HP
- Another new attack introduced
- All attacks speed up (+25% more, cumulative -50% from Phase 1)
- Breakwindows shrink again (-15% more, -27% cumulative)
- Boss enters "berserk" mode: chains 2-4 attacks together
- **BUT**: After berserk chain, largest breakwindow appears (1.5s) = kill opportunity

---

## 4. SYNERGY & BUILD INTERACTIONS

### Great Sword Synergy Examples

**"Momentum Stack" Build**:
```
Traits: Momentum + Swift Preparation + Delayed Bloom
├─ Swift Preparation: Charge speed +30%
├─ Momentum: Full charge hit = +20% move speed 3s
└─ Delayed Bloom: Full charges store 1 bonus charge (stack to 2)

Gameplay loop:
  ├─ Full charge lands (150 dmg)
  ├─ +20% move speed 3s = faster repositioning
  ├─ Another charge ready to go (Delayed Bloom effect)
  ├─ Reposition faster due to move speed bonus
  ├─ Next breakwindow appears, release stacked charge (150 dmg again)
  └─ Playstyle: More aggressive repositioning, frequent charges

Damage ceiling: 150 + 150 = 300 dmg potential per cycle
Risk: More time spent in motion, harder to dodge attacks
```

**"Predictive Master" Build**:
```
Traits: Predictive Stance + Tenacity + Anticipation
├─ Predictive Stance: Each full charge extends phase timer +0.5s
├─ Tenacity: Damage taken while charging -50%
└─ Anticipation: No stance decay while in boss wind-up

Gameplay loop:
  ├─ Boss enters wind-up (0.4s tell)
  ├─ Player starts charging (damage taken -50% if hit during charge)
  ├─ Full charge lands (phase extends 0.5s)
  └─ More time to prepare next charge
  
Playstyle: Defensive charging, rewards reading patterns early
Damage ceiling: Lower total damage, but extended fight gives more attempts
Risk: Relies on successful reads; missed charges = wasted tenacity
```

### Long Sword Synergy Examples

**"Parry Master" Build**:
```
Traits: Razor Instinct + Cascade + Retribution
├─ Razor Instinct: Parry window 8-12 frames (easier)
├─ Cascade: Each parry extends next combo +0.1s
└─ Retribution: Parry damage +50%

Gameplay loop:
  ├─ Boss attacks, wider parry window makes it easier
  ├─ Parry lands, boss stunned 0.8s + extra 0.1s = 0.9s combo window
  ├─ Player combos, damage reflected is 50% higher
  ├─ Each successful parry triggers Cascade bonus = snowballing effect
  └─ By phase 3, parry windows feel huge, parries feel frequent
  
Playstyle: Aggressive defensive counter-play
Damage ceiling: Lower raw damage (not directly attacking), but repeated parries + bonus
Risk: If parry timing is off, all bonuses fall apart; high execution requirement
```

**"Anticipation" Build**:
```
Traits: Blur + Riposte + Anticipation
├─ Blur: Parry = +30% attack speed 2s
├─ Riposte: Every 3rd parry = critical next hit (2.5x dmg)
└─ Anticipation: Stance decay disabled in boss wind-up

Gameplay loop:
  ├─ Boss wind-up, no stance decay (can build stance safely)
  ├─ Parry successful (Anticipation prevents stance bleed)
  ├─ +30% attack speed 2s (Blur effect)
  ├─ Rapid-fire attacks during combo window
  ├─ 3rd parry in sequence → next hit is critical 2.5x
  ├─ Refresh Blur timer with another parry
  └─ Sustained "chain reaction" feeling
  
Playstyle: Rhythmic, musical flow of parries
Damage ceiling: Medium (balanced), but very satisfying
Risk: Requires consistent parry success; one miss breaks the rhythm
```

---

## 5. SKILL CURVES & LEARNING PROGRESSION

### Player Skill Stages

**Stage 1: "What is happening?" (First 15 minutes)**
- Player learning: Boss attack tells
- Action: Dodge first, attack when safe
- Great Sword: Tap attacks, no charging yet
- Long Sword: Learning parry window (lots of failures)
- Expected damage: 40-60% of boss HP per run
- Frustration point: Parry feels impossible

**Stage 2: "I see the pattern" (20-40 minutes total)**
- Player learning: Breakwindow timing
- Action: Anticipate attacks based on boss stance
- Great Sword: Beginning to charge, landing some full charges
- Long Sword: Parrying 30-40% of attacks, stance building consistency
- Expected damage: 60-80% of boss HP per run
- Confidence point: First full-charge hit lands

**Stage 3: "I can read ahead" (50-100 minutes total)**
- Player learning: Multi-attack patterns and phase transitions
- Action: Pre-positioning before boss telegraphs
- Great Sword: Full charges become common, planning 2-3 moves ahead
- Long Sword: Parrying 60-70%, executing combos, chaining parries
- Expected damage: 80-120% of boss HP per run (1-shotting bosses possible)
- Mastery point: No-hit clear attempts start

**Stage 4: "I can counter-read" (150+ minutes total)**
- Player learning: Boss attack selection patterns, phase transition exploits
- Action: Using traits to manipulate boss phase timers
- Great Sword: Stacked charges, momentum chains, repositioning feels effortless
- Long Sword: Counter-stance chains, parry -> parry -> parry sequences
- Expected damage: 150%+ of boss HP per run (carries momentum between bosses)
- Skill ceiling: Attempting challenge modes, speed-running

---

## 6. WEAPON CHOICE DYNAMICS

### When Great Sword Excels
- Boss has long, predictable attack wind-ups (0.4s+)
- Breakwindows are generous (1.0s+)
- Boss has a few attacks with massive breakwindows (kill window)
- Player prefers positioning strategy over reaction

### When Long Sword Excels
- Boss has quick, frequent attacks (0.2-0.3s wind-ups)
- Close-range engagements (player can stay near boss)
- Attack chains (parrying one attack sets up parry for next)
- Player prefers reaction timing over prediction

### Boss Design: Balanced for Both Archetypes
Each boss must be beatable by both archetypes, but offer different challenges:

**Example: "Swift" Boss**
- Great Sword challenge: Attacks are fast, breakwindows are short → must charge during very tight windows
- Long Sword advantage: Frequent attacks = frequent parry opportunities
- Expected playtime: GS (6-8 min), LS (4-6 min)
- Skill expression: GS risky but rewarding, LS safe but rhythmic

**Example: "Tanky" Boss**
- Great Sword advantage: Large breakwindows, reward full charges with massive damage
- Long Sword challenge: Fewer parry opportunities, must accumulate stance through safe light attacks
- Expected playtime: GS (4-6 min), LS (7-9 min)
- Skill expression: GS explosive, LS grinding

---

## 7. BALANCE TUNING KNOBS (For Later GDD)

These values will be refined during prototyping:

```
GREAT SWORD TUNING:
├─ base_damage: 50 (adjust for phase-time)
├─ charge_multiplier_max: 3.0 (adjust for ceiling damage)
├─ charge_time_seconds: 2.0 (adjust for feel/prediction window)
├─ light_tap_threshold: 0.3s (easy alternative)
├─ movement_speed_while_charging: 0.6x (safety trade-off)
└─ recovery_on_miss: 0.8s (punishment for bad reads)

LONG SWORD TUNING:
├─ base_light_damage: 20 (adjust for stance building rate)
├─ parry_frame_window: 6-10 (adjust for skill expression)
├─ stance_per_light_hit: 20 (adjust for meter fill rate)
├─ stance_decay_rate: 5 per second (adjust for risk of losing stance)
├─ combo_stun_duration: 0.8s (adjust for combo window tightness)
├─ counter_stance_damage_multiplier: 2.0x (adjust for defensive reward)
└─ parry_damage_reflection: 50% (adjust for defensive viability)

BOSS TUNING:
├─ phase_1_attack_speed: 1.0x (baseline)
├─ phase_2_attack_speed: 1.25x (cumulative)
├─ phase_3_attack_speed: 1.5x (total from phase 1)
├─ breakwindow_phase1: 1.0s (start generous)
├─ breakwindow_phase2: 0.85s (tighten)
├─ breakwindow_phase3: 0.7s (tight, but biggest breakwindow after berserk)
└─ berserk_breakwindow_bonus: 1.5s (kill opportunity)
```

---

## SUMMARY: COMBAT DESIGN PILLARS

1. **Great Sword** = Prediction + Positioning
   - Archetype: Aggressive predictor
   - Challenge: Reading attacks ahead
   - Mastery: Perfect charge timing

2. **Long Sword** = Reaction + Timing
   - Archetype: Defensive duelist
   - Challenge: Frame-perfect parries
   - Mastery: Chaining parries into combos

3. **Bosses** = Intelligent Opponents
   - Design priority: Clear tells > damage output
   - Phase system: Skill escalation ladder
   - Breakwindows: Rewards correct reads

4. **Traits** = Playstyle Modification
   - Bad traits: +stat numbers
   - Good traits: Change how you fight
   - Synergy: Traits combine for emergent strategies

5. **No Auto-Pilot**
   - Every action has consequences
   - Every read is a decision
   - Every miss is a learning opportunity
