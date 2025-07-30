import SwiftUI

struct HistoryFilterChip: View {
  let text: String
  let onRemove: () -> Void
  
  var body: some View {
    HStack(spacing: 4) {
      Text(text)
        .font(.brainyCaption)
        .foregroundColor(.brainyText)
      
      Button(action: onRemove) {
        Image(systemName: "xmark.circle.fill")
          .font(.caption)
          .foregroundColor(.brainyTextSecondary)
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Color.brainyCardBackground)
    .cornerRadius(12)
  }
}
