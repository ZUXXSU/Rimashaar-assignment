import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case apiError(message: String, code: Int)
    case decodingError(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "The response from the server was invalid."
        case .noData:
            return "No data was received from the server."
        case .apiError(let message, _):
            return message
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
