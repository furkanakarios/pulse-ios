import SwiftUI

private struct MoreItem {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

struct MoreView: View {
    private let items: [MoreItem] = [
        MoreItem(title: "Alışkanlıklar", icon: "checkmark.circle.fill", color: .purple,
                 destination: AnyView(HabitsView())),
        MoreItem(title: "Planlar", icon: "list.bullet.clipboard", color: .blue,
                 destination: AnyView(PlansView())),
        MoreItem(title: "Sağlık Notları", icon: "note.text", color: .teal,
                 destination: AnyView(NotesView())),
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        NavigationLink(destination: item.destination) {
                            MoreCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Daha Fazla")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct MoreCard: View {
    let item: MoreItem

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(item.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(item.color)
            }

            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}
