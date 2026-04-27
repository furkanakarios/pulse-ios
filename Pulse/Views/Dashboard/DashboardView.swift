//
//  DashboardView.swift
//  Pulse — V2 Stack redesign (drop-in replacement)
//
//  Same public API as your previous DashboardView (parameterless init).
//  Wire up the @Query / @AppStorage / HealthKit calls noted in `BIND:` comments
//  to your existing data sources. Pure SwiftUI — no third-party deps. iOS 17+.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: - Data Sources (BIND: wired to real SwiftData queries)
    @Query private var waterEntries: [WaterEntry]
    @Query private var mealPlans: [MealPlan]
    @Query private var mealLogs: [MealLog]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]

    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoalD: Double = 30

    @State private var hkSteps: Double = 0
    @State private var hkCalories: Double = 0
    @State private var sleepData: SleepData? = nil
    @State private var showSettings = false
    @State private var showHabits = false
    @State private var showWeekly = false
    @State private var showMonthly = false

    // MARK: - Computed properties (real data)
    private var waterIntakeML: Int {
        waterEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + Int($1.amount) }
    }

    private var activePlan: MealPlan? { mealPlans.first { $0.isActive } }

    private var mealsCompleted: Int {
        mealLogs.filter { Calendar.current.isDateInToday($0.date) && $0.isCompleted }.count
    }

    private var mealsTotal: Int { activePlan?.groups.count ?? 0 }

    private var exerciseMinutes: Int {
        exerciseEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.duration }
    }

    private var exerciseGoalMinutes: Int { Int(dailyExerciseGoalD) }

    private var hourlyExerciseBuckets: [Int] {
        var buckets = [Int](repeating: 0, count: 12)
        for entry in exerciseEntries where Calendar.current.isDateInToday(entry.date) {
            let h = Calendar.current.component(.hour, from: entry.date)
            let slot = min(h / 2, 11)
            buckets[slot] += entry.duration
        }
        return buckets
    }

    private var activeHabits: [Habit] { habits.filter { !$0.isArchived } }

    private var habitsDoneList: [Bool] {
        activeHabits.map { habit in
            habitLogs.contains {
                $0.habit?.id == habit.id &&
                Calendar.current.isDateInToday($0.date) &&
                $0.isCompleted
            }
        }
    }

    private var habitsDone: Int { habitsDoneList.filter { $0 }.count }
    private var habitsTotal: Int { activeHabits.count }
    private var longestStreakDays: Int { habits.map { $0.streak }.max() ?? 0 }

    // Weekly water ratios (0…1) for each of the 7 days starting Monday
    private var weeklyWaterRatios: [Double] {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now))!
        return (0..<7).map { offset in
            guard let day = cal.date(byAdding: .day, value: offset, to: startOfWeek),
                  day <= .now else { return 0.0 }
            let ml = waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0.0) { $0 + $1.amount }
            return dailyWaterGoal > 0 ? min(1.0, ml / dailyWaterGoal) : 0
        }
    }

    // Monthly exercise per-week ratios (4 buckets), normalized to max
    private var monthlyExerciseWeekRatios: [Double] {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: .now))!
        let range = cal.range(of: .day, in: .month, for: startOfMonth)!
        var weeks = [0.0, 0.0, 0.0, 0.0]
        for d in range {
            guard let day = cal.date(byAdding: .day, value: d - 1, to: startOfMonth),
                  day <= .now else { continue }
            let mins = Double(exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.duration })
            weeks[min(3, (d - 1) / 7)] += mins
        }
        let maxVal = max(weeks.max() ?? 1, 1)
        return weeks.map { $0 / maxVal }
    }

    private var weekRangeLabel: String {
        let cal = Calendar.current
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "d MMM"
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now))!
        let end = cal.date(byAdding: .day, value: 6, to: start)!
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }

    private var monthLabel: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "MMMM yyyy"
        return f.string(from: .now).capitalized
    }

    private var stepsToday: String {
        hkSteps > 0 ? String(format: "%.0f", hkSteps) : "—"
    }
    private var caloriesToday: String {
        hkCalories > 0 ? "\(Int(hkCalories))" : "—"
    }
    private var sleepToday: String {
        sleepData?.formattedDuration ?? "—"
    }

    private var overallPercent: Int {
        var scores: [Double] = []
        let waterPct = dailyWaterGoal > 0 ? min(Double(waterIntakeML) / dailyWaterGoal, 1.0) : 0
        scores.append(waterPct)
        if mealsTotal > 0 { scores.append(min(Double(mealsCompleted) / Double(mealsTotal), 1.0)) }
        if exerciseGoalMinutes > 0 { scores.append(min(Double(exerciseMinutes) / Double(exerciseGoalMinutes), 1.0)) }
        if habitsTotal > 0 { scores.append(min(Double(habitsDone) / Double(habitsTotal), 1.0)) }
        guard !scores.isEmpty else { return 0 }
        return Int((scores.reduce(0, +) / Double(scores.count) * 100).rounded())
    }

    // Routing intents the parent NavigationStack can listen to (or push directly).
    var onOpenWater: (() -> Void)? = nil
    var onOpenNutrition: (() -> Void)? = nil
    var onOpenExercise: (() -> Void)? = nil
    var onOpenHabits: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                editorialHeader
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 18)

                // 01 — Water
                DashboardStackCard(
                    tag: "01 · Su",
                    color: .pulseWater,
                    big: String(format: "%.1f", Double(waterIntakeML) / 1000.0),
                    unit: "L",
                    sub: "\(formatLiters(dailyWaterGoal)) L hedefin %\(percent(waterIntakeML, Int(dailyWaterGoal)))'sinde",
                    cta: "Su ekle",
                    onTap: { onOpenWater?() },
                    visual: { DashboardWaveBar(pct: ratio(waterIntakeML, Int(dailyWaterGoal)), color: .pulseWater) }
                )
                .padding(.horizontal, 22).padding(.bottom, 14)

                // 02 — Nutrition
                DashboardStackCard(
                    tag: "02 · Beslenme",
                    color: .pulseNutrition,
                    big: "\(mealsCompleted)/\(mealsTotal)",
                    sub: nutritionSub,
                    cta: "Öğün kaydet",
                    onTap: { onOpenNutrition?() },
                    visual: { DashboardMealDots(done: mealsCompleted, total: max(mealsTotal, 1), color: .pulseNutrition) }
                )
                .padding(.horizontal, 22).padding(.bottom, 14)

                // 03 — Exercise
                DashboardStackCard(
                    tag: "03 · Egzersiz",
                    color: .pulseExercise,
                    big: "\(exerciseMinutes)",
                    unit: "dk",
                    sub: "\(exerciseGoalMinutes) dakikalık hedefe çok yakın",
                    cta: "Antrenman başlat",
                    onTap: { onOpenExercise?() },
                    visual: { DashboardHourlyBars(data: hourlyExerciseBuckets, color: .pulseExercise) }
                )
                .padding(.horizontal, 22).padding(.bottom, 14)

                // 04 — Habits
                DashboardStackCard(
                    tag: "04 · Alışkanlık",
                    color: .pulseHabit,
                    big: "\(habitsDone)/\(habitsTotal)",
                    sub: "\(habitsTotal - habitsDone) alışkanlık kaldı · en uzun seri \(longestStreakDays) gün",
                    cta: "Alışkanlıkları gör",
                    onTap: { showHabits = true },
                    visual: { DashboardMiniRings(data: habitsDoneList, color: .pulseHabit) }
                )
                .padding(.horizontal, 22).padding(.bottom, 14)

                appleHealthStrip
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                    .padding(.bottom, 16)

                historyStrip
                    .padding(.horizontal, 22)
                    .padding(.bottom, 32)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.pulseBgPage.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { pulseMark }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.pulseTextMuted)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.pulseSurface))
                        .pulseSoftShadow()
                }
            }
        }
        .task { await loadHealthKitData() }
        .sheet(isPresented: $showSettings) {
            NavigationStack { SettingsView() }
        }
        .sheet(isPresented: $showHabits) {
            NavigationStack { HabitsView() }
        }
        .sheet(isPresented: $showWeekly) {
            NavigationStack { WeeklyView() }
        }
        .sheet(isPresented: $showMonthly) {
            NavigationStack { MonthlyView() }
        }
    }

    // MARK: - Sub-views
    private var editorialHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle().fill(Color.pulseCoral).frame(width: 6, height: 6)
                Text("BUGÜN · \(todayFormatted)")
                    .font(PulseType.eyebrow).tracking(1.4)
                    .foregroundStyle(Color.pulseCoral)
            }
            (Text("Günlük\n").foregroundStyle(Color.pulseText)
             + Text("özet.").foregroundStyle(Color.pulseCoral))
                .font(PulseType.display(34))
                .tracking(-1.2)
                .lineSpacing(-2)
            HStack(spacing: 4) {
                Text("4 hedeften 3'üne yakınsın · ")
                    .foregroundStyle(Color.pulseTextMuted)
                Text("\(overallPercent)%")
                    .foregroundStyle(Color.pulseText)
                    .fontWeight(.bold)
            }
            .font(.system(size: 14, weight: .medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var appleHealthStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APPLE HEALTH")
                .font(PulseType.eyebrow).tracking(1.2)
                .foregroundStyle(Color.pulseTextMuted)
            HStack(spacing: 10) {
                DashboardMiniMetric(icon: "figure.walk", value: stepsToday, sub: "adım", color: .pulseWater)
                DashboardMiniMetric(icon: "flame.fill",  value: caloriesToday, sub: "kcal", color: .pulseCoral)
                DashboardMiniMetric(icon: "moon.fill",   value: sleepToday, sub: "uyku", color: .pulseExercise)
            }
        }
    }

    private var historyStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TARİHÇE")
                .font(PulseType.eyebrow).tracking(1.2)
                .foregroundStyle(Color.pulseTextMuted)
            HStack(spacing: 10) {
                DashboardHistoryCard(
                    title: "HAFTALIK",
                    subtitle: weekRangeLabel,
                    color: .pulseWater,
                    onTap: { showWeekly = true }
                ) {
                    DashboardMiniBar(data: weeklyWaterRatios, color: .pulseWater)
                }
                DashboardHistoryCard(
                    title: "AYLIK",
                    subtitle: monthLabel,
                    color: .pulseExercise,
                    onTap: { showMonthly = true }
                ) {
                    DashboardMiniBar(data: monthlyExerciseWeekRatios, color: .pulseExercise)
                }
            }
        }
    }

    private var pulseMark: some View {
        PulseNavBrand()
    }

    // MARK: - Helpers
    private var nutritionSub: String {
        let remaining = mealsTotal - mealsCompleted
        if remaining <= 0 { return "Tüm öğünler tamam 🎉" }
        return "Akşam yemeği ve ara öğün kaldı"
    }
    private func ratio(_ a: Int, _ b: Int) -> Double { b > 0 ? min(1.0, Double(a)/Double(b)) : 0 }
    private func percent(_ a: Int, _ b: Int) -> Int { Int((ratio(a, b) * 100).rounded()) }
    private func formatLiters(_ ml: Double) -> String { String(format: "%.1f", ml / 1000.0) }

    private var todayFormatted: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }

    // MARK: - HealthKit
    private func loadHealthKitData() async {
        guard HealthKitService.shared.isAvailable else { return }
        await HealthKitService.shared.requestAuthorization()
        async let steps = HealthKitService.shared.fetchTodaySteps()
        async let calories = HealthKitService.shared.fetchTodayActiveCalories()
        let (s, c) = await (steps, calories)
        hkSteps = s
        hkCalories = c
        sleepData = await HealthKitService.shared.fetchLastNightSleep()
    }
}

#Preview {
    NavigationStack { DashboardView() }
}
