# Clinical Trial Design Explorer

An interactive R Shiny application for exploring group sequential clinical trial designs.

---

## Motivation

Clinical trial design is one of the fundamental disciplines of biostatistics. While established statistical software provides powerful tools for designing and analyzing clinical trials, these tools often focus on computation rather than understanding.

The goal of this project is not to replace professional software such as `gsDesign` or `rpact`. Instead, it aims to create an interactive environment in which users can explore statistical concepts, understand their underlying rationale, and develop intuition about the trade-offs involved in different trial designs.

This project focuses on making statistical methodology **visible**, **interactive**, and **explainable**.

---

# Philosophy

This application follows three guiding principles.

## 1. Scientific correctness

All statistical calculations are based on established methodology and implemented using validated statistical software whenever appropriate.

The project intentionally builds upon existing scientific work instead of reimplementing well-established numerical algorithms.

---

## 2. Interactive exploration

Rather than presenting static results, the application allows users to actively modify design parameters and immediately observe how these changes affect the statistical properties of a clinical trial.

The objective is to encourage exploration instead of passive observation.

---

## 3. Explainability

Most statistical software answers the question:

> **What is the result?**

This project additionally aims to answer:

> **Why does this result occur?**

Every visualization should eventually provide:

- an intuitive explanation
- the underlying statistical rationale
- the trade-offs implied by the selected design
- practical implications for clinical trials

---

# Project Goals

The application is designed around the following objectives.

- Interactive exploration of statistical methods
- Scientifically correct implementation
- Clean and modular software architecture
- Reusable visualization components
- Separation of statistical computation and presentation
- Educational value through contextual explanations

---

# Architecture

The application is intentionally divided into independent layers.

```text
User Input
      │
      ▼
Design Parameters
      │
      ▼
Statistical Engine
      │
      ▼
Result Object
      │
      ├──────────────┐
      ▼              ▼
Boundary Plot   Results Table
      │
      ▼
Future Explanation Modules
```

Each layer has exactly one responsibility.

## Design Parameters

Responsible for collecting and validating all user-defined trial settings.

Examples include:

- significance level
- number of analyses
- information times
- stopping boundary
- one-sided or two-sided testing

---

## Statistical Engine

Transforms validated parameters into a statistical design using established statistical methodology.

Currently this layer wraps the `gsDesign` package while hiding implementation-specific details from the user interface.

---

## Result Object

The statistical engine produces a domain-specific result object.

This object represents the public interface between statistical computation and the visualization layer.

Because every visualization consumes the same result object, new UI components can be added without modifying the statistical backend.

---

## Visualization Modules

Visualization modules are intentionally independent from the statistical implementation.

Examples include:

- Boundary Plot
- Results Table
- Summary Cards
- Explanation Panels
- Future Interactive Visualizations

Each module only consumes the result object.

---

# Why a Result Object?

The statistical backend is intentionally encapsulated behind a domain-specific result object instead of exposing package-specific structures throughout the application.

This provides several advantages:

- separation of concerns
- easier testing
- interchangeable statistical backends
- reusable visualization components
- cleaner software architecture

As a result, the user interface does not depend directly on the implementation details of the underlying statistical library.

---

# Explainability

The central idea of this project is that statistical software should not only perform calculations but also support understanding.

For example, an efficacy boundary should not merely be displayed.

The application should additionally explain

- why the boundary has this shape,
- how the selected design allocates the overall Type I error,
- which trade-offs are introduced,
- and how these decisions affect the interpretation of a clinical trial.

Future versions therefore aim to provide dynamic explanations that adapt to the currently selected design.

---

# Current Features

- Group sequential designs
- O'Brien–Fleming boundaries
- Pocock boundaries
- One-sided and two-sided testing
- Adjustable number of analyses
- Adjustable information times
- Boundary visualization
- Summary tables
- Automated unit tests using `testthat`

---

# Planned Features

- Alpha spending visualization
- Dynamic explanation panel
- Sample size calculation
- Power analysis
- Kaplan–Meier simulation
- Survival endpoint support
- Adaptive designs
- Export of trial summaries
- Interactive educational examples

---

# Technologies

- R
- Shiny
- bslib
- gsDesign
- ggplot2
- testthat

---

# Vision

Clinical Trial Design Explorer is part of a broader collection of interactive applications whose purpose is to make mathematical and statistical models easier to explore, understand, and communicate.

Rather than serving as simple calculators, these applications are designed as **interactive exploration tools** that combine scientific correctness with intuitive visualization and contextual explanation.

The long-term goal is to help bridge the gap between statistical methodology and human understanding.