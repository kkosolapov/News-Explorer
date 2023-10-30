import Foundation
import Network

enum NetworkStatus: String {
    case connected
    case disconnected
}

class NetworkManager: ObservableObject {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    @Published var status: NetworkStatus = .connected
    let apiKey = "887b32d6ce7942da8fe5addcf5e81836"
    var baseURL = "https://newsapi.org/v2/everything?q=football"
    
    @Published var articles: [Article] = []
    
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.status = .connected
                    
                } else {
                    self.status = .disconnected
                }
            }
        }
        monitor.start(queue: queue)

    }
    
    func fetchArticles(completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)&apiKey=\(apiKey)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error fetching articles: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            let str = String(decoding: data, as: UTF8.self)
            print("Received data:\n\(str)")
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.articles = response.articles
                }
            } catch let DecodingError.keyNotFound(key, context) {
                print("Could not find key \(key) in JSON: \(context.debugDescription)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("Could not find value \(value) in JSON: \(context.debugDescription)")
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type mismatch \(type) in JSON: \(context.debugDescription)")
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted in JSON: \(context.debugDescription)")
            } catch let error as NSError {
                print("Error decoding articles: \(error.localizedDescription)")
            }
        }.resume()
    }
}
