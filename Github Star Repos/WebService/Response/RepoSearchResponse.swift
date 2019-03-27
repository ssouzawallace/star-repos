import Foundation

struct RepoSearchResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
    
    let totalCount: Int
    let items: [Repo]
}
