import SwiftUI

struct SignInPage: View {
  var body: some View {
    VStack {
      NavigationView {
        VStack(spacing: 12) {
          headerSection
        }
      }
    }
  }
}

extension SignInPage {

  @ViewBuilder
  private var headerSection: some View {
    VStack(spacing: 16) {
      Text("🧠")
        .font(.system(size: 80))

      Text("Brainy Quiz")
        .font(.brainyTitle)
        .foregroundStyle(.brainyText)

      Text("지식을 늘려가는 재미있는 퀴즈")
        .font(.brainyBody)
        .foregroundColor(.brainyTextSecondary)
        .multilineTextAlignment(.center)
    }
  }

  @ViewBuilder
  private var emailSignInSection: some View {
    
  }
}
