import ComposableArchitecture
import SwiftUI

struct HistoryListPage: View {
  @Bindable var store: StoreOf<HistoryListReducer>

  var body: some View {
    ZStack {
      Color.brainyBackground
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        headerView
        
        if store.isLoading {
          loadingView
        } else if let errorMessage = store.errorMessage {
          errorView(errorMessage)
        } else if store.isEmpty {
          emptyStateView
        } else {
          contentView
        }
      }
      
      // Filter overlay
      if store.showingFilters {
        filterOverlayView
      }
    }
    .background(Color.brainyBackground)
    .navigationBarHidden(true)
    .task {
      store.send(.loadHistory)
    }
  }
}

extension HistoryListPage {
  private func formatTotalTime(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = (Int(timeInterval) % 3600) / 60

    if hours > 0 {
      return "\(hours)시간 \(minutes)분"
    } else {
      return "\(minutes)분"
    }
  }
}

extension HistoryListPage {
  private var headerView: some View {
    VStack(spacing: 16) {
      HStack {
        Button(action: {
          store.send(.goToBack)
        }) {
          Image(systemName: "chevron.left")
            .font(.title2)
            .foregroundColor(.brainyText)
        }

        Spacer()

        Text("퀴즈 히스토리")
          .font(.brainyTitle)
          .foregroundColor(.brainyText)

        Spacer()

        Button(action: {
          store.send(.toggleFilters)
        }) {
          Image(systemName: store.showingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            .font(.title2)
            .foregroundColor(.brainyPrimary)
        }
      }

      // Statistics Summary
      if !store.historyItems.isEmpty {
        statisticsSummaryView
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 16)
    .padding(.bottom, 8)
  }

  private var statisticsSummaryView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        HistoryStatisticCard(
          title: "총 퀴즈",
          value: "\(store.totalQuizzes)개",
          icon: "doc.text"
        )

        HistoryStatisticCard(
          title: "평균 점수",
          value: store.averageScorePercentage,
          icon: "chart.line.uptrend.xyaxis"
        )

        HistoryStatisticCard(
          title: "총 시간",
          value: formatTotalTime(store.totalTimeSpent),
          icon: "clock"
        )
        
        HistoryStatisticCard(
          title: "획득 별",
          value: "\(store.totalStars)개",
          icon: "star.fill"
        )
        
        HistoryStatisticCard(
          title: "클리어",
          value: "\(store.clearedCount)개",
          icon: "checkmark.circle.fill"
        )
      }
      .padding(.horizontal, 24)
    }
  }

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.2)

      Text("히스토리를 불러오는 중...")
        .font(.brainyBody)
        .foregroundColor(.brainyTextSecondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      // Active filters display
      if hasActiveFilters {
        activeFiltersView
      }
      
      // History list
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(store.filteredItems) { item in
            historyItemView(item)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
      }
    }
  }
  
  private var hasActiveFilters: Bool {
    store.selectedCategory != nil || 
    store.selectedTimeRange != .all || 
    store.showOnlyCleared
  }
  
  private var activeFiltersView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        if let category = store.selectedCategory {
          HistoryFilterChip(
            title: category.displayName,
            isSelected: true
          ) {
            store.send(.selectCategory(nil))
          }
        }
        
        if store.selectedTimeRange != .all {
          HistoryFilterChip(
            title: store.selectedTimeRange.displayName,
            isSelected: true
          ) {
            store.send(.selectTimeRange(.all))
          }
        }
        
        if store.showOnlyCleared {
          HistoryFilterChip(
            title: "클리어만",
            isSelected: true
          ) {
            store.send(.toggleShowOnlyCleared)
          }
        }
        
        Button("전체 해제") {
          store.send(.clearFilters)
        }
        .font(.brainyLabelSmall)
        .foregroundColor(.brainyPrimary)
      }
      .padding(.horizontal, 24)
    }
    .padding(.vertical, 8)
    .background(Color.brainyBackground)
  }
  
  private func historyItemView(_ item: HistoryItem) -> some View {
    BrainyCard(style: .default, shadow: .small) {
      VStack(spacing: 12) {
        // Header: Stage name and date
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(item.stageDisplayName)
              .font(.brainyBodyLarge)
              .foregroundColor(.brainyText)
            
            Text(item.formattedDate)
              .font(.brainyBodySmall)
              .foregroundColor(.brainyTextSecondary)
          }
          
          Spacer()
          
          VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 4) {
              Image(systemName: item.isCleared ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(item.isCleared ? .brainySuccess : .brainyError)
              
              Text(item.isCleared ? "클리어" : "실패")
                .font(.brainyLabelSmall)
                .foregroundColor(item.isCleared ? .brainySuccess : .brainyError)
            }
            
            if item.stars > 0 {
              Text(item.starsDisplay)
                .font(.brainyBodySmall)
            }
          }
        }
        
        // Stats row
        HStack(spacing: 16) {
          HStack(spacing: 4) {
            Image(systemName: "target")
              .font(.system(size: 12))
              .foregroundColor(.brainyTextSecondary)
            
            Text("\(item.score)/\(item.totalQuestions)")
              .font(.brainyBodyMedium)
              .foregroundColor(.brainyText)
            
            Text("(\(item.accuracyPercentage))")
              .font(.brainyBodySmall)
              .foregroundColor(.brainyTextSecondary)
          }
          
          Spacer()
          
          HStack(spacing: 4) {
            Image(systemName: "clock")
              .font(.system(size: 12))
              .foregroundColor(.brainyTextSecondary)
            
            Text(item.formattedTime)
              .font(.brainyBodySmall)
              .foregroundColor(.brainyTextSecondary)
          }
          
          // Retry button
          Button(action: {
            store.send(.retryStage(item.stageId))
          }) {
            HStack(spacing: 4) {
              Image(systemName: "arrow.clockwise")
                .font(.system(size: 12))
              Text("다시 도전")
                .font(.brainyLabelSmall)
            }
            .foregroundColor(.brainyPrimary)
          }
        }
      }
      .padding(16)
    }
  }

  private var emptyStateView: some View {
    VStack(spacing: 24) {
      Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 64))
        .foregroundColor(.brainyTextSecondary)

      VStack(spacing: 8) {
        Text(hasActiveFilters ? "조건에 맞는 기록이 없어요" : "아직 풀어본 퀴즈가 없어요")
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyText)

        Text(hasActiveFilters ? "다른 조건으로 검색해보세요" : "첫 번째 퀴즈를 시작해보세요!")
          .font(.brainyBodyLarge)
          .foregroundColor(.brainyTextSecondary)
      }

      if hasActiveFilters {
        BrainyButton("필터 초기화", style: .secondary) {
          store.send(.clearFilters)
        }
      } else {
        BrainyButton("퀴즈 시작하기", style: .primary) {
          store.send(.goToBack)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(24)
  }
  
  private func errorView(_ message: String) -> some View {
    VStack(spacing: 24) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 48))
        .foregroundColor(.brainyError)

      Text("오류가 발생했습니다")
        .font(.brainyHeadlineMedium)
        .foregroundColor(.brainyText)

      Text(message)
        .font(.brainyBodyLarge)
        .foregroundColor(.brainyTextSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      VStack(spacing: 12) {
        BrainyButton("다시 시도", style: .primary) {
          store.send(.loadHistory)
        }

        BrainyButton("뒤로 가기", style: .secondary) {
          store.send(.goToBack)
        }
      }
      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }
}
// MARK: - Filter Views
extension HistoryListPage {
  private var filterOverlayView: some View {
    ZStack {
      // Background overlay
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          store.send(.toggleFilters)
        }
      
      // Filter content
      VStack(spacing: 0) {
        Spacer()
        
        filterContentView
          .background(Color.brainyBackground)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .transition(.move(edge: .bottom))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: store.showingFilters)
  }
  
