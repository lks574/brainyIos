import ComposableArchitecture
import Foundation

@DependencyClient
struct QuizGameClient {
  // MARK: - Game Session Management
  var startStage: @Sendable (String, String) async throws -> QuizGameSession
  var submitAnswer: @Sendable (String, String, String, Bool, TimeInterval) async throws -> QuizAnswerResult
  var completeStage: @Sendable (String) async throws -> QuizStageResultDTO
  var pauseGame: @Sendable (String) async throws -> Void
  var resumeGame: @Sendable (String) async throws -> Void
  var quitGame: @Sendable (String) async throws -> Void
  
  // MARK: - Game State
  var getCurrentSession: @Sendable (String) async throws -> QuizGameSession?
  var getNextQuestion: @Sendable (String) async throws -> QuizQuestionDTO?
  var getSessionProgress: @Sendable (String) async throws -> GameProgress
}

extension QuizGameClient: DependencyKey {
  static let liveValue: QuizGameClient = {
    let quizClient = QuizClient.liveValue
    var activeSessions: [String: QuizGameSession] = [:]
    
    return QuizGameClient(
      startStage: { userId, stageId in
        // Get stage and questions
        guard let stage = try await quizClient.fetchStage(stageId) else {
          throw QuizGameError.stageNotFound
        }
        
        // Check if stage is unlocked
        let isUnlocked = try await quizClient.isStageUnlocked(userId, stageId)
        guard isUnlocked else {
          throw QuizGameError.stageNotUnlocked
        }
        
        let questions = try await quizClient.fetchQuestionsForStage(stageId)
        guard !questions.isEmpty else {
          throw QuizGameError.noQuestionsFound
        }
        
        let session = QuizGameSession(
          id: UUID().uuidString,
          userId: userId,
          stage: stage,
          questions: questions,
          startedAt: Date()
        )
        
        activeSessions[session.id] = session
        return session
      },
      
      submitAnswer: { sessionId, questionId, userAnswer, isCorrect, timeSpent in
        guard var session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        
        let result = QuizAnswerResult(
          questionId: questionId,
          userAnswer: userAnswer,
          isCorrect: isCorrect,
          timeSpent: timeSpent
        )
        
        session.submitAnswer(result)
        activeSessions[sessionId] = session
        
        return result
      },
      
      completeStage: { sessionId in
        guard let session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        
        let totalScore = session.answers.filter { $0.isCorrect }.count
        let totalTime = session.answers.reduce(0) { $0 + $1.timeSpent }
        
        let stageResult = try await quizClient.createStageResult(
          session.userId,
          session.stage.id,
          totalScore,
          totalTime
        )
        
        // Remove session after completion
        activeSessions.removeValue(forKey: sessionId)
        
        return stageResult
      },
      
      pauseGame: { sessionId in
        guard var session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        session.pause()
        activeSessions[sessionId] = session
      },
      
      resumeGame: { sessionId in
        guard var session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        session.resume()
        activeSessions[sessionId] = session
      },
      
      quitGame: { sessionId in
        activeSessions.removeValue(forKey: sessionId)
      },
      
      getCurrentSession: { sessionId in
        return activeSessions[sessionId]
      },
      
      getNextQuestion: { sessionId in
        guard let session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        return session.nextQuestion
      },
      
      getSessionProgress: { sessionId in
        guard let session = activeSessions[sessionId] else {
          throw QuizGameError.sessionNotFound
        }
        return session.progress
      }
    )
  }()
}

extension DependencyValues {
  var quizGameClient: QuizGameClient {
    get { self[QuizGameClient.self] }
    set { self[QuizGameClient.self] = newValue }
  }
}

// MARK: - Test Implementation
extension QuizGameClient {
  static let testValue = QuizGameClient(
    startStage: { _, _ in .mock },
    submitAnswer: { _, _, _, _, _ in .mock },
    completeStage: { _ in .mock },
    pauseGame: { _ in },
    resumeGame: { _ in },
    quitGame: { _ in },
    getCurrentSession: { _ in .mock },
    getNextQuestion: { _ in .mock },
    getSessionProgress: { _ in .mock }
  )
  
  static let previewValue = testValue
}

// MARK: - Supporting Types
struct QuizGameSession: Equatable, Sendable {
  let id: String
  let userId: String
  let stage: QuizStageDTO
  let questions: [QuizQuestionDTO]
  let startedAt: Date
  var answers: [QuizAnswerResult] = []
  var currentQuestionIndex: Int = 0
  var isPaused: Bool = false
  var pausedAt: Date?
  var totalPausedTime: TimeInterval = 0
  
  var nextQuestion: QuizQuestionDTO? {
    guard currentQuestionIndex < questions.count else { return nil }
    return questions[currentQuestionIndex]
  }
  
  var progress: GameProgress {
    GameProgress(
      currentQuestion: currentQuestionIndex + 1,
      totalQuestions: questions.count,
      correctAnswers: answers.filter { $0.isCorrect }.count,
      timeElapsed: Date().timeIntervalSince(startedAt) - totalPausedTime
    )
  }
  
  var isCompleted: Bool {
    return currentQuestionIndex >= questions.count
  }
  
  mutating func submitAnswer(_ result: QuizAnswerResult) {
    answers.append(result)
    currentQuestionIndex += 1
  }
  
  mutating func pause() {
    isPaused = true
    pausedAt = Date()
  }
  
  mutating func resume() {
    if let pausedAt = pausedAt {
      totalPausedTime += Date().timeIntervalSince(pausedAt)
    }
    isPaused = false
    pausedAt = nil
  }
}

struct QuizAnswerResult: Equatable, Sendable {
  let questionId: String
  let userAnswer: String
  let isCorrect: Bool
  let timeSpent: TimeInterval
}

struct GameProgress: Equatable, Sendable {
  let currentQuestion: Int
  let totalQuestions: Int
  let correctAnswers: Int
  let timeElapsed: TimeInterval
  
  var progressPercentage: Double {
    guard totalQuestions > 0 else { return 0 }
    return Double(currentQuestion - 1) / Double(totalQuestions)
  }
  
  var accuracy: Double {
    guard currentQuestion > 1 else { return 0 }
    return Double(correctAnswers) / Double(currentQuestion - 1)
  }
}

enum QuizGameError: Error, Equatable {
  case stageNotFound
  case stageNotUnlocked
  case noQuestionsFound
  case sessionNotFound
  case gameAlreadyCompleted
  case invalidAnswer
}

// MARK: - Mock Data
extension QuizGameSession {
  static let mock = QuizGameSession(
    id: "session-1",
    userId: "user-1",
    stage: .mock,
    questions: .mockList,
    startedAt: Date()
  )
}

extension QuizAnswerResult {
  static let mock = QuizAnswerResult(
    questionId: "question-1",
    userAnswer: "서울",
    isCorrect: true,
    timeSpent: 5.0
  )
}

extension GameProgress {
  static let mock = GameProgress(
    currentQuestion: 3,
    totalQuestions: 10,
    correctAnswers: 2,
    timeElapsed: 45.0
  )
}