import SwiftUI

struct CategorySelectionCategoryCard: View {
  let category: QuizCategory
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 12) {
        Text(categoryIcon)
          .font(.system(size: 32))
        
        Text(category.rawValue)
          .font(.brainyBodyLarge)
          .foregroundColor(titleColor)
          .multilineTextAlignment(.center)
        
        Text(categoryDescription)
          .font(.brainyBodySmall)
          .foregroundColor(.brainyTextSecondary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 120)
      .padding(16)
      .background(backgroundColor)
      .cornerRadius(16)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(borderColor, lineWidth: borderWidth)
      )
      .scaleEffect(isSelected ? 1.05 : 1.0)
      .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private var categoryIcon: String {
    switch category {
    case .person:
      return "👤"
    case .general:
      return "🧠"
    case .country:
      return "🌍"
    case .drama:
      return "🎭"
    case .music:
      return "🎵"
    }
  }
  
  private var categoryDescription: String {
    switch category {
    case .person:
      return "유명인물에 대한 퀴즈"
    case .general:
      return "일반상식 퀴즈"
    case .country:
      return "세계 각국에 대한 퀴즈"
    case .drama:
      return "드라마와 영화 퀴즈"
    case .music:
      return "음악과 가수 퀴즈"
    }
  }
  
  private var titleColor: Color {
    isSelected ? .brainyPrimary : .brainyText
  }
  
  private var backgroundColor: Color {
    isSelected ? Color.brainyPrimary.opacity(0.05) : .brainyCardBackground
  }
  
  private var borderColor: Color {
    isSelected ? .brainyPrimary : Color.brainySecondary.opacity(0.2)
  }
  
  private var borderWidth: CGFloat {
    isSelected ? 2.0 : 1.0
  }
}
