import ComposableArchitecture
import SwiftUI

@Reducer
struct QuizPlayReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.quizClient) var quizClient

  @ObservableState
  struct State: Equatable {
    let quizType: QuizType
    let quizMode: QuizMode
    let quizCategory: QuizCategory

    var currentQuestionIndex: Int = 0
    var quizQuestions: [QuizQuestionDTO] = []
    var selectedOptionIndex: Int?
    var shortAnswerText: String = ""
    var isLastQuestion: Bool = false

    var timeRemaining: Int = 0
    var progress: Float = 0

    var isLoading: Bool = false
    var errorMessage: String?

    var hasAnswered: Bool {
      if let question = currentQuestion {
        switch question.type {
        case .multipleChoice:
          return selectedOptionIndex != nil
        case .shortAnswer:
          return !shortAnswerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voice, .ai:
          return !shortAnswerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
      }
      return false
    }

    var currentQuestion: QuizQuestionDTO? {
      if quizType == .ai {
        return nil
      } else {
        guard currentQuestionIndex < quizQuestions.count else { return nil }
        return quizQuestions[currentQuestionIndex]
      }
    }

    init(quizType: QuizType, quizMode: QuizMode, quizCategory: QuizCategory) {
      self.quizType = quizType
      self.quizMode = quizMode
      self.quizCategory = quizCategory
    }
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack

    case startQuiz
    case submitAnswer
    case changeShortAnswerText(String)
    case selectOption(Int)

    case getQuiz
    case quizLoaded([QuizQuestionDTO])
    case quizLoadFailed(String)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .goToBack:
        return .run { _ in
          await navigation.goToBack()
        }

      case .startQuiz:
        return .none

      case .submitAnswer:
        // 답변이 있는지 확인
        guard state.hasAnswered else { return .none }
        
        // 다음 문제로 이동
        if state.currentQuestionIndex < state.quizQuestions.count - 1 {
          state.currentQuestionIndex += 1
          state.selectedOptionIndex = nil
          state.shortAnswerText = ""
          
          // 진행률 업데이트
          state.progress = Float(state.currentQuestionIndex) / Float(state.quizQuestions.count)
          
          // 마지막 문제인지 확인
          state.isLastQuestion = state.currentQuestionIndex == state.quizQuestions.count - 1
        } else {
          // 퀴즈 완료 - 결과 페이지로 이동하거나 완료 처리
          state.isLastQuestion = true
          // TODO: 퀴즈 완료 처리 로직 추가
        }
        
        return .none

      case .changeShortAnswerText(let shortAnswerText):
        state.shortAnswerText = shortAnswerText
        return .none

      case .selectOption(let optionIndex):
        state.selectedOptionIndex = optionIndex
        return .none

      case .getQuiz:
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { [quizType = state.quizType, quizCategory = state.quizCategory] send in
          do {
            let filterRequest = QuizQuestionFilterRequest(
              category: quizCategory == .all ? nil : quizCategory,
              difficulty: nil, // 난이도 필터링 없음
              type: quizType,
              filter: .random,
              userId: nil, // 사용자별 필터링 없음
              limit: 10 // 10개 문제로 제한
            )
            
            let questions = try await quizClient.fetchQuestions(filterRequest)
            await send(.quizLoaded(questions))
          } catch {
            await send(.quizLoadFailed(error.localizedDescription))
          }
        }
        
      case .quizLoaded(let questions):
        state.isLoading = false
        state.quizQuestions = questions
        state.progress = 0.0
        return .none
        
      case .quizLoadFailed(let errorMessage):
        state.isLoading = false
        state.errorMessage = errorMessage
        return .none
      }
    }
  }
}
