# Pulse — Roadmap

## Phase 1 — Foundation (MVP)

> Core tracking features, local data, basic UI

- [ ] Xcode project setup (SwiftUI, SwiftData, iOS 17+)
- [ ] SwiftData models: WaterEntry, MealEntry, ExerciseEntry, Habit, HabitLog, Plan, HealthNote
- [ ] Tab navigation structure
- [ ] Dashboard screen (daily summary)
- [ ] Water tracking — log intake, daily goal progress
- [ ] Nutrition log — add/view meals by day
- [ ] Exercise log — add/view sessions by day
- [ ] Habit tracker — daily checklist + streak counter
- [ ] Health notes — free text, list view
- [ ] Settings — daily goals, notification preferences

## Phase 2 — Notifications

> Smart local reminders

- [ ] NotificationService setup
- [ ] Water reminder (repeating interval, configurable)
- [ ] Habit reminder (daily time, per habit)
- [ ] Morning summary notification
- [ ] Permission request flow (first launch)

## Phase 3 — HealthKit Integration

> Read from and write to Apple Health

- [ ] HealthKitService setup
- [ ] Request permissions (steps, calories, workouts, sleep)
- [ ] Display step count on Dashboard
- [ ] Display active calories on Dashboard
- [ ] Optionally write exercise sessions to HealthKit
- [ ] Sleep data view

## Phase 4 — Plans & Roadmap

> Weekly and monthly goal planning

- [ ] Plan model and CRUD
- [ ] Weekly plan view
- [ ] Monthly roadmap view
- [ ] Progress tracking per plan item

## Phase 5 — Polish & App Store

> Refinement before potential App Store release

- [ ] App icon design
- [ ] Launch screen
- [ ] Onboarding flow
- [ ] Widget (water/habit quick glance)
- [ ] iCloud sync (SwiftData + CloudKit entitlement)
- [ ] iPad support (optional)
- [ ] App Store metadata, screenshots
- [ ] TestFlight beta
