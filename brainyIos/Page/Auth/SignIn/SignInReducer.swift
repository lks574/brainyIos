import ComposableArchitecture
import SwiftUI

@Reducer
struct SignInReducer {

  @ObservableState
  struct State: Equatable {

  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none
      }
    }
  }
}