  private var filterContentView: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("필터")
          .font(.brainyHeadlineMedium)
          .foregroundColor(.brainyText)
        
        Spacer()
        
        Button(action: {
          store.send(.toggleFilters)
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.brainyTextSecondary)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 20)
      
      Divider()
        .background(Color.brainyTextSecondary.opacity(0.2))
      
      ScrollView {
        VStack(spacing: 24) {

          // Category filter
          filterSectionView(
            title: "카테고리") {
              categoryFilterView
            }
          
          // Time range filter
          filterSectionView(
            title: "기간") {
              timeRangeFilterView
            }

          // Clear status filter
          filterSectionView(
            title: "클리어 상태") {
              clearStatusFilterView
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
      }
      .frame(maxHeight: 400)
      
      // Bottom buttons
      Divider()
        .background(Color.brainyTextSecondary.opacity(0.2))
      
      HStack(spacing: 12) {
        BrainyButton("초기화", style: .ghost) {
          store.send(.clearFilters)
        }
        
        BrainyButton("적용", style: .primary) {
          store.send(.toggleFilters)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 16)
    }
  }
  
  private func filterSectionView<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.brainyBodyLarge)
        .foregroundColor(.brainyText)
      
      content()
    }
  }
  
  private var categoryFilterView: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
      // All categories option
      HistoryFilterButton(
        title: "전체",
        isSelected: store.selectedCategory == nil
      ) {
        store.send(.selectCategory(nil))
      }
      
      // Individual categories
      ForEach(QuizCategory.allCases, id: \.self) { category in
        HistoryFilterButton(
          title: category.displayName,
          isSelected: store.selectedCategory == category
        ) {
          store.send(.selectCategory(category))
        }
      }
    }
  }
  
  private var timeRangeFilterView: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
      ForEach(HistoryTimeRange.allCases, id: \.self) { timeRange in
        HistoryFilterButton(
          title: timeRange.displayName,
          isSelected: store.selectedTimeRange == timeRange
        ) {
          store.send(.selectTimeRange(timeRange))
        }
      }
    }
  }
  
  private var clearStatusFilterView: some View {
    HStack(spacing: 12) {
      HistoryFilterButton(
        title: "전체",
        isSelected: !store.showOnlyCleared
      ) {
        if store.showOnlyCleared {
          store.send(.toggleShowOnlyCleared)
        }
      }
      
      HistoryFilterButton(
        title: "클리어만",
        isSelected: store.showOnlyCleared
      ) {
        if !store.showOnlyCleared {
          store.send(.toggleShowOnlyCleared)
        }
      }
      
      Spacer()
    }
  }
}
