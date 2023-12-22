import SwiftUI

struct ArticleDetailView: View {
    var article: Article
    @State private var image: UIImage? = nil
    
    var body: some View {
        VStack(alignment: .center) {
            
            VStack {
                if let imageUrl = article.urlToImage, let result_image = URL(string: imageUrl) {
                    AsyncImage(url: result_image) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Text("Failed to load image")
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                } else {
                    Text("No image available")
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
        
    }
    
}
