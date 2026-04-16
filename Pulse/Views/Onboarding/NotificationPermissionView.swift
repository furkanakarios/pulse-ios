import SwiftUI

struct NotificationPermissionView: View {
    @Binding var isPresented: Bool

    let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("drop.fill", .blue, "Su Hatırlatıcısı", "Günlük su hedefine ulaşmak için düzenli hatırlatmalar al."),
        ("checkmark.circle.fill", .purple, "Alışkanlık Bildirimi", "Her alışkanlık için kişisel saat ayarla, hiç unutma."),
        ("sun.max.fill", .orange, "Sabah Özeti", "Her sabah günün hedeflerini hatırlatan bir bildirim al.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                    .padding(.top, 48)

                Text("Bildirimlere İzin Ver")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Pulse, sağlık hedeflerine ulaşmanda sana yardımcı olmak için bildirim göndermek istiyor.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Features
            VStack(spacing: 0) {
                ForEach(features, id: \.title) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: feature.icon)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(feature.color)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(feature.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
            }
            .padding(.top, 32)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        _ = await NotificationService.shared.requestAuthorization()
                        isPresented = false
                    }
                } label: {
                    Text("İzin Ver")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    isPresented = false
                } label: {
                    Text("Şimdi Değil")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    NotificationPermissionView(isPresented: .constant(true))
}
