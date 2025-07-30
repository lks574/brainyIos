import ComposableArchitecture
import SwiftUI

struct HistoryListPage: View {
  @Bindable var store: StoreOf<HistoryListReducer>
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 0) {
      headerView

      if store.isLoading {
        loadingView
      }

      Spacer()
    }
    .background(Color.brainyBackground)
    .navigationBarHidden(true)
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
          store.showingFilters = true
        }) {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .font(.title2)
            .foregroundColor(.brainyText)
        }
      }

      //      // Statistics Summary
      //      if !viewModel.quizSessions.isEmpty {
      //        statisticsSummaryView
      //      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 16)
    .padding(.bottom, 8)
  }

  private var statisticsSummaryView: some View {
    HStack(spacing: 16) {
      HistoryStatisticCard(
        title: "총 퀴즈",
        value: "\(store.totalQuizzes)개",
        icon: "doc.text"
      )

      HistoryStatisticCard(
        title: "평균 점수",
        value: String(format: "%.1f%%", store.averageScore * 100),
        icon: "chart.line.uptrend.xyaxis"
      )

      HistoryStatisticCard(
        title: "총 시간",
        value: formatTotalTime(store.totalTimeSpent),
        icon: "clock"
      )
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

  private var emptyStateView: some View {
    VStack(spacing: 24) {
      Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 64))
        .foregroundColor(.brainyTextSecondary)

      VStack(spacing: 8) {
        Text("아직 풀어본 퀴즈가 없어요")
          .font(.brainyHeadline)
          .foregroundColor(.brainyText)

        Text("첫 번째 퀴즈를 시작해보세요!")
          .font(.brainyBody)
          .foregroundColor(.brainyTextSecondary)
      }

      BrainyButton("퀴즈 시작하기", style: .primary) {
        store.send(.goToBack)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(24)
  }


}
