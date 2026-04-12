import Quick
import Nimble

@testable import Github_Star_Repos

class RepoModelTests: QuickSpec {

    override func spec() {

        // MARK: - RepoOwner

        describe("RepoOwner") {
            context("JSON decoding") {
                it("decodes correctly from valid JSON") {
                    let json = """
                    {
                        "login": "apple",
                        "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                    }
                    """.data(using: .utf8)!

                    let owner = try? JSONDecoder().decode(RepoOwner.self, from: json)

                    expect(owner).toNot(beNil())
                    expect(owner?.login).to(equal("apple"))
                    expect(owner?.avatarUrl.absoluteString).to(equal("https://avatars.githubusercontent.com/u/10639145"))
                }

                it("fails to decode when login is missing") {
                    let json = """
                    {
                        "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(RepoOwner.self, from: json) }.to(throwError())
                }

                it("fails to decode when avatar_url is missing") {
                    let json = """
                    {
                        "login": "apple"
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(RepoOwner.self, from: json) }.to(throwError())
                }

                it("fails to decode when avatar_url is not a valid URL") {
                    let json = """
                    {
                        "login": "apple",
                        "avatar_url": ""
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(RepoOwner.self, from: json) }.to(throwError())
                }
            }

            context("Equatable") {
                it("considers two owners with same values as equal") {
                    let owner1 = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)
                    let owner2 = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)

                    expect(owner1).to(equal(owner2))
                }

                it("considers two owners with different logins as not equal") {
                    let owner1 = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)
                    let owner2 = RepoOwner(login: "google", avatarUrl: URL(string: "https://example.com/avatar")!)

                    expect(owner1).toNot(equal(owner2))
                }

                it("considers two owners with different avatar URLs as not equal") {
                    let owner1 = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar1")!)
                    let owner2 = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar2")!)

                    expect(owner1).toNot(equal(owner2))
                }
            }
        }

        // MARK: - Repo

        describe("Repo") {
            let validRepoJSON = """
            {
                "name": "swift",
                "owner": {
                    "login": "apple",
                    "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                },
                "stargazers_count": 60000
            }
            """.data(using: .utf8)!

            context("JSON decoding") {
                it("decodes correctly from valid JSON") {
                    let repo = try? JSONDecoder().decode(Repo.self, from: validRepoJSON)

                    expect(repo).toNot(beNil())
                    expect(repo?.name).to(equal("swift"))
                    expect(repo?.owner.login).to(equal("apple"))
                    expect(repo?.stargazersCount).to(equal(60000))
                }

                it("fails to decode when name is missing") {
                    let json = """
                    {
                        "owner": {
                            "login": "apple",
                            "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                        },
                        "stargazers_count": 60000
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(Repo.self, from: json) }.to(throwError())
                }

                it("fails to decode when owner is missing") {
                    let json = """
                    {
                        "name": "swift",
                        "stargazers_count": 60000
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(Repo.self, from: json) }.to(throwError())
                }

                it("fails to decode when stargazers_count is missing") {
                    let json = """
                    {
                        "name": "swift",
                        "owner": {
                            "login": "apple",
                            "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                        }
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(Repo.self, from: json) }.to(throwError())
                }

                it("decodes stargazers_count of zero") {
                    let json = """
                    {
                        "name": "new-repo",
                        "owner": {
                            "login": "user",
                            "avatar_url": "https://example.com/avatar"
                        },
                        "stargazers_count": 0
                    }
                    """.data(using: .utf8)!

                    let repo = try? JSONDecoder().decode(Repo.self, from: json)

                    expect(repo).toNot(beNil())
                    expect(repo?.stargazersCount).to(equal(0))
                }
            }

            context("Equatable") {
                let owner = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)

                it("considers two repos with same values as equal") {
                    let repo1 = Repo(name: "swift", owner: owner, stargazersCount: 1000)
                    let repo2 = Repo(name: "swift", owner: owner, stargazersCount: 1000)

                    expect(repo1).to(equal(repo2))
                }

                it("considers two repos with different names as not equal") {
                    let repo1 = Repo(name: "swift", owner: owner, stargazersCount: 1000)
                    let repo2 = Repo(name: "kotlin", owner: owner, stargazersCount: 1000)

                    expect(repo1).toNot(equal(repo2))
                }

                it("considers two repos with different star counts as not equal") {
                    let repo1 = Repo(name: "swift", owner: owner, stargazersCount: 1000)
                    let repo2 = Repo(name: "swift", owner: owner, stargazersCount: 2000)

                    expect(repo1).toNot(equal(repo2))
                }

                it("considers two repos with different owners as not equal") {
                    let otherOwner = RepoOwner(login: "google", avatarUrl: URL(string: "https://example.com/avatar")!)
                    let repo1 = Repo(name: "swift", owner: owner, stargazersCount: 1000)
                    let repo2 = Repo(name: "swift", owner: otherOwner, stargazersCount: 1000)

                    expect(repo1).toNot(equal(repo2))
                }
            }
        }

        // MARK: - RepoSearchResponse

        describe("RepoSearchResponse") {
            context("JSON decoding") {
                it("decodes correctly from valid JSON") {
                    let json = """
                    {
                        "total_count": 2,
                        "items": [
                            {
                                "name": "swift",
                                "owner": {
                                    "login": "apple",
                                    "avatar_url": "https://example.com/apple"
                                },
                                "stargazers_count": 60000
                            },
                            {
                                "name": "Alamofire",
                                "owner": {
                                    "login": "Alamofire",
                                    "avatar_url": "https://example.com/alamofire"
                                },
                                "stargazers_count": 35000
                            }
                        ]
                    }
                    """.data(using: .utf8)!

                    let response = try? JSONDecoder().decode(RepoSearchResponse.self, from: json)

                    expect(response).toNot(beNil())
                    expect(response?.totalCount).to(equal(2))
                    expect(response?.items).to(haveCount(2))
                    expect(response?.items.first?.name).to(equal("swift"))
                    expect(response?.items.last?.name).to(equal("Alamofire"))
                }

                it("decodes response with empty items array") {
                    let json = """
                    {
                        "total_count": 0,
                        "items": []
                    }
                    """.data(using: .utf8)!

                    let response = try? JSONDecoder().decode(RepoSearchResponse.self, from: json)

                    expect(response).toNot(beNil())
                    expect(response?.totalCount).to(equal(0))
                    expect(response?.items).to(beEmpty())
                }

                it("fails to decode when total_count is missing") {
                    let json = """
                    {
                        "items": []
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(RepoSearchResponse.self, from: json) }.to(throwError())
                }

                it("fails to decode when items is missing") {
                    let json = """
                    {
                        "total_count": 0
                    }
                    """.data(using: .utf8)!

                    expect { try JSONDecoder().decode(RepoSearchResponse.self, from: json) }.to(throwError())
                }
            }

            context("Equatable") {
                let owner = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)
                let repo = Repo(name: "swift", owner: owner, stargazersCount: 1000)

                it("considers two responses with same values as equal") {
                    let response1 = RepoSearchResponse(totalCount: 1, items: [repo])
                    let response2 = RepoSearchResponse(totalCount: 1, items: [repo])

                    expect(response1).to(equal(response2))
                }

                it("considers two responses with different total counts as not equal") {
                    let response1 = RepoSearchResponse(totalCount: 1, items: [repo])
                    let response2 = RepoSearchResponse(totalCount: 2, items: [repo])

                    expect(response1).toNot(equal(response2))
                }

                it("considers two responses with different items as not equal") {
                    let otherRepo = Repo(name: "kotlin", owner: owner, stargazersCount: 500)
                    let response1 = RepoSearchResponse(totalCount: 1, items: [repo])
                    let response2 = RepoSearchResponse(totalCount: 1, items: [otherRepo])

                    expect(response1).toNot(equal(response2))
                }
            }
        }
    }
}
