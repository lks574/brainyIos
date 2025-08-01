import ComposableArchitecture
import SwiftUI

@Reducer
struct QuizResultReducer {
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    let session: QuizSessionDTO
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack
    case goToCategorySelection(QuizType)
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
      case let .goToCategorySelection(quizType):
        return .run { _ in
          await navigation.goToCategorySelection(quizType)
        }

      }
    }
  }
}
