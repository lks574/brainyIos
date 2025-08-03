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
        .task {
          await AppInitializer().initializeApp()
          print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        }
    }
  }

  private func setupNavigationDependency() {
    NavigationClient.liveValue = NavigationClient(
      goToQuizModeSelection: { [store] in
        await store.send(.goToQuizModeSelection)
      },
      goToCategorySelection: { [store] quizType in
        await store.send(.goToCategorySelection(quizType))
      },
      goToProfile: { [store] in
        await store.send(.goToProfile)
      },
      goToHistoryList: { [store] in
        await store.send(.goToHistoryList)
      },
      goToQuizPlay: { [store] quizType, quizCategory in
        await store.send(.goToQuizPlay(quizType, quizCategory))
      },
      goToQuizResult: { [store] in

      },
      goToBack: { [store] in
        await store.send(.goToBack)
      }
    )
  }
}

