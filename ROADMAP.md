# Pulse — Roadmap

## Phase 1 — Foundation (MVP) ✅

> Core tracking features, local data, basic UI

- [x] Xcode project setup (SwiftUI, SwiftData, iOS 17+)
- [x] SwiftData models: WaterEntry, MealPlan, MealGroup, MealItem, MealLog, ExerciseEntry, Habit, HabitLog, Plan, HealthNote
- [x] Tab navigation structure
- [x] Dashboard screen (daily summary)
- [x] Water tracking — log intake, daily goal progress
- [x] Nutrition log — program bazlı, çoklu program, öğün grupları, günlük tamamlama
- [x] Exercise log — add/view sessions by day
- [x] Habit tracker — daily checklist + streak counter
- [x] Health notes — free text, list view
- [x] Settings — daily goals, notification preferences

## Phase 2 — Notifications ✅

> Smart local reminders

- [x] NotificationService setup
- [x] Water reminder (repeating interval, configurable)
- [x] Habit reminder (daily time, per habit)
- [x] Morning summary notification
- [x] Permission request flow (first launch)

## Phase 3 — HealthKit Integration ✅

> Read from and write to Apple Health

- [x] HealthKitService setup
- [x] Request permissions (steps, calories, workouts, sleep)
- [x] Display step count on Dashboard
- [x] Display active calories on Dashboard
- [x] Optionally write exercise sessions to HealthKit
- [x] Sleep data view

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
