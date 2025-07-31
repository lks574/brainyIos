import Foundation
import SwiftData

@Model
final class QuizSessionEntity {
  @Attribute(.unique) var id: String
  var userId: String
  var category: QuizCategory
  var mode: QuizMode
  var totalQuestions: Int
  var correctAnswers: Int
  var totalTime: TimeInterval
  var startedAt: Date
  var completedAt: Date?

  @Relationship var results: [QuizResultEntity] = []
  @Relationship var user: UserEntity?

  init(id: String, userId: String, category: QuizCategory, mode: QuizMode, totalQuestions: Int) {
    self.id = id
    self.userId = userId
    self.category = category
    self.mode = mode
    self.totalQuestions = totalQuestions
    self.correctAnswers = 0
    self.totalTime = 0
    self.startedAt = Date()
  }

  /// 로컬 통계 계산용 정확도
  var accuracy: Double {
    guard totalQuestions > 0 else { return 0 }
    return Double(correctAnswers) / Double(totalQuestions)
  }
}
