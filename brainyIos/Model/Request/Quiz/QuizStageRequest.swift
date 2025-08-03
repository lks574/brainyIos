import Foundation

struct CreateQuizStageRequest: Codable, Sendable, Equatable {
  let stageNumber: Int
  let category: QuizCategory
  let difficulty: QuizDifficulty
  let title: String
  let requiredAccuracy: Double
  let totalQuestions: Int
  
  init(
    stageNumber: Int,
    category: QuizCategory,
    difficulty: QuizDifficulty,
    title: String,
    requiredAccuracy: Double = 0.7,
    totalQuestions: Int = 10
  ) {
    self.stageNumber = stageNumber
    self.category = category
    self.difficulty = difficulty
    self.title = title
    self.requiredAccuracy = requiredAccuracy
    self.totalQuestions = totalQuestions
  }
}

struct QuizStageFilterRequest: Codable, Sendable, Equatable {
  let category: QuizCategory?
  let difficulty: QuizDifficulty?
  let userId: String? // For checking unlock status
  let limit: Int?
  
  init(
    category: QuizCategory? = nil,
    difficulty: QuizDifficulty? = nil,
    userId: String? = nil,
    limit: Int? = nil
  ) {
    self.category = category
    self.difficulty = difficulty
    self.userId = userId
    self.limit = limit
  }
}