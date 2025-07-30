import SwiftUI

struct CategorySelectionQuestionFilterOption: View {
  let title: String
  let description: String
  let icon: String
  let filter: QuestionFilter
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(iconColor)
          .frame(width: 24, height: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.brainyBodyLarge)
            .foregroundColor(titleColor)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(description)
            .font(.brainyBodySmall)
            .foregroundColor(.brainyTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        Spacer()

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(checkmarkColor)
      }
      .padding(16)
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
    isSelected ? .brainyPrimary : .brainyTextSecondary
  }

  private var titleColor: Color {
    isSelected ? .brainyPrimary : .brainyText
  }

  private var backgroundColor: Color {
    isSelected ? Color.brainyPrimary.opacity(0.05) : .brainyCardBackground
  }

  private var borderColor: Color {
    isSelected ? .brainyPrimary : Color.brainySecondary.opacity(0.2)
  }

  private var borderWidth: CGFloat {
    isSelected ? 2.0 : 1.0
  }

  private var checkmarkColor: Color {
    isSelected ? .brainyPrimary : .brainyTextSecondary
  }
}
