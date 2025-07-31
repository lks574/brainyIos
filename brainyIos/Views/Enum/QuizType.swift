import Foundation

enum QuizType: String, CaseIterable, Codable, Sendable {
  case multipleChoice = "객관식"
  case shortAnswer = "주관식"
  case voice = "음성모드"
  case ai = "AI모드"
}

enum QuizMode: String, CaseIterable, Codable, Sendable {
  case stage = "스테이지"
  case individual = "개별"
}

enum QuizDifficulty: String, CaseIterable, Codable, Sendable {
  case easy = "쉬움"
  case medium = "보통"
  case hard = "어려움"
}

enum QuestionFilter: String, CaseIterable, Codable, Sendable {
  case random = "전체 무작위"
  case excludeSolved = "풀었던 것 제외"
}

enum QuizCategory: String, CaseIterable, Codable, Sendable {
  case person = "인물"
  case general = "상식"
  case country = "나라"
  case drama = "드라마"
  case music = "음악"
}
