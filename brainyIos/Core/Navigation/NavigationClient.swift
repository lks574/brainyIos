import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToQuizModeSelection: @Sendable () async -> Void
  var goToCategorySelection: @Sendable (QuizMode, QuizType) async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToQuizModeSelection: { print("📲 QuizModeSelection") },
    goToCategorySelection: { _, _ in print("📲 CategorySelection") }
  )

  static let testValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _, _ in }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}
