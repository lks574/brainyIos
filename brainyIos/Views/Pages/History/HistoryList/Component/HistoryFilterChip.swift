import SwiftUI

struct HistoryFilterChip: View {
  let title: String
  let isSelected: Bool
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text(title)
          .font(.brainyLabelMedium)
          .foregroundColor(isSelected ? .white : .brainyText)
        
        if isSelected {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.8))
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(isSelected ? Color.brainyPrimary : Color.brainyCardBackground)
      .cornerRadius(16)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(isSelected ? Color.brainyPrimary : Color.brainyTextSecondary.opacity(0.3), lineWidth: 1)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}
