import Foundation

struct APIService {
    let baseURL: URL

    init(baseURL: URL? = nil) {
        if let baseURL {
            self.baseURL = baseURL
        } else if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
                  let url = URL(string: configuredURL) {
            self.baseURL = url
        } else {
            self.baseURL = URL(string: "http://127.0.0.1:8000")!
        }
    }

    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        var components = URLComponents(
            url: baseURL.appending(path: request.endpoint.path),
            resolvingAgainstBaseURL: false
        )
        let queryItems = request.endpoint.queryItems
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components?.url else { throw APIServiceError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method
        urlRequest.timeoutInterval = 30
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIServiceError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw APIServiceError.server(httpResponse.statusCode)
            }
            do {
                return try JSONDecoder().decode(Request.Response.self, from: data)
            } catch {
                throw APIServiceError.decoding
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as APIServiceError {
            throw error
        } catch {
            throw APIServiceError.transport(error.localizedDescription)
        }
    }
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(Int)
    case decoding
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The API address is invalid. Check API_BASE_URL in the app configuration."
        case .invalidResponse:
            "The jobs service returned an unexpected response."
        case .server(let statusCode):
            "The jobs service returned an error (\(statusCode)). Try again in a moment."
        case .decoding:
            "The jobs service sent data the app could not read."
        case .transport(let message):
            "Could not reach the jobs service: \(message)"
        }
    }
}
