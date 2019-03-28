import Foundation

struct RepoSearchResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
    
    let totalCount: Int
    let items: [Repo]
}

extension RepoSearchResponse: Equatable {
    static func == (lhs: RepoSearchResponse, rhs: RepoSearchResponse) -> Bool {
        return lhs.totalCount == rhs.totalCount && lhs.items == rhs.items
    }
}
