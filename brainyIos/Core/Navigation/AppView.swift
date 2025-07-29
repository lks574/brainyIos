import SwiftUI
import ComposableArchitecture

struct AppView: View {

  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.Path),
      root: { SignInPage(store: store.scope(state: \.rootState, action: \.root)) },
    destination: { store in
      switch store.case {
      case .signIn(let store):
        SignInPage(store: store)
      case .quizModeSelection(let store):
        QuizModeSelectionPage(store: store)
      }
    })
  }
}
