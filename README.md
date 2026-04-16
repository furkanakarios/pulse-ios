# Pulse

A personal health, habit & wellness tracker for iOS — built with SwiftUI and SwiftData.

Pulse helps you stay consistent with your health goals by tracking water intake, nutrition, exercise, daily habits, and health notes — all in one place, with smart local notifications.

---

## Features

- **Dashboard** — Daily overview: water, nutrition, exercise, active habits, streaks
- **Water Tracking** — Log intake, set daily goals, get reminder notifications
- **Nutrition Log** — Meal entries with food/drink details per day
- **Exercise Log** — Activity entries with type, duration, and notes
- **Habit Tracker** — Daily checklist with streak tracking
- **Plans & Roadmap** — Weekly/monthly health goals
- **Health Notes** — Store doctor/dietitian advice, personal health history
- **HealthKit Integration** — Sync steps, calories, and workouts with Apple Health
- **Local Notifications** — Fully offline reminders, no backend required

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| Data | SwiftData |
| Notifications | UserNotifications |
| Health | HealthKit |
| Minimum iOS | 17.0 |
| Language | Swift 5.9+ |

---

## Project Structure

```
Pulse/
├── App/
│   └── PulseApp.swift
├── Models/
│   ├── WaterEntry.swift
│   ├── MealEntry.swift
│   ├── ExerciseEntry.swift
│   ├── Habit.swift
│   ├── HabitLog.swift
│   ├── Plan.swift
│   └── HealthNote.swift
├── Views/
│   ├── Dashboard/
│   ├── Water/
│   ├── Nutrition/
│   ├── Exercise/
│   ├── Habits/
│   ├── Plans/
│   ├── Notes/
│   └── Settings/
├── ViewModels/
├── Services/
│   ├── NotificationService.swift
│   └── HealthKitService.swift
└── Utilities/
```

---

## Getting Started

1. Clone the repo
2. Open `Pulse.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Enable HealthKit capability
5. Run on device or simulator (iOS 17+)

---

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the full development plan.

---

## License

Personal use. All rights reserved.
