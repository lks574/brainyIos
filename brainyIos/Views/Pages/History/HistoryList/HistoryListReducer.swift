import ComposableArchitecture
import SwiftUI

@Reducer
struct HistoryListReducer {
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    var showingFilters: Bool = false
    var isLoading: Bool = false

    var totalQuizzes: Int = 0
    var averageScore: Float = 0
    var totalTimeSpent: TimeInterval = 0
    
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack
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
      }
    }
  }
}
