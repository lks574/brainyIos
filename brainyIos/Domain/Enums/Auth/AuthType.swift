import Foundation

enum AuthType: String, CaseIterable, Codable, Sendable {
  case email = "email"
  case google = "google"
  case apple = "apple"
}
