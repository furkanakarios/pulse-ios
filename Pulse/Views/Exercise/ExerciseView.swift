import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseEntry.date, order: .reverse) private var allEntries: [ExerciseEntry]

    @State private var showAddEntry = false

    private var todayEntries: [ExerciseEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var todayTotalMinutes: Int {
        todayEntries.reduce(0) { $0 + $1.duration }
    }

    private var todayTotalCalories: Double {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        NavigationStack {
            List {
                summarySection
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                if !todayEntries.isEmpty {
                    Section("Bugünkü Egzersizler") {
                        ForEach(todayEntries) { entry in
                            entryRow(entry)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                } else {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "figure.run.circle")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("Bugün henüz egzersiz yok")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 24)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Egzersiz")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PulseNavBrand()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddExerciseView()
            }
        }
    }

    // MARK: - Summary
    private var summarySection: some View {
        HStack(spacing: 12) {
            ExerciseSummaryCard(
                value: "\(todayTotalMinutes) dk",
                label: "Toplam Süre",
                icon: "clock.fill",
                color: .green
            )
            ExerciseSummaryCard(
                value: todayTotalCalories > 0 ? "\(Int(todayTotalCalories)) kcal" : "—",
                label: "Yakılan Kalori",
                icon: "flame.fill",
                color: .orange
            )
            ExerciseSummaryCard(
                value: "\(todayEntries.count)",
                label: "Egzersiz",
                icon: "figure.run",
                color: .blue
            )
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Entry Row
    private func entryRow(_ entry: ExerciseEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: activityIcon(for: entry.activityType))
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.activityType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Label("\(entry.duration) dk", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if entry.calories > 0 {
                        Label("\(Int(entry.calories)) kcal", systemImage: "flame")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()

            Text(entry.date, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Helpers
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(todayEntries[index])
        }
        AchievementService.shared.evaluate(context: modelContext)
    }

    private func activityIcon(for type: String) -> String {
        switch type.lowercased() {
        case let t where t.contains("koş") || t.contains("run"): return "figure.run"
        case let t where t.contains("yüz") || t.contains("swim"): return "figure.pool.swim"
        case let t where t.contains("bisiklet") || t.contains("cycling"): return "figure.outdoor.cycle"
        case let t where t.contains("yürü") || t.contains("walk"): return "figure.walk"
        case let t where t.contains("yoga"): return "figure.mind.and.body"
        case let t where t.contains("ağırlık") || t.contains("weights"): return "dumbbell.fill"
        default: return "figure.strengthtraining.functional"
        }
    }
}

// MARK: - Summary Card
struct ExerciseSummaryCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
