import XCTest
@testable import News_Explorer

final class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUpWithError() throws {
        networkManager = NetworkManager()
    }

    override func tearDownWithError() throws {
        networkManager = nil
    }

    func testFetchArticles() throws {
        let expectation = XCTestExpectation(description: "Fetch articles")
        
        networkManager.fetchArticles { result in
            switch result {
            case .success:
                XCTAssertFalse(self.networkManager.articles.isEmpty, "Articles should not be empty after fetching")
            case .failure(let error):
                XCTFail("Fetching articles failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
    }
}
