import Foundation

struct QuizQuestionDTO: Codable, Sendable, Equatable, Identifiable {
  let id: String
  let question: String
  let correctAnswer: String
  let options: [String]?
  let category: QuizCategory
  let difficulty: QuizDifficulty
  let type: QuizType
  let audioURL: String?
  let isCompleted: Bool
}

extension QuizQuestionDTO {
  init(from entity: QuizQuestionEntity) {
    self.id = entity.id
    self.question = entity.question
    self.correctAnswer = entity.correctAnswer
    self.options = entity.options
    self.category = entity.category
    self.difficulty = entity.difficulty
    self.type = entity.type
    self.audioURL = entity.audioURL
    self.isCompleted = entity.isCompleted
  }
}

// MARK: - Mock Data
extension QuizQuestionDTO {
  static let mock = QuizQuestionDTO(
    id: "question-1",
    question: "대한민국의 수도는 어디인가요?",
    correctAnswer: "서울",
    options: ["서울", "부산", "대구", "인천"],
    category: .general,
    difficulty: .easy,
    type: .multipleChoice,
    audioURL: nil,
    isCompleted: false
  )
}

extension [QuizQuestionDTO] {
  static let mockList = [
    QuizQuestionDTO(
      id: "question-1",
      question: "대한민국의 수도는 어디인가요?",
      correctAnswer: "서울",
      options: ["서울", "부산", "대구", "인천"],
      category: .general,
      difficulty: .easy,
      type: .multipleChoice,
      audioURL: nil,
      isCompleted: false
    ),
    QuizQuestionDTO(
      id: "question-2",
      question: "세종대왕이 만든 문자는 무엇인가요?",
      correctAnswer: "한글",
      options: nil,
      category: .person,
      difficulty: .medium,
      type: .shortAnswer,
      audioURL: nil,
      isCompleted: false
    ),
    QuizQuestionDTO(
      id: "question-3",
      question: "BTS의 리더는 누구인가요?",
      correctAnswer: "RM",
      options: ["RM", "진", "슈가", "제이홉"],
      category: .music,
      difficulty: .easy,
      type: .multipleChoice,
      audioURL: nil,
      isCompleted: true
    )
  ]
}
