import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileReducer {
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    var user: UserDTO?
    var isDarkModeEnabled: Bool = true
    var isNotificationEnabled: Bool = true
    var isSoundEnabled: Bool = true

    var authIsLoading: Bool = false
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
