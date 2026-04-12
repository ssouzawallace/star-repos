import Quick
import Nimble

@testable import Github_Star_Repos

class EndpointTests: QuickSpec {

    override func spec() {

        describe("Endpoint") {

            describe("searchSwiftRepos") {
                it("creates endpoint with correct path") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.path).to(equal("/search/repositories"))
                }

                it("includes language query parameter for Swift") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    let languageItem = endpoint.queryItems.first(where: { $0.name == "q" })
                    expect(languageItem?.value).to(equal("language:swift"))
                }

                it("includes sort by stars query parameter") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    let sortItem = endpoint.queryItems.first(where: { $0.name == "sort" })
                    expect(sortItem?.value).to(equal("stars"))
                }

                it("includes correct page query parameter") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 3, perPage: 20)

                    let pageItem = endpoint.queryItems.first(where: { $0.name == "page" })
                    expect(pageItem?.value).to(equal("3"))
                }

                it("includes correct per_page query parameter") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 50)

                    let perPageItem = endpoint.queryItems.first(where: { $0.name == "per_page" })
                    expect(perPageItem?.value).to(equal("50"))
                }

                it("has exactly four query items") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.queryItems).to(haveCount(4))
                }
            }

            describe("url") {
                it("constructs URL with https scheme") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.url?.scheme).to(equal("https"))
                }

                it("constructs URL with api.github.com host") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.url?.host).to(equal("api.github.com"))
                }

                it("constructs URL with correct path") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.url?.path).to(equal("/search/repositories"))
                }

                it("constructs a non-nil URL for valid endpoints") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 1, perPage: 20)

                    expect(endpoint.url).toNot(beNil())
                }

                it("constructs URL with all query parameters") {
                    let endpoint = Endpoint.searchSwiftRepos(currentPage: 2, perPage: 30)
                    let urlString = endpoint.url?.absoluteString ?? ""

                    expect(urlString).to(contain("q=language%3Aswift"))
                    expect(urlString).to(contain("sort=stars"))
                    expect(urlString).to(contain("page=2"))
                    expect(urlString).to(contain("per_page=30"))
                }

                it("constructs URL for custom endpoint") {
                    let endpoint = Endpoint(path: "/users", queryItems: [
                        URLQueryItem(name: "since", value: "100")
                    ])

                    expect(endpoint.url?.scheme).to(equal("https"))
                    expect(endpoint.url?.host).to(equal("api.github.com"))
                    expect(endpoint.url?.path).to(equal("/users"))
                }
            }
        }
    }
}
