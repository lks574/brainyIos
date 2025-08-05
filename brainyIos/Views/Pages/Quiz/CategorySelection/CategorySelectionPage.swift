import ComposableArchitecture
import SwiftUI

struct CategorySelectionPage: View {
  @Bindable var store: StoreOf<CategorySelectionReducer>

  var body: some View {
    VStack(spacing: 24) {
      // 헤더
      headerSection

      ScrollView {
        VStack(spacing: 20) {
          // 문제 필터 선택 (전체 무작위 vs 풀었던 것 제외)
          questionFilterSection

          // 카테고리 선택
          categorySection
        }
        .padding(.horizontal, 24)
      }

      // 하단 버튼
      bottomSection
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.brainyBackground)
    .navigationBarHidden(true)
    .onAppear {
      store.send(.loadCategoryProgress)
    }
  }
}

extension CategorySelectionPage {
  private var headerSection: some View {
    VStack(spacing: 12) {
      Text("플레이 형식")
        .font(.brainyTitle)
        .foregroundColor(.brainyText)
    }
    .padding(.horizontal, 24)
    .padding(.top, 16)
  }

  private var questionFilterSection: some View {
    VStack(alignment: .leading, spacing: 12) {
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
            isSelected: store.selectedCategory == category,
            progress: store.categoryProgress[category]
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
        store.send(.goToQuizPlay)
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
