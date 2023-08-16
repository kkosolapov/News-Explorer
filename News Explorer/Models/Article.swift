import Foundation

struct Article: Codable, Identifiable {
    let id =  UUID ()
    let source: Source
    let author: String?
    let title: String?
    let url: String?
    let urlToImage: String?
    let description: String?
    let publishedAt: String?
    let content: String?
}
