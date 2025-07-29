import ComposableArchitecture

@Reducer
struct AppFeature {

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    var rootState = SignInReducer.State()
  }

  enum Action {
    case Path(StackAction<Path.State, Path.Action>)
    case root(SignInReducer.Action)
  }

  @Reducer(state: .equatable)
  enum Path {
    case signIn(SignInReducer)
    case quizModeSelection(QuizModeSelectionReducer)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .Path, .root:
        return .none
      }
    }
    .forEach(\.path, action: \.Path)
  }
}
