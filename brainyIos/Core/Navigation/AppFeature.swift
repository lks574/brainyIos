import ComposableArchitecture

@Reducer
struct AppFeature {

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    var rootState = SignInReducer.State()
  }

  // TODO: 추후 Root 따로 만들것.
  // 업데이트 여부, 로그인 여부 파악 하여 Page 변경
  // root / path는 완전 다름
  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case goToQuizModeSelection
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
      case .goToQuizModeSelection:
        state.path.append(.quizModeSelection(QuizModeSelectionReducer.State()))
        return .none

      case .root(.goToQuizModeSelection):
        state.path.append(.quizModeSelection(QuizModeSelectionReducer.State()))
        return .none

      case .path, .root:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}
