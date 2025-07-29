import SwiftUI
import ComposableArchitecture

@main
struct brainyIosApp: App {

  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      SignInPage(store: .init(initialState: .init(), reducer: {
        SignInReducer()
      }))
    }
  }
}
