import Foundation
import SwiftData

@MainActor
final class AchievementService {
    static let shared = AchievementService()
    private init() {}

    // MARK: - Public: evaluate & unlock

    /// Tüm başarımları değerlendirir, yeni kazanılanları unlock eder,
    /// hedefe yaklaşanlara bildirim gönderir.
    func evaluate(context: ModelContext) {
        let waterEntries    = fetch(WaterEntry.self, from: context)
        let exerciseEntries = fetch(ExerciseEntry.self, from: context)
        let mealPlans       = fetch(MealPlan.self, from: context)
        let habits          = fetch(Habit.self, from: context)
        let existing        = fetch(Achievement.self, from: context)

        let dailyWaterGoal    = UserDefaults.standard.double(forKey: "dailyWaterGoal").positive(or: 2500)
        let dailyExerciseGoal = UserDefaults.standard.double(forKey: "dailyExerciseGoal").positive(or: 30)

        for def in AchievementDefinition.all {
            let record = existing.first { $0.key == def.key } ?? {
                let a = Achievement(key: def.key)
                context.insert(a)
                return a
            }()

            // Önceki günde kazanıldıysa kalıcı — dokunma
            if let unlockedAt = record.unlockedAt,
               !Calendar.current.isDateInToday(unlockedAt) {
                continue
            }

            let progress = computeProgress(
                key: def.key,
                waterEntries: waterEntries,
                exerciseEntries: exerciseEntries,
                mealPlans: mealPlans,
                habits: habits,
                waterGoal: dailyWaterGoal,
                exerciseGoal: dailyExerciseGoal
            )

            if progress >= def.totalSteps {
                // Yeni kazanıldıysa tarihi yaz; bugün zaten kazanılmışsa gerek yok
                if record.unlockedAt == nil {
                    record.unlockedAt = .now
                }
            } else {
                // Bugün kazanıldı ama koşul artık sağlanmıyorsa geri al
                if let unlockedAt = record.unlockedAt,
                   Calendar.current.isDateInToday(unlockedAt) {
                    record.unlockedAt = nil
                }
            }

            if !record.isUnlocked,
               def.notifyAtProgress > 0,
               progress >= def.notifyAtProgress,
               record.notifiedProgress < progress {
                record.notifiedProgress = progress
                let remaining = def.totalSteps - progress
                let body = remaining == 1
                    ? "Yarın da devam edersen \"\(def.title)\" başarımını kazanacaksın! 🏆"
                    : "\(remaining) adım daha ve \"\(def.title)\" başarımı senindir!"
                NotificationService.shared.scheduleAchievementProgressNotification(
                    title: "Hedefe yaklaşıyorsun 🎯",
                    body: body,
                    identifier: "com.pulse.achievement.progress.\(def.key)"
                )
            }
        }

        try? context.save()
    }

    // MARK: - Public: current progress for UI

    func currentProgress(for key: String, context: ModelContext) -> Int {
        let waterEntries    = fetch(WaterEntry.self, from: context)
        let exerciseEntries = fetch(ExerciseEntry.self, from: context)
        let mealPlans       = fetch(MealPlan.self, from: context)
        let habits          = fetch(Habit.self, from: context)
        let waterGoal    = UserDefaults.standard.double(forKey: "dailyWaterGoal").positive(or: 2500)
        let exerciseGoal = UserDefaults.standard.double(forKey: "dailyExerciseGoal").positive(or: 30)

        return computeProgress(
            key: key,
            waterEntries: waterEntries,
            exerciseEntries: exerciseEntries,
            mealPlans: mealPlans,
            habits: habits,
            waterGoal: waterGoal,
            exerciseGoal: exerciseGoal
        )
    }

    // MARK: - Core logic

