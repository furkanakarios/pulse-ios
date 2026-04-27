import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var achievements: [Achievement]

    private var unlockedCount: Int { achievements.filter { $0.isUnlocked }.count }
    private var totalCount: Int { AchievementDefinition.all.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summaryHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    categorySection(category)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Başarımlar")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0)
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: unlockedCount)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.yellow)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(unlockedCount) / \(totalCount) Başarım")
                    .font(.system(size: 20, weight: .heavy))
                Text("Tüm kategorilerde hedeflerini tamamla")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - Category section

    private func categorySection(_ category: AchievementCategory) -> some View {
        let defs = AchievementDefinition.all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(category.color)
                Text(category.rawValue.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(category.color)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(defs.enumerated()), id: \.element.key) { idx, def in
                    let record = achievements.first { $0.key == def.key }
                    AchievementRow(
                        definition: def,
                        record: record,
                        progress: record?.isUnlocked == true
                            ? def.totalSteps
                            : AchievementService.shared.currentProgress(for: def.key, context: modelContext)
                    )
                    if idx < defs.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Row

private struct AchievementRow: View {
    let definition: AchievementDefinition
    let record: Achievement?
    let progress: Int

    private var isUnlocked: Bool { record?.isUnlocked == true }
    private var progressRatio: Double {
        definition.totalSteps > 1
            ? min(1.0, Double(progress) / Double(definition.totalSteps))
            : (isUnlocked ? 1.0 : 0.0)
    }

    var body: some View {
        HStack(spacing: 14) {
            iconBadge
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(definition.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    Spacer()
                    if isUnlocked, let date = record?.unlockedAt {
                        Text(date, format: .dateTime.day().month())
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.tertiary)
                    } else if definition.totalSteps > 1 {
                        Text("\(progress)/\(definition.totalSteps)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(isUnlocked ? definition.category.color : .secondary)
                    }
                }
                Text(definition.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)

                if definition.totalSteps > 1 && !isUnlocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemFill))
                                .frame(height: 4)
                            Capsule()
                                .fill(definition.category.color)
                                .frame(width: geo.size.width * progressRatio, height: 4)
                                .animation(.easeOut(duration: 0.5), value: progressRatio)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 2)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .opacity(isUnlocked ? 1.0 : 0.55)
    }

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isUnlocked
                      ? definition.category.color.opacity(0.18)
                      : Color(.tertiarySystemFill))
                .frame(width: 44, height: 44)
            Image(systemName: definition.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isUnlocked ? definition.category.color : Color(.tertiaryLabel))
        }
        .overlay(
            isUnlocked
                ? RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(definition.category.color.opacity(0.35), lineWidth: 1.5)
                : nil
        )
    }
}

#Preview {
    NavigationStack { AchievementsView() }
        .modelContainer(for: [Achievement.self], inMemory: true)
}
