import ComposableArchitecture
import SwiftUI

@Reducer
struct CategorySelectionReducer {

  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    let quizMode: QuizMode
    let quizType: QuizType

    var selectedCategory: QuizCategory?
    var selectedPlayMode: QuizMode = .individual
    var selectedQuestionFilter: QuestionFilter = .random
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack
    case changePlayMode(QuizMode)
    case changeFilter(QuestionFilter)
    case changeCategory(QuizCategory)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .goToBack:
        return .none

      case .changePlayMode(let quizMode):
        state.selectedPlayMode = quizMode
        return .none

      case .changeFilter(let filter):
        state.selectedQuestionFilter = filter
        return .none

      case .changeCategory(let category):
        state.selectedCategory = category
        return .none
      }
    }
  }
}



