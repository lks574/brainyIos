import ComposableArchitecture
import SwiftUI
import SwiftData

@Reducer
struct CategorySelectionReducer {

  @Dependency(\.navigation) var navigation
  @Dependency(\.quizClient) var quizClient

  @ObservableState
  struct State: Equatable {
    let quizType: QuizType

    var selectedCategory: QuizCategory?
    var selectedQuestionFilter: QuestionFilter = .random
    var categoryProgress: [QuizCategory: CategoryProgress] = [:]
  }
  
  struct CategoryProgress: Equatable {
    let totalStages: Int
    let completedStages: Int
    
    var progressPercentage: Double {
      guard totalStages > 0 else { return 0.0 }
      return Double(completedStages) / Double(totalStages)
    }
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case goToBack
    case goToQuizPlay
    case changeFilter(QuestionFilter)
    case changeCategory(QuizCategory)
    case loadCategoryProgress
    case categoryProgressLoaded([QuizCategory: CategoryProgress])
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

      case .goToQuizPlay:
        guard let category = state.selectedCategory else { return .none }
        
        // 스테이지가 없는 카테고리인지 확인
        let progress = state.categoryProgress[category]
        if let progress = progress, progress.totalStages == 0 {
          // 스테이지가 없는 카테고리에 대한 알림 표시
          return .run { _ in
            // TODO: 알림 UI 표시 로직 추가 필요
            print("선택한 카테고리에는 아직 스테이지가 없습니다.")
          }
        }
        
        // 다음에 풀어야 할 스테이지 ID 결정
        let stageID = getNextStageID(for: category, progress: progress)
        return .run { [state] _ in
          await navigation.goToQuizPlay(state.quizType, stageID, category)
        }

      case .changeFilter(let filter):
        state.selectedQuestionFilter = filter
        return .none

      case .changeCategory(let category):
        state.selectedCategory = category
        return .none
        
      case .loadCategoryProgress:
        return .run { [quizClient] send in
          let userId = getCurrentUserId() // 실제 사용자 ID 가져오기
          let progress = await loadCategoryProgressData(userId: userId, quizClient: quizClient)
          await send(.categoryProgressLoaded(progress))
        }
        
      case .categoryProgressLoaded(let progress):
        state.categoryProgress = progress
        return .none
      }
    }
  }
  
  private func loadCategoryProgressData(userId: String, quizClient: QuizClient) async -> [QuizCategory: CategoryProgress] {
    var progress: [QuizCategory: CategoryProgress] = [:]
    
    for category in QuizCategory.allCases {
      do {
        // QuizClient를 통해 카테고리별 통계 가져오기
        let stats = try await quizClient.getCategoryStageStats(userId, category)
        let stages = try await quizClient.fetchStagesByCategory(category)
        
        progress[category] = CategoryProgress(
          totalStages: stages.count,
          completedStages: stats.completedStages
        )
      } catch {
        print("Error loading progress for category \(category): \(error)")
        // 에러 발생 시 기본값 설정
        progress[category] = CategoryProgress(
          totalStages: 0,
          completedStages: 0
        )
      }
    }
    
    return progress
  }
  
  /// 현재 사용자 ID를 가져옵니다.
  private func getCurrentUserId() -> String {
    // 실제 구현에서는 UserDefaults, Keychain 등에서 사용자 ID를 가져와야 함
    return UserDefaults.standard.string(forKey: "current_user_id") ?? "default_user"
  }
  
  /// 다음에 풀어야 할 스테이지 ID를 반환합니다.
  /// 완료되지 않은 첫 번째 스테이지를 반환하며, 모든 스테이지가 완료된 경우 마지막 스테이지를 반환합니다.
  private func getNextStageID(for category: QuizCategory, progress: CategoryProgress?) -> String {
    guard let progress = progress, progress.totalStages > 0 else {
      // 진행 상황이 없거나 스테이지가 없는 경우 첫 번째 스테이지 반환
      return getStageID(for: category, stageNumber: 1)
    }
    
    // 완료된 스테이지 수가 총 스테이지 수보다 작으면 다음 스테이지 반환
    if progress.completedStages < progress.totalStages {
      let nextStageNumber = progress.completedStages + 1
      return getStageID(for: category, stageNumber: nextStageNumber)
    } else {
      // 모든 스테이지가 완료된 경우 마지막 스테이지 반환 (재플레이 가능)
      return getStageID(for: category, stageNumber: progress.totalStages)
    }
  }
  
  /// 카테고리와 스테이지 번호로 스테이지 ID를 생성합니다.
  private func getStageID(for category: QuizCategory, stageNumber: Int) -> String {
    let categoryString = category.rawValue.lowercased()
    return "\(categoryString)_stage_\(stageNumber)"
  }
}



