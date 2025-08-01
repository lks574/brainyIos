import SwiftUI
import ComposableArchitecture

struct AppView: View {

  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path),
      root: { SignInPage(store: store.scope(state: \.rootState, action: \.root)) },
    destination: { store in
      switch store.case {
      case .signIn(let store):
        SignInPage(store: store)
      case .quizModeSelection(let store):
        QuizModeSelectionPage(store: store)
      case .categorySelection(let store):
        CategorySelectionPage(store: store)
      case .profile(let store):
        ProfilePage(store: store)
      case .quizPlay(let store):
        QuizPlayPage(store: store)
      case .quizResult(let store):
        QuizResultPage(store: store)
      case .historyList(let store):
        HistoryListPage(store: store)
      }
    })
  }
}
