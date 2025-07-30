import ComposableArchitecture
import SwiftUI

@Reducer
struct SignInReducer {
  @Dependency(\.swiftDataClient) var swiftDataClient
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    var isLoading: Bool = false
    var email: String = ""
    var password: String = ""
    var showPassword: Bool = false
    var errorMessage: String?
    var isAuthenticated: Bool = false

    var isSignInButtonEnabled: Bool {
      !email.isEmpty && !password.isEmpty && !isLoading
    }

    var isSocialSignInEnabled: Bool {
      !isLoading
    }

    public init() {}
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case togglePasswordVisibility
    case signInWithEmail
    case signInWithApple
    case signInWithGoogle
    case goToQuizModeSelection
    case clearError
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .togglePasswordVisibility:
        state.showPassword.toggle()
        return .none

      case .signInWithEmail:
        return .none

      case .signInWithApple:
        return .none

      case .signInWithGoogle:
        return .none

      case .goToQuizModeSelection:
        return .none

      case .clearError:
        return .none
      }
    }
  }
}
