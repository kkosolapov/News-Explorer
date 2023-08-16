import XCTest
@testable import News_Explorer

class ArticleListViewTests: XCTestCase {

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
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Fetching articles failed with error: \(error.localizedDescription)")
            }
        }
        
    }

    func testFetchArticlesInvalidURL() throws {
        let expectation = XCTestExpectation(description: "Fetch articles with invalid URL")
        
        networkManager.baseURL = "invalidURL"
        
        networkManager.fetchArticles { result in
            switch result {
            case .success:
                XCTFail("Fetching articles with invalid URL should fail")
            case .failure:
                expectation.fulfill()
            }
        }
        
    }

}
