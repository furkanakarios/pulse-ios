import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]

    @State private var showAddHabit = false
    @State private var reminderHabit: Habit? = nil

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
                                onToggle: { toggleHabit(habit) },
                                onReminderTap: { reminderHabit = habit }
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
                    Button { showAddHabit = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
            .sheet(item: $reminderHabit) { habit in
                HabitReminderSheet(habit: habit)
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
            let habit = activeHabits[index]
            NotificationService.shared.cancelHabitReminder(habitID: habit.id.uuidString)
            modelContext.delete(habit)
        }
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void
    let onReminderTap: () -> Void

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

            Button(action: onReminderTap) {
                Image(systemName: habit.reminderTime != nil ? "bell.fill" : "bell")
                    .font(.subheadline)
                    .foregroundStyle(habit.reminderTime != nil ? .purple : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}

// MARK: - Habit Reminder Sheet
struct HabitReminderSheet: View {
    @Bindable var habit: Habit
    @Environment(\.dismiss) private var dismiss

    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    @State private var showDeniedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Hatırlatıcı Aç", isOn: Binding(
                        get: { reminderEnabled },
                        set: { toggleReminder($0) }
                    ))
                    .tint(.purple)

                    if reminderEnabled {
                        DatePicker("Saat", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { scheduleReminder() }
                    }
                } header: {
                    Text(habit.name)
                } footer: {
                    Text("Her gün bu saatte alışkanlığını tamamladın mı diye hatırlatır.")
                }
            }
            .navigationTitle("Hatırlatıcı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { loadCurrentState() }
            .alert("Bildirim İzni Gerekli", isPresented: $showDeniedAlert) {
                Button("Ayarlara Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("İptal", role: .cancel) { reminderEnabled = false }
            } message: {
                Text("Bildirimlere izin vermek için Ayarlar > Pulse > Bildirimler bölümüne gidin.")
            }
        }
        .presentationDetents([.medium])
    }

    private func loadCurrentState() {
        if let time = habit.reminderTime {
            reminderEnabled = true
            reminderTime = time
        } else {
            reminderEnabled = false
        }
    }

    private func toggleReminder(_ enabled: Bool) {
        if enabled {
            Task {
                let status = await NotificationService.shared.authorizationStatus()
                switch status {
                case .authorized, .provisional:
                    reminderEnabled = true
                    scheduleReminder()
                case .notDetermined:
                    let granted = await NotificationService.shared.requestAuthorization()
                    if granted {
                        reminderEnabled = true
                        scheduleReminder()
                    } else {
                        reminderEnabled = false
                    }
                case .denied:
                    showDeniedAlert = true
                default:
                    reminderEnabled = false
                }
            }
        } else {
            reminderEnabled = false
            habit.reminderTime = nil
            NotificationService.shared.cancelHabitReminder(habitID: habit.id.uuidString)
        }
    }

    private func scheduleReminder() {
        habit.reminderTime = reminderTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        NotificationService.shared.scheduleHabitReminder(
            habitID: habit.id.uuidString,
            habitName: habit.name,
            hour: components.hour ?? 9,
            minute: components.minute ?? 0
        )
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
