import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToQuizModeSelection: @Sendable () async -> Void
  var goToCategorySelection: @Sendable (QuizMode, QuizType) async -> Void
  var goToBack: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToQuizModeSelection: { print("📲 QuizModeSelection") },
    goToCategorySelection: { _, _ in print("📲 CategorySelection") },
    goToBack: { }
  )

  static let testValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _, _ in },
    goToBack: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}
