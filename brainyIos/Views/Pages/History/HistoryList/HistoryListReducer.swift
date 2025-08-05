import ComposableArchitecture
import SwiftUI

@Reducer
struct HistoryListReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.quizClient) var quizClient

  @ObservableState
  struct State: Equatable {
    // UI State
    var showingFilters: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Filter State
    var selectedCategory: QuizCategory? = nil
    var selectedTimeRange: HistoryTimeRange = .all
    var showOnlyCleared: Bool = false
    
    // Data State
    var historyItems: [HistoryItem] = []
    var filteredItems: [HistoryItem] = []
    
    // Statistics
    var totalQuizzes: Int = 0
    var averageScore: Double = 0
    var totalTimeSpent: TimeInterval = 0
    var totalStars: Int = 0
    var clearedCount: Int = 0
    
    var isEmpty: Bool {
      filteredItems.isEmpty
    }
    
    var averageScorePercentage: String {
      String(format: "%.1f%%", averageScore * 100)
    }
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack
    
    // Data Loading
    case loadHistory
    case historyLoaded([HistoryItem])
    case historyLoadFailed(String)
    
    // Filtering
    case toggleFilters
    case selectCategory(QuizCategory?)
    case selectTimeRange(HistoryTimeRange)
    case toggleShowOnlyCleared
    case applyFilters
    case clearFilters
    
    // Actions
    case retryStage(String) // 스테이지 다시 도전
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .goToBack:
        return .run { _ in
          await navigation.goToBack()
        }
        
      case .loadHistory:
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { send in
          do {
            let userId = getCurrentUserId()
            let results = try await quizClient.fetchStageResults(userId, nil, nil)
            
            let historyItems = results.map { result in
              HistoryItem(
                id: result.id,
                stageId: result.stageId,
                category: getCategoryFromStageId(result.stageId),
                score: result.score,
                totalQuestions: 10, // 기본값
                accuracy: result.accuracy,
                stars: result.stars,
                timeSpent: result.timeSpent,
                completedAt: result.completedAt,
                isCleared: result.isCleared
              )
            }
            
            await send(.historyLoaded(historyItems))
          } catch {
            await send(.historyLoadFailed(error.localizedDescription))
          }
        }
        
      case .historyLoaded(let items):
        state.isLoading = false
        state.historyItems = items.sorted { $0.completedAt > $1.completedAt }
        state.filteredItems = state.historyItems
        
        // 통계 계산
        updateStatistics(&state)
        
        return .send(.applyFilters)
        
      case .historyLoadFailed(let error):
        state.isLoading = false
        state.errorMessage = error
        return .none
        
      case .toggleFilters:
        state.showingFilters.toggle()
        return .none
        
      case .selectCategory(let category):
        state.selectedCategory = category
        return .send(.applyFilters)
        
      case .selectTimeRange(let timeRange):
        state.selectedTimeRange = timeRange
        return .send(.applyFilters)
        
      case .toggleShowOnlyCleared:
        state.showOnlyCleared.toggle()
        return .send(.applyFilters)
        
      case .applyFilters:
        state.filteredItems = filterItems(state.historyItems, state: state)
        return .none
        
      case .clearFilters:
        state.selectedCategory = nil
        state.selectedTimeRange = .all
        state.showOnlyCleared = false
        return .send(.applyFilters)
        
      case .retryStage(let stageId):
        // 해당 스테이지로 이동
        return .run { _ in
          // stageId에서 카테고리 추출
          let category = getCategoryFromStageId(stageId)
          await navigation.goToQuizPlay(.multipleChoice, stageId, category)
        }
      }
    }
  }
  
  // MARK: - Helper Functions
  
  private func getCurrentUserId() -> String {
    return UserDefaults.standard.string(forKey: "current_user_id") ?? "default_user"
  }
  
  private func getCategoryFromStageId(_ stageId: String) -> QuizCategory {
    let components = stageId.components(separatedBy: "_")
    guard let categoryString = components.first,
          let category = QuizCategory(rawValue: categoryString) else {
      return .general
    }
    return category
  }
  
  private func updateStatistics(_ state: inout State) {
    let items = state.historyItems
    
    state.totalQuizzes = items.count
    state.clearedCount = items.filter { $0.isCleared }.count
    state.totalStars = items.reduce(0) { $0 + $1.stars }
    state.totalTimeSpent = items.reduce(0) { $0 + $1.timeSpent }
    
    if !items.isEmpty {
      state.averageScore = items.reduce(0) { $0 + $1.accuracy } / Double(items.count)
    }
  }
  
  private func filterItems(_ items: [HistoryItem], state: State) -> [HistoryItem] {
    var filtered = items
    
    // 카테고리 필터
    if let category = state.selectedCategory {
      filtered = filtered.filter { $0.category == category }
    }
    
    // 클리어 여부 필터
    if state.showOnlyCleared {
      filtered = filtered.filter { $0.isCleared }
    }
    
    // 시간 범위 필터
    let now = Date()
    switch state.selectedTimeRange {
    case .today:
      let startOfDay = Calendar.current.startOfDay(for: now)
      filtered = filtered.filter { $0.completedAt >= startOfDay }
    case .week:
      let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
      filtered = filtered.filter { $0.completedAt >= weekAgo }
    case .month:
      let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
      filtered = filtered.filter { $0.completedAt >= monthAgo }
    case .all:
      break
    }
    
    return filtered
  }
}
// MARK: - Supporting Types

struct HistoryItem: Equatable, Sendable, Identifiable {
  let id: String
  let stageId: String
  let category: QuizCategory
  let score: Int
  let totalQuestions: Int
  let accuracy: Double
  let stars: Int
  let timeSpent: TimeInterval
  let completedAt: Date
  let isCleared: Bool
  
  var accuracyPercentage: String {
    return String(format: "%.0f%%", accuracy * 100)
  }
  
  var starsDisplay: String {
    return String(repeating: "⭐", count: stars)
  }
  
  var formattedTime: String {
    let minutes = Int(timeSpent) / 60
    let seconds = Int(timeSpent) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: completedAt)
  }
  
  var categoryDisplayName: String {
    return category.displayName
  }
  
  var stageDisplayName: String {
    let components = stageId.components(separatedBy: "_")
    if components.count >= 3,
       let stageNumber = components.last {
      return "\(categoryDisplayName) \(stageNumber)단계"
    }
    return stageId
  }
}

enum HistoryTimeRange: String, CaseIterable, Sendable {
  case today = "today"
  case week = "week"
  case month = "month"
  case all = "all"
  
  var displayName: String {
    switch self {
    case .today: return "오늘"
    case .week: return "1주일"
    case .month: return "1개월"
    case .all: return "전체"
    }
  }
}