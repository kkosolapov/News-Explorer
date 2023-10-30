import SwiftUI

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
            ScrollView (.horizontal){
                HStack(){Text("**Title**: \(article.title ?? "")")
                }
            }
            
            ScrollView (.horizontal){
                HStack(){Text("**Description**: \(article.description ?? "")")
                }
            }
            
            ScrollView (.horizontal){
                HStack(){Text("**Author**: \(article.author ?? "")")}
            }
            
            ScrollView (.horizontal){
                HStack() {Text("**Source**: \(article.source.name ?? "")") }
            }
            
            ScrollView (.horizontal){
                HStack() { Text("**Published At**: \(article.publishedAt ?? "")")}
                
            }
            
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
