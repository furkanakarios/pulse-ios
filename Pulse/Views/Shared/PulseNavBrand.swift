import SwiftUI

/// Sol üst köşe marka göstergesi — tüm ana ekranlarda kullanılır.
struct PulseNavBrand: View {
    var body: some View {
        HStack(spacing: 6) {
            Image("PulseIcon")
                .resizable()
                .frame(width: 26, height: 26)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            Text("Pulse")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(.primary)
        }
        .fixedSize()
    }
}
