import FBSnapshotTestCase
import OHHTTPStubs

@testable import Github_Star_Repos

class Github_Star_ReposSnapshotTest: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
//        recordMode = true
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }
    
    func testPopulatedList() {
        stub(condition: isHost("api.github.com")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("mock_response.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        let viewController = RepoListViewController()
        
        sleep(3)
        
        FBSnapshotVerifyView(viewController.view)
    }

    func testErrorList() {
        stub(condition: isHost("api.github.com")) { request in
            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
                .responseTime(OHHTTPStubsDownloadSpeed3G)
        }
        
        let viewController = RepoListViewController()
        
        sleep(3)
        
        FBSnapshotVerifyView(viewController.view)
    }
}
