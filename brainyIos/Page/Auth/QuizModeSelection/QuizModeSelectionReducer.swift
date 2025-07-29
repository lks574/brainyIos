import ComposableArchitecture
import SwiftUI

@Reducer
struct QuizModeSelectionReducer {

  @ObservableState
  struct State: Equatable {
    var selectedQuizType: QuizType?
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case changeQuizType(QuizType)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .changeQuizType(let quizType):
        state.selectedQuizType = quizType
        return .none
      }
    }
  }
}

