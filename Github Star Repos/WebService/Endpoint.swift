import Foundation

struct Endpoint {
    enum Error: Swift.Error {
        case invalidURL
    }
    
    let path: String
    let queryItems: [URLQueryItem]
}


extension Endpoint {
    static func searchSwiftRepos(currentPage: Int, perPage: Int) -> Endpoint {
        return Endpoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "q", value: "language:swift"),
                URLQueryItem(name: "sort", value: "stars"),
                URLQueryItem(name: "page", value: currentPage.description),
                URLQueryItem(name: "per_page", value: perPage.description),
            ]
        )
    }
}

extension Endpoint {    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
