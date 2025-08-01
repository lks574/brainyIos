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
    var selectOption: Int?

    var isLastQuestion: Bool = false
    var hasAnswered: Bool = false

    var timeRemaining: Int = 0
    var progress: Float = 0

    var isLoading: Bool = false
    var errorMessage: String?

    var currentQuestion: QuizQuestionDTO?

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
        return .none

      case .changeShortAnswerText(let shortAnswerText):
        state.shortAnswerText = shortAnswerText
        return .none

      case .selectOption(let optionIndex):
        state.selectOption = optionIndex
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
        state.currentQuestion = questions.first
        state.progress = 0.0
        return .none
        
      case .quizLoadFailed(let errorMessage):
        state.isLoading = false
        state.errorMessage = errorMessage
        print("aaa", errorMessage)
        return .none
      }
    }
  }
}
