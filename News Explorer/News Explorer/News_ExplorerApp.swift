import SwiftUI

@main
struct News_ExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            ArticleListView(networkManager: NetworkManager())
        }
    }
}