    private func computeProgress(
        key: String,
        waterEntries: [WaterEntry],
        exerciseEntries: [ExerciseEntry],
        mealPlans: [MealPlan],
        habits: [Habit],
        waterGoal: Double,
        exerciseGoal: Double
    ) -> Int {
        let cal = Calendar.current

        switch key {

        // MARK: Water
        case "water_first":
            return waterEntries.isEmpty ? 0 : 1

        case "water_daily_goal":
            let todayML = waterEntries
                .filter { cal.isDateInToday($0.date) }
                .reduce(0.0) { $0 + $1.amount }
            return todayML >= waterGoal ? 1 : 0

        case "water_streak_3":
            return min(waterStreak(entries: waterEntries, goal: waterGoal), 3)
        case "water_streak_7":
            return min(waterStreak(entries: waterEntries, goal: waterGoal), 7)
        case "water_streak_30":
            return min(waterStreak(entries: waterEntries, goal: waterGoal), 30)

        case "water_total_50L":
            let liters = Int(waterEntries.reduce(0.0) { $0 + $1.amount } / 1000.0)
            return min(liters, 50)
        case "water_total_100L":
            let liters = Int(waterEntries.reduce(0.0) { $0 + $1.amount } / 1000.0)
            return min(liters, 100)

        // MARK: Exercise
        case "exercise_first":
            return exerciseEntries.isEmpty ? 0 : 1

        case "exercise_daily_goal":
            let todayMins = exerciseEntries
                .filter { cal.isDateInToday($0.date) }
                .reduce(0) { $0 + $1.duration }
            return todayMins >= Int(exerciseGoal) ? 1 : 0

        case "exercise_streak_3":
            return min(exerciseStreak(entries: exerciseEntries, goalMinutes: Int(exerciseGoal)), 3)
        case "exercise_streak_7":
            return min(exerciseStreak(entries: exerciseEntries, goalMinutes: Int(exerciseGoal)), 7)
        case "exercise_streak_30":
            return min(exerciseStreak(entries: exerciseEntries, goalMinutes: Int(exerciseGoal)), 30)

        case "exercise_total_10h":
            let hours = Int(exerciseEntries.reduce(0) { $0 + $1.duration }) / 60
            return min(hours, 10)

        // MARK: Nutrition
        case "nutrition_first":
            let activePlan = mealPlans.first { $0.isActive }
            guard let plan = activePlan else { return 0 }
            let anyCompleted = plan.groups.contains { !$0.logs.filter { $0.isCompleted }.isEmpty }
            return anyCompleted ? 1 : 0

        case "nutrition_daily_complete":
            return nutritionAllCompletedToday(plans: mealPlans) ? 1 : 0

        case "nutrition_streak_3":
            return min(nutritionStreak(plans: mealPlans), 3)
        case "nutrition_streak_7":
            return min(nutritionStreak(plans: mealPlans), 7)
        case "nutrition_streak_30":
            return min(nutritionStreak(plans: mealPlans), 30)

        // MARK: Habit
        case "habit_first_created":
            return habits.filter { !$0.isArchived }.isEmpty ? 0 : 1

        case "habit_daily_complete":
            return allHabitsCompletedOn(.now, habits: habits) ? 1 : 0

        case "habit_streak_7":
            return min(allHabitsStreak(habits: habits), 7)
        case "habit_streak_30":
            return min(allHabitsStreak(habits: habits), 30)

        // MARK: General
        case "general_perfect_day":
            return isPerfectDay(
                .now,
                waterEntries: waterEntries,
                exerciseEntries: exerciseEntries,
                mealPlans: mealPlans,
                habits: habits,
                waterGoal: waterGoal,
                exerciseGoal: exerciseGoal
            ) ? 1 : 0

        case "general_perfect_week":
            return min(perfectDayStreak(
                waterEntries: waterEntries,
                exerciseEntries: exerciseEntries,
                mealPlans: mealPlans,
                habits: habits,
                waterGoal: waterGoal,
                exerciseGoal: exerciseGoal
            ), 7)

        default:
            return 0
        }
    }

    // MARK: - Streak helpers

    private func waterStreak(entries: [WaterEntry], goal: Double) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while true {
            let total = entries
                .filter { cal.isDate($0.date, inSameDayAs: day) }
                .reduce(0.0) { $0 + $1.amount }
            guard total >= goal else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    private func exerciseStreak(entries: [ExerciseEntry], goalMinutes: Int) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while true {
            let total = entries
                .filter { cal.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.duration }
            guard total >= goalMinutes else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    private func nutritionAllCompletedToday(plans: [MealPlan]) -> Bool {
        guard let plan = plans.first(where: { $0.isActive }),
              !plan.groups.isEmpty else { return false }
        return plan.groups.allSatisfy { $0.isCompleted(on: .now) }
    }

    private func nutritionStreak(plans: [MealPlan]) -> Int {
        guard let plan = plans.first(where: { $0.isActive }),
              !plan.groups.isEmpty else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while true {
            guard plan.groups.allSatisfy({ $0.isCompleted(on: day) }) else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    private func allHabitsCompletedOn(_ date: Date, habits: [Habit]) -> Bool {
        let active = habits.filter { !$0.isArchived }
        guard !active.isEmpty else { return false }
        let cal = Calendar.current
        return active.allSatisfy { habit in
            habit.logs.contains { $0.isCompleted && cal.isDate($0.date, inSameDayAs: date) }
        }
    }

    private func allHabitsStreak(habits: [Habit]) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while true {
            guard allHabitsCompletedOn(day, habits: habits) else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    private func isPerfectDay(
        _ date: Date,
        waterEntries: [WaterEntry],
        exerciseEntries: [ExerciseEntry],
        mealPlans: [MealPlan],
        habits: [Habit],
        waterGoal: Double,
        exerciseGoal: Double
    ) -> Bool {
        let cal = Calendar.current
        let waterOK = waterEntries
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .reduce(0.0) { $0 + $1.amount } >= waterGoal
        let exerciseOK = exerciseEntries
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.duration } >= Int(exerciseGoal)
        let nutritionOK: Bool = {
            guard let plan = mealPlans.first(where: { $0.isActive }),
                  !plan.groups.isEmpty else { return false }
            return plan.groups.allSatisfy { $0.isCompleted(on: date) }
        }()
        let habitOK = allHabitsCompletedOn(date, habits: habits)
        return waterOK && exerciseOK && nutritionOK && habitOK
    }

    private func perfectDayStreak(
        waterEntries: [WaterEntry],
        exerciseEntries: [ExerciseEntry],
        mealPlans: [MealPlan],
        habits: [Habit],
        waterGoal: Double,
        exerciseGoal: Double
    ) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while true {
            guard isPerfectDay(
                day,
                waterEntries: waterEntries,
                exerciseEntries: exerciseEntries,
                mealPlans: mealPlans,
                habits: habits,
                waterGoal: waterGoal,
                exerciseGoal: exerciseGoal
            ) else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    // MARK: - Fetch helper

    private func fetch<T: PersistentModel>(_ type: T.Type, from context: ModelContext) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }
}

// MARK: - Double helper

private extension Double {
    func positive(or fallback: Double) -> Double {
        self > 0 ? self : fallback
    }
}
