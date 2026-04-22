import SwiftUI
import SwiftData
import Charts

struct MonthlyView: View {
    @Query private var waterEntries: [WaterEntry]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habitLogs: [HabitLog]
    @Query private var habits: [Habit]
    @Query(sort: \Plan.startDate, order: .reverse) private var plans: [Plan]

    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30

    @State private var displayedMonth: Date = {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now))!
    }()
    @State private var selectedDay: Date? = nil

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "MMMM yyyy"; return f
    }()

    private static let dayDetailFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "EEEE, d MMMM"; return f
    }()

    private static let dayNumberFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "tr_TR"); f.dateFormat = "d"; return f
    }()

    private var monthDays: [Date?] {
        let cal = Calendar.current
        let startOfMonth = displayedMonth
        let range = cal.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = (cal.component(.weekday, from: startOfMonth) + 5) % 7
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: startOfMonth))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private var activeHabitsCount: Int {
        habits.filter { !$0.isArchived }.count
    }

    private var plansInMonth: [Plan] {
        let cal = Calendar.current
        let start = displayedMonth
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return plans.filter { $0.startDate < end && $0.endDate >= start }
    }

    // MARK: - Chart Data
    private struct MonthDayData: Identifiable {
        let id: Date
        let day: Int
        let water: Double
    }

    private var monthChartData: [MonthDayData] {
        let cal = Calendar.current
        let pastDays = monthDays.compactMap { $0 }.filter { !($0 > Date.now && !cal.isDateInToday($0)) }
        return pastDays.map { day in
            let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount }
            return MonthDayData(id: day, day: cal.component(.day, from: day), water: water)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                monthNavigatorView
                calendarGridView
                if let day = selectedDay {
                    dayDetailView(for: day)
                }
                if !plansInMonth.isEmpty {
                    plansTimelineView
                }
                monthStatsView
                monthlyChartView
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Aylık Görünüm")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Month Navigator
    private var monthNavigatorView: some View {
        HStack {
            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth)!
                selectedDay = nil
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }

            Spacer()

            Text(Self.monthFormatter.string(from: displayedMonth))
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button {
                displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth)!
                selectedDay = nil
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Calendar Grid
    private var calendarGridView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"], id: \.self) { label in
                    Text(label)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(monthDays.indices, id: \.self) { i in
                    if let day = monthDays[i] {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dayCell(_ date: Date) -> some View {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isFuture = date > Date.now && !isToday
        let isSelected = selectedDay.map { cal.isDate($0, inSameDayAs: date) } ?? false
        let score = isFuture ? -1.0 : dayScore(date)
        let dayNum = cal.component(.day, from: date)

        return Button {
            selectedDay = isSelected ? nil : date
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(cellBackground(isSelected: isSelected, isToday: isToday, score: score, isFuture: isFuture))
                    .frame(height: 40)

                VStack(spacing: 2) {
                    Text("\(dayNum)")
                        .font(.caption)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(cellTextColor(isSelected: isSelected, isToday: isToday, isFuture: isFuture))

                    if !isFuture && score >= 0 {
                        Circle()
                            .fill(dotColor(score))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func cellBackground(isSelected: Bool, isToday: Bool, score: Double, isFuture: Bool) -> Color {
        if isSelected { return .blue }
        if isToday { return Color.blue.opacity(0.15) }
        if isFuture { return Color.clear }
        if score >= 2 { return Color.green.opacity(0.15) }
        if score >= 1 { return Color.orange.opacity(0.1) }
        return Color(.tertiarySystemBackground)
    }

    private func cellTextColor(isSelected: Bool, isToday: Bool, isFuture: Bool) -> Color {
        if isSelected { return .white }
        if isFuture { return .secondary.opacity(0.4) }
        return .primary
    }

    private func dotColor(_ score: Double) -> Color {
        if score >= 2 { return .green }
        if score >= 1 { return .orange }
        return .secondary.opacity(0.3)
    }

    // MARK: - Day Detail
    private func dayDetailView(for date: Date) -> some View {
        let cal = Calendar.current
        let isFuture = date > Date.now && !cal.isDateInToday(date)
        let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.amount }
        let exercise = exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.duration }
        let completedHabits = habitLogs.filter { cal.isDate($0.date, inSameDayAs: date) && $0.isCompleted }.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Self.dayDetailFormatter.string(from: date))
                    .font(.headline)
                Spacer()
                if cal.isDateInToday(date) {
                    Text("Bugün")
                        .font(.caption).fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }

            if isFuture {
                Text("Bu gün henüz gelmedi.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                HStack(spacing: 12) {
                    miniStat(icon: "drop.fill", color: .blue, value: String(format: "%.0f ml", water), label: "Su")
                    miniStat(icon: "figure.run", color: .green, value: "\(Int(exercise)) dk", label: "Egzersiz")
                    miniStat(icon: "checkmark.circle.fill", color: .purple, value: "\(completedHabits)/\(activeHabitsCount)", label: "Alışkanlık")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func miniStat(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.caption)
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.caption).fontWeight(.semibold)
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Plans Timeline
    private var plansTimelineView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Aydaki Planlar")
                .font(.headline)

            ForEach(plansInMonth) { plan in
                NavigationLink(destination: PlanDetailView(plan: plan)) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(plan.planType)
                                .font(.caption2).fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7).padding(.vertical, 2)
                                .background(plan.planType == "Haftalık" ? Color.blue : Color.purple)
                                .clipShape(Capsule())

                            Text(plan.title)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Spacer()

                            if plan.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.caption)
                            }
                        }

                        planBarView(plan)
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

    private func planBarView(_ plan: Plan) -> some View {
        let cal = Calendar.current
        let monthStart = displayedMonth
        let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart)!
        let daysInMonth = cal.range(of: .day, in: .month, for: monthStart)!.count

        let planVisibleStart = max(plan.startDate, monthStart)
        let planVisibleEnd = min(plan.endDate, monthEnd)

        let startOffset = cal.dateComponents([.day], from: monthStart, to: planVisibleStart).day ?? 0
        let duration = max(1, cal.dateComponents([.day], from: planVisibleStart, to: planVisibleEnd).day ?? 1)

        let leadingFrac = Double(startOffset) / Double(daysInMonth)
        let widthFrac = Double(duration) / Double(daysInMonth)

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.quaternarySystemFill))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(plan.isCompleted ? Color.green : (plan.planType == "Haftalık" ? Color.blue : Color.purple))
                    .frame(width: max(8, geo.size.width * widthFrac), height: 6)
                    .offset(x: geo.size.width * leadingFrac)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Month Stats
    private var monthStatsView: some View {
        let cal = Calendar.current
        let pastDays = monthDays.compactMap { $0 }.filter { !($0 > Date.now && !cal.isDateInToday($0)) }

        let daysMetGoalWater = pastDays.filter { day in
            waterEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount } >= dailyWaterGoal
        }.count

        let daysMetGoalExercise = pastDays.filter { day in
            Double(exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.duration }) >= dailyExerciseGoal
        }.count

        let totalExercise = pastDays.reduce(0) { sum, day in
            sum + exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.duration }
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Ay İstatistikleri")
                .font(.headline)

            HStack(spacing: 12) {
                monthStatTile(icon: "drop.fill", color: .blue, value: "\(daysMetGoalWater)", label: "Su hedefi\ntutturulan gün")
                monthStatTile(icon: "figure.run", color: .green, value: "\(daysMetGoalExercise)", label: "Egzersiz hedefi\ntutturulan gün")
                monthStatTile(icon: "clock.fill", color: .orange, value: "\(totalExercise) dk", label: "Toplam\negzersiz")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func monthStatTile(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.subheadline)
            Text(value).font(.title3).fontWeight(.bold)
            Text(label).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Monthly Chart
    private var monthlyChartView: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Su Grafiği").font(.headline)
                Text("Aylık su tüketimi").font(.caption).foregroundStyle(.secondary)
            }

            Chart {
                ForEach(monthChartData) { item in
                    AreaMark(
                        x: .value("Gün", item.day),
                        y: .value("Su (ml)", item.water)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.07, green: 0.55, blue: 0.75).opacity(0.35), Color(red: 0.07, green: 0.55, blue: 0.75).opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Gün", item.day),
                        y: .value("Su (ml)", item.water)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.07, green: 0.55, blue: 0.75), Color(red: 0.2, green: 0.75, blue: 0.9)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Gün", item.day),
                        y: .value("Su (ml)", item.water)
                    )
                    .foregroundStyle(item.water >= dailyWaterGoal ? Color.green : Color(red: 0.07, green: 0.55, blue: 0.75))
                    .symbolSize(item.water >= dailyWaterGoal ? 40 : 20)
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
                AxisMarks(values: .stride(by: 5)) { value in
                    AxisGridLine().foregroundStyle(Color.secondary.opacity(0.1))
                    AxisValueLabel {
                        if let day = value.as(Int.self) {
                            Text("\(day)")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
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
    private func dayScore(_ date: Date) -> Double {
        let cal = Calendar.current
        let water = waterEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.amount }
        let exercise = Double(exerciseEntries.filter { cal.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.duration })
        var score = 0.0
        if water >= dailyWaterGoal { score += 1 }
        if exercise >= dailyExerciseGoal { score += 1 }
        return score
    }
}
