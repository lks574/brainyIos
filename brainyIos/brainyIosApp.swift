import SwiftUI
import ComposableArchitecture

@main
struct brainyIosApp: App {
  var body: some Scene {
    WindowGroup {
      SignInPage(store: .init(initialState: .init(), reducer: {
        SignInReducer()
      }))
    }
  }
}
