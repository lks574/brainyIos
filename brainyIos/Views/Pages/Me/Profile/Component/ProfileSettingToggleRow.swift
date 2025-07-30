import SwiftUI

struct ProfileSettingToggleRow: View {
  let icon: String
  let title: String
  let subtitle: String
  @Binding var isOn: Bool
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(.brainyPrimary)
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
      
      Toggle("", isOn: $isOn)
        .labelsHidden()
        .tint(.brainyPrimary)
    }
    .padding(.vertical, 12)
  }
}
