import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToQuizModeSelection: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToQuizModeSelection: { print("📲 QuizModeSelection") }
  )

  static let testValue = NavigationClient(
    goToQuizModeSelection: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}
