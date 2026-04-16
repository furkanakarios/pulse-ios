# Pulse — Architecture

## Overview

Pulse is a local-first iOS application. There is no backend, no user accounts, no cloud sync. All data lives on the device using SwiftData. Notifications are fully local via `UNUserNotificationCenter`.

---

## Design Pattern

**MVVM (Model — View — ViewModel)**

- `Models` — SwiftData `@Model` classes, plain data structs
- `ViewModels` — `@Observable` classes that hold business logic and mediate between models and views
- `Views` — SwiftUI views, as dumb as possible, only render state from ViewModels
- `Services` — Singleton-style classes for HealthKit and Notifications (side-effect heavy, kept separate)

---

## Data Layer — SwiftData

All persistent data is stored locally via SwiftData (`ModelContainer` + `ModelContext`).

### Models

| Model | Purpose |
|-------|---------|
| `WaterEntry` | A single water intake log (amount in ml, timestamp) |
| `MealEntry` | A single meal/drink log (name, meal type, notes, timestamp) |
| `ExerciseEntry` | A single exercise session (type, duration, notes, timestamp) |
| `Habit` | A recurring habit definition (name, frequency, goal) |
| `HabitLog` | A daily completion record for a Habit |
| `Plan` | A weekly or monthly goal/roadmap item |
| `HealthNote` | A free-text note (doctor advice, health history, etc.) |

### Relationships

```
Habit  ──< HabitLog   (one habit has many daily logs)
```

All other models are independent daily log entries, queried by date range.

---

## Notification Layer — UNUserNotificationCenter

Managed by `NotificationService` (singleton).

- All notifications are **local** — no push, no server
- Notification types:
  - Water reminders (repeating, configurable interval)
  - Habit reminders (daily at a set time)
  - Custom plan reminders
- Permissions requested on first launch
- User can configure schedule in Settings

---

## HealthKit Layer

Managed by `HealthKitService` (singleton).

- **Read:** Steps, active energy burned, workouts, sleep analysis
- **Write:** Workouts logged in Pulse can optionally be saved to Apple Health
- Permissions requested on first use of HealthKit features
- HealthKit data is displayed as supplemental info on Dashboard — not stored in SwiftData

### Required Info.plist Keys

```
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
```

---

## Navigation

Tab-based navigation with 5 primary tabs:

```
TabView
├── Dashboard
├── Log (Water / Nutrition / Exercise — segmented)
├── Habits
├── Plans
└── More (Notes, Settings, HealthKit)
```

---

## State Management

- `@Environment(\.modelContext)` passed through SwiftUI environment for SwiftData access
- `@Query` used directly in views for simple data reads
- `@Observable` ViewModels for complex state (e.g. dashboard aggregations, notification scheduling)
- No third-party state management libraries

---

## Security & Privacy

- No network requests — zero data leaves the device
- No analytics, no tracking
- HealthKit permissions are granular — user chooses what to share
- `.gitignore` excludes all sensitive files (certs, provisioning profiles, API keys)
