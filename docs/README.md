# RallyOps App Documentation

This folder contains documentation for the **rallyops** app—a personal companion for turning dreams into reality through meaningful life rallyops, milestones, and habits.

## Overview

The rallyops app is a SwiftUI + SwiftData iOS/macOS application that helps users:

1. **Define Core Values** — Life principles that guide their choices
2. **Set Milestones** — Time-bound rallyops tied to each core value
3. **Track Actions** — One-time tasks with due dates
4. **Build Habits** — Recurring behaviors with day-of-week schedules and daily check-ins

## Documentation Index

| Document | Description |
|----------|-------------|
| [Architecture](architecture.md) | Data models, app structure, and persistence |
| [Core Values](core-values.md) | Creating and managing core values |
| [Milestones](milestones.md) | Creating milestones, adding actions and habits |
| [Actions](actions.md) | Action items, due dates, completion tracking |
| [Habits](habits.md) | Recurring habits, check-ins, and routines |
| [Today View](today-view.md) | Daily view, date navigation, and routines |
| [Calendar](calendar.md) | Date selection and navigation |
| [Settings](settings.md) | App settings and debug tools |
| [Onboarding](onboarding.md) | First goal walkthrough and create goal flow |
| [Testing](testing.md) | Unit tests and date helpers |
| [Theme](theme.md) | Design system, colors, typography, spacing, and view modifiers |
| [Data Helpers](data-helpers.md) | Extensions, utility methods, and helper functions |

## Quick Start

The app launches to a tabbed interface:

- **Today** — Actions and habits for the selected date
- **Milestones** — Browse milestones by core value
- **Core Values** — List and manage core values

## Tech Stack

- **UI:** SwiftUI
- **Persistence:** SwiftData
- **Platforms:** iOS, macOS (Settings available as native macOS Settings panel)
