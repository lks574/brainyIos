import SwiftUI

struct HistoryFilterButton: View {
  let text: String
  let isSelected: Bool
  var style: FilterButtonStyle = .normal
  let onTap: () -> Void

  enum FilterButtonStyle {
    case normal
    case fullWidth
  }

  var body: some View {
    Button(action: onTap) {
      Text(text)
        .font(.brainyBody)
        .foregroundColor(isSelected ? .white : .brainyText)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: style == .fullWidth ? .infinity : nil)
        .background(isSelected ? Color.brainyAccent : Color.brainyCardBackground)
        .cornerRadius(8)
    }
    .buttonStyle(PlainButtonStyle())
  }
}
