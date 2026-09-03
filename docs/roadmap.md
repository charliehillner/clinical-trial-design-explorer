# Clinical Trial Design Explorer — Roadmap

The Clinical Trial Design Explorer is developed incrementally.

The goal is not to build a comprehensive clinical trial design platform as
quickly as possible. Instead, each milestone should result in a coherent,
usable and explainable statistical exploration tool.

---

## Guiding Principles

Every feature should contribute to at least one of the following goals:

1. **Scientific correctness**  
   Statistical results should be based on established methodology.

2. **Interactive exploration**  
   Users should be able to investigate how design decisions affect statistical
   properties.

3. **Explainability**  
   The application should explain not only what happens, but why it happens and
   which trade-offs are involved.

4. **Clean architecture**  
   Statistical domain logic, explanation logic and presentation should remain
   separated.

---

# Milestone 1 — Group Sequential Design Explorer

**Goal:** Provide a polished and explainable environment for exploring classical
group sequential efficacy boundaries.

## Statistical Core

- [x] O'Brien–Fleming boundaries
- [x] Pocock boundaries
- [x] One-sided designs
- [x] Two-sided designs
- [x] Adjustable number of analyses
- [x] Equally spaced information times
- [x] Custom information times
- [x] Fixed-design reference boundary
- [x] Alpha-spending calculation

## Visualization

- [x] Boundary plot
- [x] Boundary result table
- [ ] Alpha-spending visualization
- [ ] Summary cards
- [ ] Improve plot annotations and readability

## Explainability

- [x] Context-aware explanation engine
- [x] Current-design interpretation
- [x] Statistical rationale
- [x] Qualitative trade-off assessment
- [x] Interactive "Try this next" suggestions
- [ ] Refine explanation rules
- [ ] Explain alpha spending visually
- [ ] Add contextual comparison with alternative designs
- [ ] Add tests for explanation rules

## Software Quality

- [x] Modular Shiny architecture
- [x] Domain-specific design result object
- [x] Separate explanation object
- [x] Initial `testthat` suite
- [ ] Move validation into dedicated domain module
- [ ] Expand tests for edge cases
- [ ] Add automated checks / CI

## Presentation

- [x] Project README
- [x] Architecture documentation
- [ ] Final UI polish
- [ ] Responsive layout review
- [ ] Application screenshots
- [ ] Demonstration GIF
- [ ] Deployment

### Definition of Done

Milestone 1 is complete when a user can configure a group sequential design,
understand its efficacy boundaries and alpha allocation, and receive a
context-aware explanation of the statistical rationale and trade-offs.

---

# Milestone 2 — Comparative Design Exploration

**Goal:** Allow users to understand how different group sequential strategies
behave under the same trial assumptions.

- [ ] Side-by-side O'Brien–Fleming vs. Pocock comparison
- [ ] Comparative boundary visualization
- [ ] Comparative alpha-spending visualization
- [ ] Explain differences between competing designs
- [ ] Additional alpha-spending functions
- [ ] Power calculation
- [ ] Sample-size implications
- [ ] Stopping probabilities by analysis

---

# Milestone 3 — Trial Simulation

**Goal:** Connect theoretical design properties with simulated trial outcomes.

- [ ] Simulate trial trajectories
- [ ] Visualize sequential test statistics
- [ ] Demonstrate early efficacy stopping
- [ ] Estimate operating characteristics by simulation
- [ ] Compare empirical and theoretical Type I error
- [ ] Compare empirical power across designs
- [ ] Explain individual simulated trial decisions

---

# Milestone 4 — Time-to-Event Designs

**Goal:** Extend the explorer toward common clinical trial endpoints.

- [ ] Survival data simulation
- [ ] Kaplan–Meier visualization
- [ ] Logrank testing
- [ ] Event-driven information
- [ ] Group sequential survival designs
- [ ] Explain events vs. sample size in survival trials

---

# Future Research Extensions

Potential long-term extensions include:

- adaptive designs
- sample-size re-estimation
- population selection
- multiple populations
- multiple testing
- advanced error-rate control

These features intentionally remain outside the current project scope until the
core explorer is complete.

---

# Release Strategy

Development follows a simple rule:

> **Finish depth before adding breadth.**

A milestone should be polished, tested, documented and demonstrable before a
new statistical domain is introduced.
