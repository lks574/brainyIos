import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToQuizModeSelection: @Sendable () async -> Void
  var goToCategorySelection: @Sendable (QuizType) async -> Void
  var goToProfile: @Sendable () async -> Void
  var goToHistoryList: @Sendable () async -> Void
  var goToQuizPlay: @Sendable (QuizType, String, QuizCategory) async -> Void
  var goToQuizResult: @Sendable (QuizStageResultDTO) async -> Void
  var goToBack: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _ in },
    goToProfile: { },
    goToHistoryList: { },
    goToQuizPlay: { _, _, _ in },
    goToQuizResult: { _ in },
    goToBack: { }
  )

  static let testValue = NavigationClient(
    goToQuizModeSelection: { },
    goToCategorySelection: { _ in },
    goToProfile: { },
    goToHistoryList: { },
    goToQuizPlay: { _, _, _ in },
    goToQuizResult: { _ in },
    goToBack: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}
