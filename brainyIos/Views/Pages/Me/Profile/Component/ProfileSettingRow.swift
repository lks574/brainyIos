import SwiftUI

struct ProfileSettingRow: View {
  let icon: String
  let title: String
  let subtitle: String
  let showChevron: Bool
  let isLoading: Bool
  let iconColor: Color
  let action: () -> Void

  init(
    icon: String,
    title: String,
    subtitle: String,
    showChevron: Bool = true,
    isLoading: Bool = false,
    iconColor: Color = .brainyPrimary,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.title = title
    self.subtitle = subtitle
    self.showChevron = showChevron
    self.isLoading = isLoading
    self.iconColor = iconColor
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 20))
          .foregroundColor(iconColor)
          .frame(width: 32, height: 32)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.brainyBody)
            .foregroundColor(.brainyText)

          Text(subtitle)
            .font(.brainyCaption)
            .foregroundColor(.brainyTextSecondary)
        }

        Spacer()

        if isLoading {
          ProgressView()
            .scaleEffect(0.8)
        } else if showChevron {
          Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.brainyTextSecondary)
        }
      }
      .padding(.vertical, 12)
    }
    .disabled(isLoading)
  }
}
