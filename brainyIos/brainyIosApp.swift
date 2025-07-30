import SwiftUI
import ComposableArchitecture

@main
struct brainyIosApp: App {

  @State private var store: StoreOf<AppFeature>

  init() {
    let store = Store(initialState: AppFeature.State()) {
      AppFeature()
    }
    self._store = State(initialValue: store)
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .onAppear {
          setupNavigationDependency()
        }
    }
  }

  private func setupNavigationDependency() {
    NavigationClient.liveValue = NavigationClient(
      goToQuizModeSelection: { [store] in
        await store.send(.goToQuizModeSelection)
      },
      goToCategorySelection: { [store] quizMode, quizType in
        await store.send(.goToCategorySelection(quizMode, quizType))
      },
      goToProfile: { [store] in
        await store.send(.goToProfile)
      },
      goToBack: { [store] in
        await store.send(.goToBack)
      }
    )
  }
}

