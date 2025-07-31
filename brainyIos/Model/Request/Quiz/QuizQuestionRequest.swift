import Foundation

struct CreateQuizQuestionRequest: Codable, Sendable, Equatable {
  let question: String
  let correctAnswer: String
  let options: [String]?
  let category: QuizCategory
  let difficulty: QuizDifficulty
  let type: QuizType
  let audioURL: String?
  
  init(
    question: String,
    correctAnswer: String,
    category: QuizCategory,
    difficulty: QuizDifficulty,
    type: QuizType,
    options: [String]? = nil,
    audioURL: String? = nil
  ) {
    self.question = question
    self.correctAnswer = correctAnswer
    self.options = options
    self.category = category
    self.difficulty = difficulty
    self.type = type
    self.audioURL = audioURL
  }
}

struct QuizQuestionFilterRequest: Codable, Sendable, Equatable {
  let category: QuizCategory?
  let difficulty: QuizDifficulty?
  let type: QuizType?
  let filter: QuestionFilter
  let userId: String? // 풀었던 문제 제외용
  let limit: Int?
  
  init(
    category: QuizCategory? = nil,
    difficulty: QuizDifficulty? = nil,
    type: QuizType? = nil,
    filter: QuestionFilter = .random,
    userId: String? = nil,
    limit: Int? = nil
  ) {
    self.category = category
    self.difficulty = difficulty
    self.type = type
    self.filter = filter
    self.userId = userId
    self.limit = limit
  }
}

struct QuizQuestionUpdateRequest: Codable, Sendable, Equatable {
  let question: String?
  let correctAnswer: String?
  let options: [String]?
  let category: QuizCategory?
  let difficulty: QuizDifficulty?
  let type: QuizType?
  let audioURL: String?
  let isCompleted: Bool?
  
  init(
    question: String? = nil,
    correctAnswer: String? = nil,
    options: [String]? = nil,
    category: QuizCategory? = nil,
    difficulty: QuizDifficulty? = nil,
    type: QuizType? = nil,
    audioURL: String? = nil,
    isCompleted: Bool? = nil
  ) {
    self.question = question
    self.correctAnswer = correctAnswer
    self.options = options
    self.category = category
    self.difficulty = difficulty
    self.type = type
    self.audioURL = audioURL
    self.isCompleted = isCompleted
  }
}