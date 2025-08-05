import SwiftUI

struct HistoryFilterButton: View {
  let title: String
  let isSelected: Bool
  var style: FilterButtonStyle = .normal
  let action: () -> Void

  enum FilterButtonStyle {
    case normal
    case fullWidth
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.brainyBodyMedium)
        .foregroundColor(isSelected ? .white : .brainyText)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: style == .fullWidth ? .infinity : nil)
        .background(isSelected ? Color.brainyPrimary : Color.brainyCardBackground)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? Color.brainyPrimary : Color.brainyTextSecondary.opacity(0.3), lineWidth: 1)
        )
    }
    .buttonStyle(PlainButtonStyle())
  }
}
