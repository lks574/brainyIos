import ComposableArchitecture
import SwiftUI

struct CategorySelectionPage: View {
  @Bindable var store: StoreOf<CategorySelectionReducer>

  var body: some View {

    // TODO: View 마무리
  }
}

extension CategorySelectionPage {
  private var headerSection: some View {
    VStack(spacing: 12) {
      Text("카테고리 선택")
        .font(.brainyTitle)
        .foregroundColor(.brainyText)

      Text("퀴즈 모드: \(store.quizMode.rawValue)")
        .font(.brainyBodyMedium)
        .foregroundColor(.brainyTextSecondary)
    }
    .padding(.horizontal, 24)
    .padding(.top, 16)
  }

  private var playModeSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("플레이 형식")
        .font(.brainyHeadlineSmall)
        .foregroundColor(.brainyText)

      HStack(spacing: 12) {
        CategorySelectionPlayModeToggle(
          title: "스테이지",
          description: "순차적 진행",
          icon: "list.number",
          mode: .stage,
          isSelected: store.selectedPlayMode == .stage
        ) {
          store.send(.changePlayMode(.stage))
        }

        CategorySelectionPlayModeToggle(
          title: "개별",
          description: "독립적 풀이",
          icon: "square.grid.2x2",
          mode: .individual,
          isSelected: store.selectedPlayMode == .individual
        ) {
          store.send(.changePlayMode(.individual))
        }
      }
    }
  }

  private var questionFilterSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("문제 선택")
        .font(.brainyHeadlineSmall)
        .foregroundColor(.brainyText)

      VStack(spacing: 8) {
        CategorySelectionQuestionFilterOption(
          title: "전체 무작위",
          description: "모든 문제에서 랜덤 선택",
          icon: "shuffle",
          filter: .random,
          isSelected: store.selectedQuestionFilter == .random
        ) {
          store.send(.changeFilter(.random))
        }

        CategorySelectionQuestionFilterOption(
          title: "풀었던 것 제외",
          description: "이전에 풀지 않은 문제만",
          icon: "checkmark.circle.badge.xmark",
          filter: .excludeSolved,
          isSelected: store.selectedQuestionFilter == .excludeSolved
        ) {
          store.send(.changeFilter(.excludeSolved))
        }
      }
    }
  }

  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("카테고리")
        .font(.brainyHeadlineSmall)
        .foregroundColor(.brainyText)

      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 12) {
        ForEach(QuizCategory.allCases, id: \.self) { category in
          CategorySelectionCategoryCard(
            category: category,
            isSelected: store.selectedCategory == category
          ) {
            store.send(.changeCategory(category))
          }
        }
      }
    }
  }

  private var bottomSection: some View {
    VStack(spacing: 16) {
      // 시작 버튼
      BrainyButton(
        "퀴즈 시작",
        style: .primary,
        size: .large,
        isEnabled: store.selectedCategory != nil
      ) {
        if let category = store.selectedCategory {
          // TODO: 라우팅
        }
      }

      // 뒤로 가기 버튼
      BrainyButton("뒤로 가기", style: .secondary, size: .medium) {
        store.send(.goToBack)
      }
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 32)
  }

}
