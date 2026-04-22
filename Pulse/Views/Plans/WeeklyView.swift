import SwiftUI
import SwiftData
import Charts

struct WeeklyView: View {
    @Query private var waterEntries: [WaterEntry]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habitLogs: [HabitLog]
    @Query private var habits: [Habit]
    @Query(sort: \Plan.startDate, order: .reverse) private var plans: [Plan]

    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30

    @State private var selectedDay: Date = Date.now

    private static let dayDetailFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "EEEE, d MMMM"; return f
    }()

    private var weekDays: [Date] {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private var activePlansThisWeek: [Plan] {
        let now = Date.now
        return plans.filter { !$0.isCompleted && $0.startDate <= now && $0.endDate >= now }
    }

    private var activeHabitsCount: Int { habits.filter { !$0.isArchived }.count }

    // MARK: - Chart Data
    private struct DayData: Identifiable {
        let id: Date
        let label: String
        let water: Double
        let exercise: Int
    }

    private var weekChartData: [DayData] {
        let cal = Calendar.current
        return weekDays.compactMap { day in
            guard !(day > Date.now && !cal.isDateInToday(day)) else { return nil }
            let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount }
            let ex = exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.duration }
            return DayData(id: day, label: dayLetter(day), water: water, exercise: ex)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                weekStripView
                selectedDayDetailView
                if !activePlansThisWeek.isEmpty { activeWeeklyPlansView }
                weekSummaryView
                weeklyChartView
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Haftalık Görünüm")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Week Strip
    private var weekStripView: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                let isToday = Calendar.current.isDateInToday(day)
                let score = dayScore(day)
                Button { selectedDay = day } label: {
                    VStack(spacing: 6) {
                        Text(dayLetter(day))
                            .font(.caption2).fontWeight(.medium)
                            .foregroundStyle(isSelected ? .white : .secondary)
                        Text(dayNumber(day))
                            .font(.subheadline).fontWeight(isToday ? .bold : .regular)
                            .foregroundStyle(isSelected ? .white : (isToday ? .primary : .secondary))
                        Circle().fill(scoreColor(score)).frame(width: 6, height: 6).opacity(score > 0 ? 1 : 0.2)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color.blue : Color.clear))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Selected Day Detail
    private var selectedDayDetailView: some View {
        let cal = Calendar.current
        let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: selectedDay) }.reduce(0) { $0 + $1.amount }
        let exercise = exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: selectedDay) }.reduce(0) { $0 + $1.duration }
        let completedHabits = habitLogs.filter { cal.isDate($0.date, inSameDayAs: selectedDay) && $0.isCompleted }.count
        let isToday = cal.isDateInToday(selectedDay)
        let isFuture = selectedDay > Date.now && !isToday

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Self.dayDetailFormatter.string(from: selectedDay)).font(.headline)
                Spacer()
                if isToday {
                    Text("Bugün").font(.caption).fontWeight(.medium).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.blue).clipShape(Capsule())
                }
            }
            if isFuture {
                Text("Bu gün henüz gelmedi.").font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
            } else {
                HStack(spacing: 12) {
                    dayMetricCard(icon: "drop.fill", color: .blue, title: "Su",
                                  value: String(format: "%.0f ml", water),
                                  progress: min(water / dailyWaterGoal, 1.0))
                    dayMetricCard(icon: "figure.run", color: .green, title: "Egzersiz",
                                  value: "\(Int(exercise)) dk",
                                  progress: min(Double(exercise) / dailyExerciseGoal, 1.0))
                    dayMetricCard(icon: "checkmark.circle.fill", color: .purple, title: "Alışkanlık",
                                  value: "\(completedHabits)/\(activeHabitsCount)",
                                  progress: activeHabitsCount > 0 ? Double(completedHabits) / Double(activeHabitsCount) : 0)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dayMetricCard(icon: String, color: Color, title: String, value: String, progress: Double) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.caption).fontWeight(.semibold).multilineTextAlignment(.center)
            Text(title).font(.caption2).foregroundStyle(.secondary)
            ProgressView(value: progress).tint(color)
        }
        .frame(maxWidth: .infinity).padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Active Plans
    private var activeWeeklyPlansView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Haftaki Planlar").font(.headline)
            ForEach(activePlansThisWeek) { plan in
                NavigationLink(destination: PlanDetailView(plan: plan)) {
                    HStack(spacing: 12) {
                        Image(systemName: plan.planType == "Haftalık" ? "calendar.badge.clock" : "calendar")
                            .foregroundStyle(plan.planType == "Haftalık" ? .blue : .purple).frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.title).font(.subheadline).fontWeight(.medium).foregroundStyle(.primary).lineLimit(1)
                            let daysLeft = max(0, Calendar.current.dateComponents([.day], from: .now, to: plan.endDate).day ?? 0)
                            Text("\(daysLeft) gün kaldı").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Week Summary
    private var weekSummaryView: some View {
        let cal = Calendar.current
        let pastDays = weekDays.filter { !($0 > Date.now && !cal.isDateInToday($0)) }
        let totalWater = pastDays.reduce(0.0) { sum, day in sum + waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount } }
        let totalExercise = pastDays.reduce(0) { sum, day in sum + exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.duration } }
        let daysWithGoalWater = pastDays.filter { day in
            waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount } >= dailyWaterGoal
        }.count

        return VStack(alignment: .leading, spacing: 12) {
            Text("Hafta Özeti").font(.headline)
            HStack(spacing: 12) {
                WeeklySummaryTile(icon: "drop.fill", color: .blue, title: "Toplam Su", value: String(format: "%.1f L", totalWater / 1000))
                WeeklySummaryTile(icon: "figure.run", color: .green, title: "Toplam Egzersiz", value: "\(totalExercise) dk")
                WeeklySummaryTile(icon: "drop.fill", color: .teal, title: "Su Hedefi", value: "\(daysWithGoalWater)/\(pastDays.count) gün")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Weekly Chart
    private var weeklyChartView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Su Grafiği").font(.headline)
                Text("Günlük su tüketimi").font(.caption).foregroundStyle(.secondary)
            }

            Chart {
                ForEach(weekChartData) { item in
                    BarMark(
                        x: .value("Gün", item.label),
                        y: .value("Su (ml)", item.water)
                    )
                    .foregroundStyle(
                        item.water >= dailyWaterGoal
                        ? LinearGradient(colors: [.green, .mint], startPoint: .bottom, endPoint: .top)
                        : LinearGradient(colors: [Color(red: 0.07, green: 0.55, blue: 0.75), Color(red: 0.2, green: 0.75, blue: 0.9)], startPoint: .bottom, endPoint: .top)
                    )
                    .cornerRadius(8)
                }

                RuleMark(y: .value("Hedef", dailyWaterGoal))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(Color.orange.opacity(0.8))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Hedef")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 4)
                    }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(Color.secondary.opacity(0.15))
                    AxisValueLabel {
                        if let ml = value.as(Double.self) {
                            Text(ml >= 1000 ? String(format: "%.1fL", ml / 1000) : "\(Int(ml))")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().font(.system(size: 10))
                }
            }

            HStack(spacing: 16) {
                legendDot(color: Color(red: 0.07, green: 0.55, blue: 0.75), label: "Su tüketimi")
                legendDot(color: .green, label: "Hedef tamamlandı")
                legendDot(color: .orange, label: "Günlük hedef", dashed: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func legendDot(color: Color, label: String, dashed: Bool = false) -> some View {
        HStack(spacing: 5) {
            if dashed {
                Rectangle().fill(color).frame(width: 12, height: 2)
            } else {
                Circle().fill(color).frame(width: 8, height: 8)
            }
            Text(label).font(.system(size: 10)).foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers
    private func dayLetter(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(3)).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        Calendar.current.component(.day, from: date).description
    }

    private func dayScore(_ date: Date) -> Double {
        let cal = Calendar.current
        guard !(date > Date.now && !cal.isDateInToday(date)) else { return 0 }
        let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.amount }
        let exercise = exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.duration }
        var score = 0.0
        if water >= dailyWaterGoal { score += 1 }
        if Double(exercise) >= dailyExerciseGoal { score += 1 }
        return score
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 2 { return .green }
        if score >= 1 { return .orange }
        return .secondary
    }
}

struct WeeklySummaryTile: View {
    let icon: String; let color: Color; let title: String; let value: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.subheadline).foregroundStyle(color)
            Text(value).font(.caption).fontWeight(.bold).multilineTextAlignment(.center)
            Text(title).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
