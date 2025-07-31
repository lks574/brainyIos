import Combine
import Foundation
import SwiftData

final class SwiftDataManager: ObservableObject {
  private let modelContainer: ModelContainer
  private let modelContext: ModelContext

  init() throws {
    let schema = Schema([
      UserEntity.self,
      QuizQuestionEntity.self,
      QuizSessionEntity.self,
      QuizResultEntity.self
    ])

    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false)

    self.modelContainer = try ModelContainer(
      for: schema,
      configurations: [modelConfiguration]
    )

    self.modelContext = ModelContext(modelContainer)
  }

  func createUser(_ req: CreateUserRequest) throws -> UserDTO {
    let user = UserEntity(
      id: UUID().uuidString,
      username: req.username,
      email: req.email,
      profileImageURL: req.profileImageURL
    )
    modelContext.insert(user)
    try modelContext.save()
    return UserDTO(from: user)
  }

  func fetchUsers() throws -> [UserDTO] {
    let descriptor = FetchDescriptor<UserEntity>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    let users = try modelContext.fetch(descriptor)
    return users.map { UserDTO(from: $0) }
  }

  func fetchUser(by id: String) throws -> UserDTO? {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return nil }
    return UserDTO(from: user)
  }

  func updateUser(id: String, with req: UserUpdateRequest) throws -> UserDTO? {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return nil }

    if let username = req.username {
      user.username = username
    }
    if let email = req.email {
      user.email = email
    }
    if let profileImageURL = req.profileImageURL {
      user.profileImageURL = profileImageURL
    }
    if let favoriteCategory = req.favoriteCategory {
      user.favoriteCategory = favoriteCategory
    }
    
    user.updateTimestamp()
    try modelContext.save()
    return UserDTO(from: user)
  }

  func updateUserStats(id: String, with req: UserStatsUpdateRequest) throws -> UserDTO? {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return nil }

    if let totalQuizzesTaken = req.totalQuizzesTaken {
      user.totalQuizzesTaken = totalQuizzesTaken
    }
    if let totalCorrectAnswers = req.totalCorrectAnswers {
      user.totalCorrectAnswers = totalCorrectAnswers
    }
    if let currentStreak = req.currentStreak {
      user.currentStreak = currentStreak
    }
    if let bestStreak = req.bestStreak {
      user.bestStreak = bestStreak
    }
    
    user.updateTimestamp()
    try modelContext.save()
    return UserDTO(from: user)
  }

  func getCurrentUser() throws -> UserDTO? {
    let descriptor = FetchDescriptor<UserEntity>(
      sortBy: [SortDescriptor(\.createdAt, order: .forward)]
    )
    guard let user = try modelContext.fetch(descriptor).first else { return nil }
    return UserDTO(from: user)
  }

  func deleteUser(id: String) throws -> Bool {
    let predicate = #Predicate<UserEntity> { user in
      user.id == id
    }
    let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
    guard let user = try modelContext.fetch(descriptor).first else { return false }

    modelContext.delete(user)
    try modelContext.save()
    return true
  }
}
