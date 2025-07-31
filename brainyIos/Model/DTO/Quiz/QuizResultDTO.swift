import Foundation

struct QuizResultDTO: Codable, Sendable, Equatable, Identifiable {
  let id: String
  let userId: String
  let questionId: String
  let userAnswer: String
  let isCorrect: Bool
  let timeSpent: TimeInterval
  let completedAt: Date
  let category: QuizCategory
  let quizMode: QuizMode
}

extension QuizResultDTO {
  init(from entity: QuizResultEntity) {
    self.id = entity.id
    self.userId = entity.userId
    self.questionId = entity.questionId
    self.userAnswer = entity.userAnswer
    self.isCorrect = entity.isCorrect
    self.timeSpent = entity.timeSpent
    self.completedAt = entity.completedAt
    self.category = entity.category
    self.quizMode = entity.quizMode
  }
}

// MARK: - Mock Data
extension QuizResultDTO {
  static let mock = QuizResultDTO(
    id: "result-1",
    userId: "user-1",
    questionId: "question-1",
    userAnswer: "서울",
    isCorrect: true,
    timeSpent: 5.2,
    completedAt: Date(),
    category: .general,
    quizMode: .stage
  )
}
