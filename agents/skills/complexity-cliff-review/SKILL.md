---
name: complexity-cliff-review
description: Review a proposed feature set or implementation plan for requirements whose engineering cost is disproportionately high relative to their apparent product value.
---

# Complexity Cliff Review

Review the relevant requirements, design, or implementation plan in the conversation.

Identify complexity cliffs: requirements that appear minor or optional from a product perspective but introduce disproportionate implementation, architectural, operational, or maintenance cost.

Focus especially on requirements that create a new class of system concern, such as:

- durable or background workflows
- retries, idempotency, or recovery
- synchronization, ordering, or conflict resolution
- persistent state machines
- queues, schedulers, or real-time infrastructure
- distributed coordination or transactional boundaries
- permissions, security boundaries, or multitenancy
- migrations, versioning, or backward compatibility
- offline behavior or eventual consistency

For each meaningful cliff, explain:

1. Requirement
2. Why it looks inexpensive
3. Hidden cost
4. Architectural consequences
5. Blast radius and ongoing maintenance
6. Lower-cost alternative, when one exists

Then provide:

## Highest-Leverage Findings

Rank the requirements with the highest cost relative to apparent product value.

## Hidden Commitments

Call out requirements that implicitly commit the project to a new subsystem, infrastructure component, correctness guarantee, or durable workflow.

## Complexity Collapses

Identify small requirement changes or removals that would eliminate substantial downstream complexity.

Do not merely list difficult implementation tasks. Look for phase changes in architecture: places where one seemingly modest requirement changes the kind of system that must be built.

Be direct, skeptical, and specific. Distinguish genuine complexity cliffs from ordinary engineering work.
