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
        return .run { _ in
         
        }
      }
    }
  }
}
