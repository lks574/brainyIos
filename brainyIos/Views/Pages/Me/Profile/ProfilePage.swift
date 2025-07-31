import ComposableArchitecture
import SwiftUI

struct ProfilePage: View {
  @Bindable var store: StoreOf<ProfileReducer>

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        userInfoSection
        settingsSection
        appInfoSection
        logoutSection

        BrainyButton("뒤로 가기", style: .secondary) {
          store.send(.goToBack)
        }
      }
      .padding(24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.brainyBackground)
    .navigationBarHidden(true)

  }
}

extension ProfilePage {
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
  }

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  private var authProviderIcon: String {
//    guard let user = store.user else { return "person.circle" }
    return "envelope.circle"
//    switch user.authProvider {
//    case .email:
//      return "envelope.circle"
//    case .google:
//      return "globe.circle"
//    case .apple:
//      return "applelogo"
//    }
  }

  private var authProviderText: String {
//    guard let user = store.user else { return "알 수 없음" }
    return "이메일로 가입"
//    switch user.authProvider {
//    case .email:
//      return "이메일로 가입"
//    case .google:
//      return "Google로 가입"
//    case .apple:
//      return "Apple로 가입"
//    }
  }
}

extension ProfilePage {
  private var headerSection: some View {
    VStack(spacing: 16) {
      // 프로필 아이콘
      ZStack {
        Circle()
          .fill(Color.brainyPrimary.opacity(0.1))
          .frame(width: 80, height: 80)

        Image(systemName: "person.fill")
          .font(.system(size: 36))
          .foregroundColor(.brainyPrimary)
      }

      Text("프로필")
        .font(.brainyTitle)
        .foregroundColor(.brainyText)
    }
  }

  private var userInfoSection: some View {
    VStack(spacing: .zero) {
      if let user = store.user {
        VStack(spacing: 16) {
          // 사용자 기본 정보
          VStack(spacing: 8) {
            Text(user.username)
              .font(.brainyHeadlineMedium)
              .foregroundColor(.brainyText)

            if let email = user.email {
              Text(email)
                .font(.brainyBody)
                .foregroundColor(.brainyTextSecondary)
            }

            // 인증 제공자 표시
            HStack(spacing: 8) {
              Image(systemName: authProviderIcon)
                .font(.system(size: 14))
                .foregroundColor(.brainyTextSecondary)

              Text(authProviderText)
                .font(.brainyCaption)
                .foregroundColor(.brainyTextSecondary)
            }
          }

          VStack(spacing: 4) {
            Text("가입일")
              .font(.brainyCaption)
              .foregroundColor(.brainyTextSecondary)

            Text(formatDate(user.createdAt))
              .font(.brainyBodySmall)
              .foregroundColor(.brainyText)
          }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.brainyCardBackground)
        .cornerRadius(16)
      } else {
        EmptyView()
      }
    }
  }

  private var settingsSection: some View {
    VStack(spacing: 16) {
      // 섹션 헤더
      HStack {
        Text("설정")
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyText)
        Spacer()
      }

      VStack(spacing: 0) {
        // 데이터 동기화
        //        ProfileSettingRow(
        //          icon: syncViewModel.syncStatusIcon,
        //          title: "데이터 동기화",
        //          subtitle: syncViewModel.lastSyncDateString,
        //          showChevron: true,
        //          isLoading: syncViewModel.isSyncing,
        //          iconColor: syncViewModel.syncStatusColor
        //        ) {
        //          performSync()
        //        }

        Divider()
          .padding(.leading, 44)

        // 다크모드 토글
        ProfileSettingToggleRow(
          icon: "moon.circle",
          title: "다크모드",
          subtitle: "어두운 테마 사용",
          isOn: $store.isDarkModeEnabled
        )

        Divider()
          .padding(.leading, 44)

        // 알림 설정
        ProfileSettingToggleRow(
          icon: "bell.circle",
          title: "알림",
          subtitle: "퀴즈 알림 받기",
          isOn: $store.isNotificationEnabled
        )

        Divider()
          .padding(.leading, 44)

        // 사운드 설정
        ProfileSettingToggleRow(
          icon: "speaker.wave.2.circle",
          title: "사운드",
          subtitle: "효과음 및 배경음",
          isOn: $store.isSoundEnabled
        )
      }
      .padding(16)
      .background(Color.brainyCardBackground)
      .cornerRadius(16)
    }
  }

  private var appInfoSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("앱 정보")
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyText)
        Spacer()
      }

      VStack(spacing: 0) {
        ProfileSettingRow(
          icon: "info.circle",
          title: "버전",
          subtitle: appVersion,
          showChevron: false
        ) { }

        Divider()
          .padding(.leading, 44)

        ProfileSettingRow(
          icon: "questionmark.circle",
          title: "도움말",
          subtitle: "사용법 및 FAQ",
          showChevron: true
        ) {
          // TODO: 도움말 화면으로 이동
        }

        Divider()
          .padding(.leading, 44)

        ProfileSettingRow(
          icon: "envelope.circle",
          title: "문의하기",
          subtitle: "개발자에게 연락",
          showChevron: true
        ) {
          // TODO: 문의 화면으로 이동
        }
      }
      .padding(16)
      .background(Color.brainyCardBackground)
      .cornerRadius(16)
    }
  }

  var logoutSection: some View {
    BrainyButton(
      store.authIsLoading ? "로그아웃 중..." : "로그아웃",
      style: .secondary,
      isEnabled: !store.authIsLoading
    ) {
      //      Task {
      //        await authViewModel.signOut()
      //        if !authViewModel.isAuthenticated {
      //          coordinator.navigateToAuthentication()
      //        }
      //      }
    }
  }

}

