import ComposableArchitecture
import SwiftUI

struct QuizPlayPage: View {
  @Bindable var store: StoreOf<QuizPlayReducer>

  var body: some View {
    ZStack {
      Color.brainyBackground
        .ignoresSafeArea()

      if store.isLoading {
        loadingView
      } else if let errorMessage = store.errorMessage {
        errorView(errorMessage)
      } else if store.quizQuestions.isEmpty {
        emptyStateView
      } else {
        quizContentView
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.brainyBackground)
    .navigationBarHidden(true)
    .task {
      store.send(.startStage)
    }
  }
}

extension QuizPlayPage {
  private var timerColor: Color {
    return switch store.timeRemaining {
    case 0..<30: .brainyError
    case 30..<60: .brainyWarning
    default: .brainyTextSecondary
    }
  }

  private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }

  private func showHintForCurrentQuestion() {
    // TODO: Implement hint functionality
    // This could show the first letter of the answer, eliminate wrong options, etc.
    print("Hint requested for current question")
  }
}

extension QuizPlayPage {

  private var loadingView: some View {
    VStack(spacing: 24) {
      ProgressView()
        .scaleEffect(1.5)
        .tint(.brainyPrimary)

      Text("퀴즈를 준비하고 있습니다...")
        .font(.brainyBodyLarge)
        .foregroundColor(.brainyTextSecondary)
    }
  }

  private func errorView(_ message: String) -> some View {
    VStack(spacing: 24) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 48))
        .foregroundColor(.brainyError)

      Text("오류가 발생했습니다")
        .font(.brainyHeadlineMedium)
        .foregroundColor(.brainyText)

      Text(message)
        .font(.brainyBodyLarge)
        .foregroundColor(.brainyTextSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      VStack(spacing: 12) {
        BrainyButton("다시 시도", style: .primary) {
//          store.send(.startQuiz)
        }

        BrainyButton("뒤로 가기", style: .secondary) {
          store.send(.goToBack)
        }
      }
      .padding(.horizontal)
    }
    .padding()
  }

  private var emptyStateView: some View {
    VStack(spacing: 24) {
      Image(systemName: "questionmark.circle")
        .font(.system(size: 48))
        .foregroundColor(.brainyTextSecondary)

      Text("문제가 없습니다")
        .font(.brainyHeadlineMedium)
        .foregroundColor(.brainyText)

      Text("해당 카테고리에 \(store.quizType.displayName) 문제가 없습니다.")
        .font(.brainyBodyLarge)
        .foregroundColor(.brainyTextSecondary)
        .multilineTextAlignment(.center)

      BrainyButton("뒤로 가기", style: .primary) {
        store.send(.goToBack)
      }
      .padding(.horizontal)
    }
    .padding()
  }

  private var quizContentView: some View {
    VStack(spacing: 0) {
      // Header with progress and timer
      headerView

      // Question content
      ScrollView {
        VStack(spacing: 24) {
          questionView
          answerInputView
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 100) // Space for bottom button
      }

      Spacer()

      // Bottom action button
      bottomActionView
    }
  }

  private var questionView: some View {
    BrainyCard(style: .quiz, shadow: .medium) {
      VStack(alignment: .leading, spacing: 16) {
        // Question type badge
        HStack {
          Text(store.quizType.displayName)
            .font(.brainyLabelMedium)
            .foregroundColor(.brainyPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.brainyPrimary.opacity(0.1))
            .cornerRadius(16)

          Spacer()

          //          // Reward ad button for hints
          //          RewardedAdButton(title: "힌트") {
          //            // Show hint for current question
          //            showHintForCurrentQuestion()
          //          }

          Text(store.quizCategory.displayName)
            .font(.brainyLabelMedium)
            .foregroundColor(.brainyTextSecondary)
        }

        // Question text
        Text(store.currentQuestion?.question ?? "")
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyText)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  // MARK: - Answer Input View
  private var answerInputView: some View {
    Group {
      if let question = store.currentQuestion {
        switch question.type {
        case .multipleChoice:
          multipleChoiceView(question: question)
        case .voice:
          voiceQuizView(question: question)
        case .ai:
          shortAnswerView
        }
      }
    }
  }

  private func multipleChoiceView(question: QuizQuestionDTO) -> some View {
    VStack(spacing: 12) {
      ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
        BrainyQuizCard(
          isSelected: store.selectedOptionIndex == index,
          onTap: {
            store.send(.selectOption(index))
          }
        ) {
          HStack {
            // Option letter (A, B, C, D)
            Text(String(Character(UnicodeScalar(65 + index)!)))
              .font(.brainyBodyMedium)
              .fontWeight(.semibold)
              .foregroundColor(.brainyPrimary)
              .frame(width: 24, height: 24)
              .background(Color.brainyPrimary.opacity(0.1))
              .cornerRadius(12)

            Text(option)
              .font(.brainyBodyLarge)
              .foregroundColor(.brainyText)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)

            Spacer()
          }
        }
      }
    }
  }

  private var shortAnswerView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("답안을 입력하세요")
        .font(.brainyBodyMedium)
        .foregroundColor(.brainyTextSecondary)

      BrainyTextField(
        text: $store.shortAnswerText,
        placeholder: "답안을 입력하세요...",
        style: .outlined
      )
    }
  }

  private var headerView: some View {
    VStack(spacing: 16) {
      // Progress bar
      HStack {
        Button(action: {
          store.send(.goToBack)
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.brainyText)
        }

        Spacer()

        Text("\(store.currentQuestionIndex + 1) / \(store.quizQuestions.count)")
          .font(.brainyBodyMedium)
          .foregroundColor(.brainyTextSecondary)

        Spacer()

        HStack(spacing: 12) {
          // History button
          Button(action: {
            store.send(.goToHistory)
          }) {
            Image(systemName: "clock.arrow.circlepath")
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(.brainyPrimary)
          }
          
          // Timer
          HStack(spacing: 4) {
            Image(systemName: "clock")
              .font(.system(size: 14))
              .foregroundColor(timerColor)

            Text(formatTime(store.timeRemaining))
              .font(.brainyBodyMedium)
              .foregroundColor(timerColor)
          }
        }
      }
      .padding(.horizontal, 24)

      // Progress bar
      ProgressView(value: store.progress)
        .tint(.brainyPrimary)
        .scaleEffect(y: 2)
        .padding(.horizontal, 24)

      // Reward status
      //      AdRewardStatusView()
      //        .padding(.horizontal, 24)
    }
    .padding(.top, 16)
    .padding(.bottom, 24)
    .background(Color.brainyBackground)
  }

  private var bottomActionView: some View {
    VStack(spacing: 16) {
      Divider()
        .background(Color.brainyTextSecondary.opacity(0.2))

      HStack(spacing: 16) {
        BrainyButton(
          "건너뛰기",
          style: .ghost,
          size: .medium
        ) {
          store.send(.submitAnswer)
        }

        // Submit/Next button
        BrainyButton(
          store.isLastQuestion ? "완료" : "다음",
          style: .primary,
          size: .medium,
          isEnabled: store.hasAnswered
        ) {
          store.send(.submitAnswer)
        }
      }
      .padding(.horizontal, 24)
    }
    .padding(.bottom, 34) // Safe area bottom padding
    .background(Color.brainyBackground)
  }

  private func voiceQuizView(question: QuizQuestionDTO) -> some View {
    VoiceQuizView(question: question) { answer in
      store.send(.changeShortAnswerText(answer))
    }
  }
}
