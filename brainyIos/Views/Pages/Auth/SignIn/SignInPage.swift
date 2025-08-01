import ComposableArchitecture
import SwiftUI
import AuthenticationServices

struct SignInPage: View {
  @Bindable var store: StoreOf<SignInReducer>

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 32) {
          // 로고 및 타이틀
          headerSection

          // 이메일 로그인 폼
          emailSignInSection

          // 구분선
          dividerSection

          // 소셜 로그인 버튼들
          socialSignInSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
      }
      .background(Color.brainyBackground)
      .navigationBarHidden(true)
    }
    .alert("로그인 오류", isPresented: .constant(store.errorMessage != nil)) {
      Button("확인") {
        store.send(.clearError)
      }
    } message: {
      if let errorMessage = store.errorMessage {
        Text(errorMessage)
      }
    }
    .onChange(of: store.isAuthenticated) { _, isAuthenticated in
      if isAuthenticated {

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
    VStack(spacing: 16) {
      // 이메일 입력 필드
      BrainyTextField(
        text: $store.email,
        placeholder: "이메일",
        keyboardType: .emailAddress
      )
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()

      // 비밀번호 입력 필드
      HStack {
        if store.showPassword {
          BrainyTextField(
            text: $store.password,
            placeholder: "비밀번호"
          )
        } else {
          SecureField("비밀번호", text: $store.password)
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.brainySurface)
            .cornerRadius(12)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brainySecondary.opacity(0.3), lineWidth: 1)
            )
        }

        Button(action: { store.send(.togglePasswordVisibility) }) {
          Image(systemName: store.showPassword ? "eye.slash" : "eye")
            .foregroundColor(.brainyTextSecondary)
        }
        .padding(.trailing, 16)
      }

      // 로그인 버튼
      BrainyButton(
        store.isLoading ? "로그인 중..." : "이메일로 로그인",
        style: .primary,
        isEnabled: store.isSignInButtonEnabled
      ) {
        store.send(.signInWithEmail)
      }
    }
  }

  @ViewBuilder
  private var dividerSection: some View {
    HStack {
      Rectangle()
        .fill(Color.brainySecondary.opacity(0.3))
        .frame(height: 1)

      Text("또는")
        .font(.brainyCaption)
        .foregroundColor(.brainyTextSecondary)
        .padding(.horizontal, 16)

      Rectangle()
        .fill(Color.brainySecondary.opacity(0.3))
        .frame(height: 1)
    }
  }

  @ViewBuilder
  private var socialSignInSection: some View {
    VStack(spacing: 12) {
      // Sign in with Apple
      SignInWithAppleButton(
        onRequest: { request in
          request.requestedScopes = [.fullName, .email]
        },
        onCompletion: { result in
          store.send(.signInWithApple)
        }
      )
      .signInWithAppleButtonStyle(.black)
      .frame(height: 50)
      .cornerRadius(12)
      .disabled(!store.isSocialSignInEnabled)

      // Google 로그인 버튼
      Button(action: {
        store.send(.goToQuizModeSelection)
      }) {
        HStack {
          Image(systemName: "globe")
            .foregroundColor(.white)

          Text("Google로 로그인")
            .font(.brainyButton)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.red)
        .cornerRadius(12)
      }
      .disabled(!store.isSocialSignInEnabled)
    }
  }
}
