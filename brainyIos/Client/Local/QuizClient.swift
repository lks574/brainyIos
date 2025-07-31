import ComposableArchitecture

@DependencyClient
struct QuizClient {
  // MARK: - Quiz Questions
  var createQuestion: @Sendable (CreateQuizQuestionRequest) async throws -> QuizQuestionDTO
  var fetchQuestions: @Sendable (QuizQuestionFilterRequest) async throws -> [QuizQuestionDTO]
  var fetchQuestion: @Sendable (String) async throws -> QuizQuestionDTO?
  var updateQuestion: @Sendable (String, QuizQuestionUpdateRequest) async throws -> QuizQuestionDTO?
  var deleteQuestion: @Sendable (String) async throws -> Bool
  
  // MARK: - Quiz Sessions
  var createSession: @Sendable (CreateQuizSessionRequest) async throws -> QuizSessionDTO
  var fetchSessions: @Sendable (QuizSessionFilterRequest) async throws -> [QuizSessionDTO]
  var fetchSession: @Sendable (String) async throws -> QuizSessionDTO?
  var updateSession: @Sendable (String, UpdateQuizSessionRequest) async throws -> QuizSessionDTO?
  var deleteSession: @Sendable (String) async throws -> Bool
  
  // MARK: - Quiz Results
  var createResult: @Sendable (CreateQuizResultRequest) async throws -> QuizResultDTO
  var fetchResults: @Sendable (QuizResultFilterRequest) async throws -> [QuizResultDTO]
  var fetchResult: @Sendable (String) async throws -> QuizResultDTO?
  var deleteResult: @Sendable (String) async throws -> Bool
  
  // MARK: - Statistics
  var getUserQuizStats: @Sendable (String) async throws -> (totalQuizzes: Int, correctAnswers: Int, accuracy: Double)
  var getCategoryStats: @Sendable (String, QuizCategory) async throws -> (totalQuizzes: Int, correctAnswers: Int, accuracy: Double)
  
  // MARK: - Initial Data Loading
  var loadInitialDataIfNeeded: @Sendable () async throws -> Void
}

extension QuizClient: DependencyKey {
  static let liveValue: QuizClient = {
    let repository = QuizRepository()
    return QuizClient(
      // MARK: - Quiz Questions
      createQuestion: { req in
        try repository.createQuestion(req)
      },
      fetchQuestions: { filter in
        try repository.fetchQuestions(with: filter)
      },
      fetchQuestion: { id in
        try repository.fetchQuestion(by: id)
      },
      updateQuestion: { id, req in
        try repository.updateQuestion(id: id, with: req)
      },
      deleteQuestion: { id in
        try repository.deleteQuestion(id: id)
      },
      
      // MARK: - Quiz Sessions
      createSession: { req in
        try repository.createSession(req)
      },
      fetchSessions: { filter in
        try repository.fetchSessions(with: filter)
      },
      fetchSession: { id in
        try repository.fetchSession(by: id)
      },
      updateSession: { id, req in
        try repository.updateSession(id: id, with: req)
      },
      deleteSession: { id in
        try repository.deleteSession(id: id)
      },
      
      // MARK: - Quiz Results
      createResult: { req in
        try repository.createResult(req)
      },
      fetchResults: { filter in
        try repository.fetchResults(with: filter)
      },
      fetchResult: { id in
        try repository.fetchResult(by: id)
      },
      deleteResult: { id in
        try repository.deleteResult(id: id)
      },
      
      // MARK: - Statistics
      getUserQuizStats: { userId in
        try repository.getUserQuizStats(userId: userId)
      },
      getCategoryStats: { userId, category in
        try repository.getCategoryStats(userId: userId, category: category)
      },
      
      // MARK: - Initial Data Loading
      loadInitialDataIfNeeded: {
        try repository.loadInitialDataIfNeeded()
      }
    )
  }()
}

extension DependencyValues {
  var quizClient: QuizClient {
    get { self[QuizClient.self] }
    set { self[QuizClient.self] = newValue }
  }
}

// MARK: - Test Implementation
extension QuizClient {
  static let testValue = QuizClient(
    // MARK: - Quiz Questions
    createQuestion: { _ in .mock },
    fetchQuestions: { _ in .mockList },
    fetchQuestion: { _ in .mock },
    updateQuestion: { _, _ in .mock },
    deleteQuestion: { _ in true },
    
    // MARK: - Quiz Sessions
    createSession: { _ in .mock },
    fetchSessions: { _ in [.mock] },
    fetchSession: { _ in .mock },
    updateSession: { _, _ in .mock },
    deleteSession: { _ in true },
    
    // MARK: - Quiz Results
    createResult: { _ in .mock },
    fetchResults: { _ in [.mock] },
    fetchResult: { _ in .mock },
    deleteResult: { _ in true },
    
    // MARK: - Statistics
    getUserQuizStats: { _ in (totalQuizzes: 10, correctAnswers: 8, accuracy: 0.8) },
    getCategoryStats: { _, _ in (totalQuizzes: 5, correctAnswers: 4, accuracy: 0.8) },
    
    // MARK: - Initial Data Loading
    loadInitialDataIfNeeded: { }
  )
  
  static let previewValue = testValue
}
