import SwiftUI

struct ArticleListView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var selectedSortingParameter: SortingParameter = .title
    @State private var selectedArticle: Article?
    @State private var searchQuery: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
        
    var body: some View {
        VStack {
            
            TextField("Search", text: $searchQuery)
                    .padding()
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
                    } else {
                        Text("No title")
                    }
                }
            }
            
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            
            .onAppear {
                            self.networkManager.fetchArticles { result in
                                switch result {
                                case .success:
                                    break
                                case .failure(let error):
                                    print("Error fetching articles: \(error)")
                    }
                }
            }
        }
    }

    private var sortedArticles: [Article] {
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

struct ArticleDetailView: View {
    var article: Article
    @State private var image: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = article.urlToImage, let _ = URL(string: imageUrl) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    ProgressView()
                }
            }
            Text("**Title**: \(article.title ?? "")")
            Text("**Description**: \(article.description ?? "")")
            Text("**Author**: \(article.author ?? "")")
            Text("**Source**: \(article.source.name ?? "")")
            Text("**Published At**: \(article.publishedAt ?? "")")
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageUrlString = article.urlToImage, let imageUrl = URL(string: imageUrlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }.resume()
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
