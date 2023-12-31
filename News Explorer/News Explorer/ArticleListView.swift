import SwiftUI
import Network

struct ArticleListView: View {
    
    @StateObject var networkManager: NetworkManager
    
    @State private var isLoadingInfo = true
    
    @State private var selectedSortingParameter: SortingParameter = .title
    @State private var selectedArticle: Article?
    @State private var searchQuery: String = ""
    @State private var noInternetConnection: String = "No network connection"
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @StateObject private var monitor = NetworkManager()
    
    @State private var showNetworkAlert = false
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        
        if (monitor.status.rawValue == "disconnected") {
            NoInternetView()
        }
        
        else {
            
            VStack {
                
                if isLoadingInfo {
                    
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
                    
                }
                
                else {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .padding(.horizontal)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                    
                    TextField("Search", text: $searchQuery)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    DatePicker("Start Date", selection: $startDate)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                    
                    DatePicker("End Date", selection: $endDate)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                    
                    Picker("Sort By", selection: $selectedSortingParameter) {
                        ForEach(SortingParameter.allCases, id: \.self) { parameter in
                            Text(parameter.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                }
                
                List(sortedArticles, id: \.title) { article in
                    Button(action: {
                        selectedArticle = article
                    }) {
                        if let title = article.title, let description = article.description {
                            VStack(alignment: .leading) {
                                Text("**Title**: \(title)")
                                Text("**Description**: \(description)")
                            }
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal, 4)
                        }
                        
                    }
                }
                
                .alert(isPresented: .constant(!searchQuery.isEmpty && sortedArticles.filter {
                    let titleMatch = $0.title?.localizedCaseInsensitiveContains(searchQuery) ?? false
                    let descriptionMatch = $0.description?.localizedCaseInsensitiveContains(searchQuery) ?? false
                    return titleMatch || descriptionMatch
                }.isEmpty)) {
                    Alert(
                        title: Text("No Articles Found"),
                        message: Text("No articles match your search criteria."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                .sheet(item: $selectedArticle) { article in
                    ArticleDetailView(article: article)
                }
                
                .onAppear {
                    
                    loadData()
                    self.networkManager.fetchArticles { result in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            print("Error fetching articles: \(error)")
                        }
                    }
                    
                }
                
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
            }
            
        }
    }
    
    private func loadData() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoadingInfo = false
        }
    }
    
    var sortedArticles: [Article] {
        let filteredArticles: [Article]
        if searchQuery.isEmpty {
            filteredArticles = networkManager.articles
        } else {
            filteredArticles = networkManager.articles.filter { article in
                let titleMatch = article.title?.localizedCaseInsensitiveContains(searchQuery) ?? false
                let descriptionMatch = article.description?.localizedCaseInsensitiveContains(searchQuery) ?? false
                return titleMatch || descriptionMatch
            }
        }
        
        let filteredAndSortedArticles: [Article]
        if startDate <= endDate {
            filteredAndSortedArticles = filteredArticles.filter { article in
                if let publishedAtString = article.publishedAt {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let publishedAtDate = dateFormatter.date(from: publishedAtString) {
                        return publishedAtDate >= startDate && publishedAtDate <= endDate
                    }
                }
                return false
            }
        } else {
            filteredAndSortedArticles = []
        }
        
        switch selectedSortingParameter {
        case .title:
            return filteredAndSortedArticles.sorted { $0.title ?? "" < $1.title ?? "" }
        case .author:
            return filteredAndSortedArticles.sorted { $0.author ?? "" < $1.author ?? "" }
        case .publishedAt:
            return filteredAndSortedArticles.sorted { $0.publishedAt ?? "" < $1.publishedAt ?? "" }
        }
        
    }
}

enum SortingParameter: String, CaseIterable {
    case title = "Title"
    case author = "Author"
    case publishedAt = "Published At"
}

struct ArticleListView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleListView(networkManager: NetworkManager())
    }
}


extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
