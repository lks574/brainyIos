import ComposableArchitecture
import SwiftUI
import SwiftData

@Reducer
struct CategorySelectionReducer {

  @Dependency(\.navigation) var navigation

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
        return .run { [state] _ in
          await navigation.goToQuizPlay(state.quizType, category)
        }

      case .changeFilter(let filter):
        state.selectedQuestionFilter = filter
        return .none

      case .changeCategory(let category):
        state.selectedCategory = category
        return .none
        
      case .loadCategoryProgress:
        return .run { send in
          // TODO: 실제 사용자 ID를 가져와야 함
          let userId = "current_user" // 임시 사용자 ID
          let progress = await loadCategoryProgressData(userId: userId)
          await send(.categoryProgressLoaded(progress))
        }
        
      case .categoryProgressLoaded(let progress):
        state.categoryProgress = progress
        return .none
      }
    }
  }
  
  private func loadCategoryProgressData(userId: String) async -> [QuizCategory: CategoryProgress] {
    // SwiftData를 사용해서 실제 스테이지 데이터를 가져오는 로직
    // 실제 구현에서는 ModelContext를 통해 데이터를 가져와야 함
    
    var progress: [QuizCategory: CategoryProgress] = [:]
    
    for category in QuizCategory.allCases {
      // 각 카테고리별 총 스테이지 수 계산
      let totalStages = await getTotalStagesForCategory(category)
      
      // 각 카테고리별 완료된 스테이지 수 계산
      let completedStages = await getCompletedStagesForCategory(category, userId: userId)
      
      progress[category] = CategoryProgress(
        totalStages: totalStages,
        completedStages: completedStages
      )
    }
    
    return progress
  }
  
  private func getTotalStagesForCategory(_ category: QuizCategory) async -> Int {
    // TODO: SwiftData ModelContext를 통해 실제 스테이지 수를 가져와야 함
    // 실제 구현 예시:
    // return QuizStageEntity.getTotalStagesCount(for: category, in: modelContext)
    
    // quiz_data.json 파일 기반 실제 스테이지 수
    switch category {
    case .general: return 2  // general_stage_1, general_stage_2
    case .history: return 1  // history_stage_1
    case .music: return 1    // music_stage_1
    case .food: return 1     // food_stage_1
    case .sports: return 1   // sports_stage_1
    case .movie: return 1    // movie_stage_1
    case .person: return 1   // person_stage_1
    case .country: return 0  // 스테이지 없음
    case .drama: return 0    // 스테이지 없음
    }
  }
  
  private func getCompletedStagesForCategory(_ category: QuizCategory, userId: String) async -> Int {
    // TODO: SwiftData ModelContext를 통해 실제 완료된 스테이지 수를 가져와야 함
    // 실제 구현 예시:
    // return QuizStageEntity.getCompletedStagesCount(for: category, userId: userId, in: modelContext)
    
    // 현재는 테스트용 임시 데이터 - 실제로는 사용자의 완료 기록을 확인해야 함
    let totalStages = await getTotalStagesForCategory(category)
    
    // 스테이지가 없는 카테고리는 0 반환
    guard totalStages > 0 else { return 0 }
    
    // 테스트용으로 현실적인 진행도 설정 (대부분 미완료 상태)
    switch category {
    case .general: return 0  // 2개 중 0개 완료 (0%)
    case .history: return 0  // 1개 중 0개 완료 (0%)
    case .music: return 1    // 1개 중 1개 완료 (100%) - 테스트용으로 하나만 완료
    case .food: return 0     // 1개 중 0개 완료 (0%)
    case .sports: return 0   // 1개 중 0개 완료 (0%)
    case .movie: return 0    // 1개 중 0개 완료 (0%)
    case .person: return 0   // 1개 중 0개 완료 (0%)
    case .country: return 0  // 스테이지 없음
    case .drama: return 0    // 스테이지 없음
    }
  }
}



