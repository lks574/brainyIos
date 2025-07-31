import ComposableArchitecture
import SwiftUI

@Reducer
struct QuizModeSelectionReducer {

  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    var selectedQuizType: QuizType?
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case changeQuizType(QuizType)
    case goToCategory(QuizType)
    case goToProfile
    case goToHistoryList
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

      case let .goToCategory(quizType):
        return .run { _ in
          await navigation.goToCategorySelection(quizType)
        }

      case .goToProfile:
        return .run { _ in
          await navigation.goToProfile()
        }

      case .goToHistoryList:
        return .run { _ in
          await navigation.goToHistoryList()
        }

      }
    }
  }
}

