import ComposableArchitecture
import SwiftUI

/// 퀴즈 모드 선택 화면
struct QuizModeSelectionPage: View {
  @Bindable var store: StoreOf<QuizModeSelectionReducer>
  
  var body: some View {
    VStack(spacing: 32) {
      // 헤더
      headerSection

      // 퀴즈 모드 선택 버튼들
      quizModeSection

      Spacer()

      // 하단 네비게이션 버튼들
      bottomNavigationSection
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.brainyBackground)
    .navigationBarHidden(true)
  }

  // MARK: - Header Section
  private var headerSection: some View {
    VStack(spacing: 16) {
      Text("🧠")
        .font(.system(size: 60))

      Text("퀴즈 모드 선택")
        .font(.brainyTitle)
        .foregroundColor(.brainyText)

      Text("원하는 퀴즈 형태를 선택해주세요")
        .font(.brainyBody)
        .foregroundColor(.brainyTextSecondary)
        .multilineTextAlignment(.center)
    }
  }

  // MARK: - Quiz Mode Section
  private var quizModeSection: some View {
    VStack(spacing: 16) {
      // 주관식 퀴즈
      QuizModeCard(
        icon: "pencil.and.outline",
        title: "주관식 퀴즈",
        description: "직접 답을 입력하는 퀴즈",
        quizType: .shortAnswer,
        isSelected: store.selectedQuizType == .shortAnswer
      ) {
        store.send(.changeQuizType(.shortAnswer))
        store.send(.goToCategory(.shortAnswer))
      }

      // 객관식 퀴즈
      QuizModeCard(
        icon: "list.bullet.circle",
        title: "객관식 퀴즈",
        description: "선택지에서 답을 고르는 퀴즈",
        quizType: .multipleChoice,
        isSelected: store.selectedQuizType == .multipleChoice
      ) {
        store.send(.changeQuizType(.multipleChoice))
        store.send(.goToCategory(.multipleChoice))
      }

      // 음성모드 퀴즈 (미구현)
      QuizModeCard(
        icon: "mic.circle",
        title: "음성모드 퀴즈",
        description: "음성으로 듣고 답하는 퀴즈",
        quizType: .voice,
        isEnabled: false,
        isSelected: store.selectedQuizType == .voice
      ) {
        store.send(.changeQuizType(.voice))
      }

      // AI 모드 퀴즈 (미구현)
      QuizModeCard(
        icon: "brain.head.profile",
        title: "AI 모드 퀴즈",
        description: "AI가 생성하는 동적 퀴즈",
        quizType: .ai,
        isEnabled: false,
        isSelected: store.selectedQuizType == .ai
      ) {
        store.send(.changeQuizType(.ai))
      }
    }
  }

  // MARK: - Bottom Navigation Section
  private var bottomNavigationSection: some View {
    HStack(spacing: 16) {
      // 히스토리 버튼
      Button(action: {
        store.send(.goToHistoryList)
      }) {
        HStack {
          Image(systemName: "clock.arrow.circlepath")
          Text("히스토리")
        }
        .font(.brainyButton)
        .foregroundColor(.brainyPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.brainySurface)
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.brainyPrimary, lineWidth: 1)
        )
      }

      // 프로필 버튼
      Button(action: {
        store.send(.goToProfile)
      }) {
        HStack {
          Image(systemName: "person.circle")
          Text("프로필")
        }
        .font(.brainyButton)
        .foregroundColor(.brainyPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.brainySurface)
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.brainyPrimary, lineWidth: 1)
        )
      }
    }
  }
}

// MARK: - Quiz Mode Card
private struct QuizModeCard: View {
  let icon: String
  let title: String
  let description: String
  let quizType: QuizType
  let isEnabled: Bool
  let isSelected: Bool
  let action: () -> Void

  init(
    icon: String,
    title: String,
    description: String,
    quizType: QuizType,
    isEnabled: Bool = true,
    isSelected: Bool = false,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.title = title
    self.description = description
    self.quizType = quizType
    self.isEnabled = isEnabled
    self.isSelected = isSelected
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(spacing: 16) {
        // 아이콘
        Image(systemName: icon)
          .font(.system(size: 24, weight: .medium))
          .foregroundColor(iconColor)
          .frame(width: 48, height: 48)
          .background(
            Circle()
              .fill(iconBackgroundColor)
          )

        // 텍스트
        VStack(alignment: .leading, spacing: 6) {
          Text(title)
            .font(.brainyHeadlineMedium)
            .foregroundColor(titleColor)
            .multilineTextAlignment(.leading)

          Text(description)
            .font(.brainyBodyMedium)
            .foregroundColor(.brainyTextSecondary)
            .multilineTextAlignment(.leading)
        }

        Spacer()

        // 상태 표시
        statusIndicator
      }
      .padding(20)
      .background(cardBackgroundColor)
      .cornerRadius(16)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(borderColor, lineWidth: borderWidth)
      )
      .scaleEffect(isSelected ? 1.02 : 1.0)
      .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    .disabled(!isEnabled)
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: - Computed Properties

  private var iconColor: Color {
    if !isEnabled {
      return .brainyTextSecondary
    }
    return isSelected ? .white : .brainyPrimary
  }

  private var iconBackgroundColor: Color {
    if !isEnabled {
      return Color.brainyTextSecondary.opacity(0.1)
    }
    return isSelected ? .brainyPrimary : Color.brainyPrimary.opacity(0.1)
  }

  private var titleColor: Color {
    if !isEnabled {
      return .brainyTextSecondary
    }
    return isSelected ? .brainyPrimary : .brainyText
  }

  private var cardBackgroundColor: Color {
    if isSelected {
      return Color.brainyPrimary.opacity(0.05)
    }
    return .brainyCardBackground
  }

  private var borderColor: Color {
    if !isEnabled {
      return Color.brainySecondary.opacity(0.2)
    }
    return isSelected ? .brainyPrimary : Color.brainySecondary.opacity(0.2)
  }

  private var borderWidth: CGFloat {
    return isSelected ? 2.0 : 1.0
  }

  @ViewBuilder
  private var statusIndicator: some View {
    if !isEnabled {
      Text("준비중")
        .font(.brainyLabelSmall)
        .foregroundColor(.brainyTextSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.brainyTextSecondary.opacity(0.1))
        .cornerRadius(8)
    } else if isSelected {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 20, weight: .medium))
        .foregroundColor(.brainyPrimary)
    } else {
      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.brainyTextSecondary)
    }
  }
}

