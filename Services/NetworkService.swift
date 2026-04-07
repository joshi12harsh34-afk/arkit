import Foundation
import Combine

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL configuration is invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from the server."
        case .serverError(let statusCode):
            return "Server responded with an error (Status code: \(statusCode))."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    // Environment config
    private let baseURL = "https://api.example.com" // Replace with actual backend endpoint
    lazy private var shipInURL = URL(string: "\(baseURL)/shipin")
    
    private init() {}
    
    /// Generic POST Request Handler
    func post<T: Encodable, U: Decodable>(url: URL?, body: T, responseType: U.Type) -> AnyPublisher<U, NetworkError> {
        guard let url = url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        do {
            let encodedBody = try JSONEncoder().encode(body)
            request.httpBody = encodedBody
        } catch {
            return Fail(error: NetworkError.requestFailed(error)).eraseToAnyPublisher()
        }
        
        return executeRequest(request, responseType: responseType)
    }
    
    /// Generic GET Request Handler
    func get<U: Decodable>(url: URL?, responseType: U.Type) -> AnyPublisher<U, NetworkError> {
        guard let url = url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        return executeRequest(request, responseType: responseType)
    }
    
    /// Shared execution logic for requests
    private func executeRequest<U: Decodable>(_ request: URLRequest, responseType: U.Type) -> AnyPublisher<U, NetworkError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { output -> AnyPublisher<Data, NetworkError> in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.serverError(statusCode: httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(output.data)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .decode(type: U.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError { return networkError }
                return NetworkError.decodingError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - App Specific Endpoints
    
    struct ShipInResponse: Codable {
        let success: Bool
        let message: String?
    }
    
    /// Submitting Package Data (POST /shipin)
    func submitPackage(_ package: Package) -> AnyPublisher<ShipInResponse, NetworkError> {
        return post(url: shipInURL, body: package, responseType: ShipInResponse.self)
    }
    
    /// Fetching Packages (GET /shipin)
    func fetchPackages() -> AnyPublisher<[Package], NetworkError> {
        return get(url: shipInURL, responseType: [Package].self)
    }
}
