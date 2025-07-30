import SwiftUI

struct CategorySelectionPlayModeToggle: View {
  let title: String
  let description: String
  let icon: String
  let mode: QuizMode
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(iconColor)

        Text(title)
          .font(.brainyLabelLarge)
          .foregroundColor(titleColor)

        Text(description)
          .font(.brainyLabelSmall)
          .foregroundColor(.brainyTextSecondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(backgroundColor)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(borderColor, lineWidth: borderWidth)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }

  private var iconColor: Color {
    isSelected ? .white : .brainyPrimary
  }

  private var titleColor: Color {
    isSelected ? .white : .brainyText
  }

  private var backgroundColor: Color {
    isSelected ? .brainyPrimary : .brainyCardBackground
  }

  private var borderColor: Color {
    isSelected ? .brainyPrimary : Color.brainySecondary.opacity(0.2)
  }

  private var borderWidth: CGFloat {
    isSelected ? 2.0 : 1.0
  }
}
