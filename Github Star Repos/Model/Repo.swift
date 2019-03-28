import Foundation

struct Repo: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case owner
        case stargazersCount = "stargazers_count"
    }
    let name: String
    let owner: RepoOwner
    let stargazersCount: Int
}

struct RepoOwner: Codable {
    private enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
    let login: String
    let avatarUrl: URL
}

extension Repo: Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.name == rhs.name && lhs.owner == rhs.owner && lhs.stargazersCount == rhs.stargazersCount
    }
}

extension RepoOwner: Equatable {
    static func == (lhs: RepoOwner, rhs: RepoOwner) -> Bool {
        return lhs.login == rhs.login && lhs.avatarUrl.absoluteString == rhs.avatarUrl.absoluteString
    }
}
