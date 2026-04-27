// FeatureRow.swift & PermissionRow.swift
import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.pulseAccentSoft)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.pulseAccent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.pulseText)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.pulseTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var granted: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.pulseAccent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 16, weight: .semibold))
                Text(subtitle).font(.system(size: 13)).foregroundStyle(Color.pulseTextSecondary)
            }
            Spacer()
            Toggle("", isOn: $granted)
                .labelsHidden()
                .tint(Color.pulseAccent)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.pulseSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
