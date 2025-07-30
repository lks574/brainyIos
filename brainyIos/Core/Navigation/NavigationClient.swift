import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToQuizModeSelection: @Sendable () async -> Void
  var goToCategorySelection: @Sendable (QuizMode, QuizType) async -> Void
  var goToProfile: @Sendable () async -> Void
  var goToHistoryList: @Sendable () async -> Void
  var goToBack: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _, _ in },
    goToProfile: { },
    goToHistoryList: { },
    goToBack: { }
  )

  static let testValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _, _ in },
    goToProfile: { },
    goToHistoryList: { },
    goToBack: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}
