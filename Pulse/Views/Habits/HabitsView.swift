import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]

    @State private var showAddHabit = false

    private var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    private var completedToday: Int {
        activeHabits.filter { isCompleted($0) }.count
    }

    var body: some View {
        NavigationStack {
            List {
                if !activeHabits.isEmpty {
                    progressSection
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }

                if activeHabits.isEmpty {
                    emptyStateRow
                } else {
                    Section("Bugün") {
                        ForEach(activeHabits) { habit in
                            HabitRow(
                                habit: habit,
                                isCompleted: isCompleted(habit),
                                onToggle: { toggleHabit(habit) }
                            )
                        }
                        .onDelete(perform: deleteHabits)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Alışkanlıklar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
        }
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedToday)/\(activeHabits.count) tamamlandı")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Bugünkü ilerleme")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.2), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: activeHabits.isEmpty ? 0 : Double(completedToday) / Double(activeHabits.count))
                        .stroke(
                            completedToday == activeHabits.count ? Color.green : Color.purple,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.4), value: completedToday)
                }
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal)
            .padding(.top, 4)

            ProgressView(value: activeHabits.isEmpty ? 0 : Double(completedToday) / Double(activeHabits.count))
                .tint(completedToday == activeHabits.count ? .green : .purple)
                .padding(.horizontal)
                .animation(.easeOut(duration: 0.4), value: completedToday)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Empty State
    private var emptyStateRow: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Henüz alışkanlık yok")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                showAddHabit = true
            } label: {
                Label("Alışkanlık Ekle", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .listRowBackground(Color.clear)
    }

    // MARK: - Helpers
    private func isCompleted(_ habit: Habit) -> Bool {
        habitLogs.contains {
            $0.habit?.id == habit.id &&
            Calendar.current.isDateInToday($0.date) &&
            $0.isCompleted
        }
    }

    private func toggleHabit(_ habit: Habit) {
        if let existing = habitLogs.first(where: {
            $0.habit?.id == habit.id && Calendar.current.isDateInToday($0.date)
        }) {
            existing.isCompleted.toggle()
        } else {
            let log = HabitLog(date: .now, isCompleted: true)
            log.habit = habit
            modelContext.insert(log)
        }
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activeHabits[index])
        }
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? .green : .secondary)
                    .animation(.spring(duration: 0.3), value: isCompleted)
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Image(systemName: habit.icon)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(isCompleted ? Color.green : Color(hex: habit.colorHex))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .animation(.easeOut(duration: 0.3), value: isCompleted)

                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough(isCompleted, color: .secondary)
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                    if habit.streak > 0 {
                        Label("\(habit.streak) günlük seri", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    HabitsView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
