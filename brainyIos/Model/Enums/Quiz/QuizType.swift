import Foundation

// MARK: - Quiz Type
enum QuizType: String, Codable, CaseIterable, Sendable {
  case multipleChoice = "multipleChoice"
  case shortAnswer = "shortAnswer"
  case voice
  case ai

  var displayName: String {
    return switch self {
    case .multipleChoice: "객관식"
    case .shortAnswer: "주관식"
    case .voice: "음성모드"
    case .ai: "AI모드"
    }
  }
}

// MARK: - Quiz Mode
enum QuizMode: String, Codable, CaseIterable, Sendable {
  case practice = "practice"
  case timed = "timed"
  case challenge = "challenge"
  case stage = "stage"

  var displayName: String {
    return switch self {
    case .practice: "연습 모드"
    case .timed: "시간 제한"
    case .challenge: "도전 모드"
    case .stage: "스테이지"
    }
  }
}

// MARK: - Quiz Category
enum QuizCategory: String, Codable, CaseIterable, Sendable {
  case general = "general"
  case country = "country"
  case drama = "drama"
  case history = "history"
  case person = "person"
  case music = "music"
  case food = "food"
  case sports = "sports"
  case movie = "movie"

  var displayName: String {
    switch self {
    case .general:
      return "일반상식"
    case .country:
      return "국가"
    case .drama:
      return "드라마"
    case .history:
      return "역사"
    case .person:
      return "인물"
    case .music:
      return "음악"
    case .food:
      return "음식"
    case .sports:
      return "스포츠"
    case .movie:
      return "영화"
    }
  }
}

// MARK: - Quiz Difficulty
enum QuizDifficulty: String, Codable, CaseIterable, Sendable {
  case easy = "easy"
  case medium = "medium"
  case hard = "hard"

  var displayName: String {
    switch self {
    case .easy:
      return "쉬움"
    case .medium:
      return "보통"
    case .hard:
      return "어려움"
    }
  }
}

// MARK: - Question Filter
enum QuestionFilter: String, Codable, CaseIterable, Sendable {
  case random = "random"
  case newest = "newest"
  case oldest = "oldest"
  case difficulty = "difficulty"
  case excludeSolved = "excludeSolved"

  var displayName: String {
    return switch self {
    case .random: "랜덤"
    case .newest: "최신순"
    case .oldest: "오래된순"
    case .difficulty: "난이도순"
    case .excludeSolved: "풀었던 것 제외"
    }
  }
}
