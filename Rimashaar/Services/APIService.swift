import Foundation

class APIService {
    private let baseURL = "https://admin-cp.rimashaar.com/api/v1/"

    private func performRequest<T: Decodable>(endpoint: String, method: String = "POST", body: (some Encodable)? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)?lang=en") else {
            print("API Request Error: Invalid URL for endpoint \(endpoint)")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            let requestBodyData = try JSONEncoder().encode(body)
            request.httpBody = requestBodyData
            print("API Request: \(method) \(url)")
            print("Request Body: \(String(data: requestBodyData, encoding: .utf8) ?? "N/A")")
        } else {
            print("API Request: \(method) \(url)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("API Response Error: Invalid HTTP Response for \(url)")
            throw APIError.invalidResponse
        }

        print("API Response Status Code: \(httpResponse.statusCode) for \(url)")
        print("API Response Data: \(String(data: data, encoding: .utf8) ?? "N/A")")

        guard (200...299).contains(httpResponse.statusCode) else {
            print("API Error: HTTP Status Code \(httpResponse.statusCode) for \(url)")
            throw APIError.invalidResponse
        }
        
        guard !data.isEmpty else {
            print("API Error: No data received for \(url)")
            throw APIError.noData
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("API Decoding Error for \(url): \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func performRequest(endpoint: String, method: String = "POST", body: [String: Any]? = nil) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)\(endpoint)?lang=en") else {
            print("API Request Error: Invalid URL for endpoint \(endpoint)")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            let requestBodyData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = requestBodyData
            print("API Request: \(method) \(url)")
            print("Request Body: \(String(data: requestBodyData ?? Data(), encoding: .utf8) ?? "N/A")")
        } else {
            print("API Request: \(method) \(url)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("API Response Error: Invalid HTTP Response for \(url)")
            throw APIError.invalidResponse
        }

        print("API Response Status Code: \(httpResponse.statusCode) for \(url)")
        print("API Response Data: \(String(data: data, encoding: .utf8) ?? "N/A")")

        guard (200...299).contains(httpResponse.statusCode) else {
            print("API Error: HTTP Status Code \(httpResponse.statusCode) for \(url)")
            throw APIError.invalidResponse
        }
        
        guard !data.isEmpty else {
            print("API Error: No data received for \(url)")
            throw APIError.noData
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return jsonResponse
            } else {
                print("API Decoding Error for \(url): Failed to parse JSON response.")
                throw APIError.decodingError(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response."]))
            }
        } catch {
            print("API Decoding Error for \(url): \(error)")
            throw APIError.decodingError(error)
        }
    }

    func registerUser(registrationData: RegistrationRequest) async throws -> RegistrationResponse {
        do {
            let response: RegistrationResponse = try await performRequest(endpoint: "register-new", body: registrationData)
            if !response.success {
                print("Registration Failed: \(response.message ?? "Unknown error")")
                throw APIError.apiError(message: response.message ?? "Registration failed.", code: response.status)
            }
            print("Registration Successful: \(response.message ?? "No message")")
            return response
        } catch {
            print("Error in registerUser: \(error)")
            throw error
        }
    }

    func verifyOtp(otp: String, userId: Int) async throws -> Bool {
        do {
            let body: [String: Any] = ["user_id": userId, "otp": otp]
            let response = try await performRequest(endpoint: "verify-code", body: body)
            
            let success = response["success"] as? Bool ?? false
            let status = response["status"] as? Int
            let message = response["message"] as? String
            
            if success && status == 200 {
                print("OTP Verification Successful.")
                return true
            } else {
                print("OTP Verification Failed: \(message ?? "Unknown error")")
                throw APIError.apiError(message: message ?? "OTP verification failed.", code: status ?? 0)
            }
        } catch {
            print("Error in verifyOtp: \(error)")
            throw error
        }
    }
}
