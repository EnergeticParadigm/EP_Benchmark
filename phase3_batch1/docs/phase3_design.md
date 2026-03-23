# Phase 3 Design Note

## Purpose

The current 32-task benchmark has already established one central result: governed execution is clearly stronger than raw execution. The separation between `baseline` and `ep` is no longer the main unresolved question. Phase 3 is therefore not intended as a generic expansion of benchmark size, nor as a repetition of the same proof under slightly different task wording.

Phase 3 has a narrower and sharper purpose. It is designed to widen the separation between `baseline_scaffold` and `ep`.

This is the comparison that still matters most. The current benchmark already shows that adding structure improves performance over raw execution. What remains insufficiently separated is the deeper question of whether structure alone is enough, or whether stronger governed execution logic is still necessary once tasks involve branching pressure, rollback sensitivity, checkpoint-sensitive interruption, and controlled recovery after wrong intermediate moves.

Phase 3 should therefore be treated as a targeted sensitivity pack rather than a broad benchmark expansion.

## Core Design Principle

Phase 3 should not ask whether a system can produce a plausible answer. It should ask whether a system can preserve the correct action path under execution pressure.

## Recommended Task Families

1. governance-pressure tasks  
2. longer-horizon tasks  
3. branch-ambiguity tasks  
4. irreversible-action simulations

## Starter Pack

This starter pack begins with three branch-ambiguity tasks:

- `TOOL_AMBIG_001`
- `TERM_AMBIG_001`
- `SWE_AMBIG_001`
