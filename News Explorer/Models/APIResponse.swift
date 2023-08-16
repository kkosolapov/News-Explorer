import Foundation

struct APIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
