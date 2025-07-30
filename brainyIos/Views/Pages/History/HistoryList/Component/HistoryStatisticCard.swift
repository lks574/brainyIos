import SwiftUI

struct HistoryStatisticCard: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(.brainyAccent)

      Text(value)
        .font(.brainyHeadline)
        .foregroundColor(.brainyText)

      Text(title)
        .font(.brainyCaption)
        .foregroundColor(.brainyTextSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(Color.brainyCardBackground)
    .cornerRadius(12)
  }
}
