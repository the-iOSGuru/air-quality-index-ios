//
//  NetworkingManager.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/11/24.
//

import Foundation

// Error Enum
enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case overQuota
    case invalidKey
    case unknownError
    case invalidData
}

class NetworkManager {
    
    private func buildURL(lat: Double, lng: Double, token: String) -> URL? {
        var components = URLComponents(string: "\(Constants.API.baseURL):\(lat);\(lng)/")
        components?.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]
        return components?.url
    }
    
    func fetchAirQualityData(lat: Double, lng: Double, token: String) async throws -> GeoData {
        guard let url = buildURL(lat: lat, lng: lng, token: token) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(GeoData.self, from: data)
        
        if decodedData.status == "error" {
            throw mapError(from: data)
        }
        
        return decodedData
    }
    
    private func mapError(from data: Data) -> NetworkError {
        do {
            let decoder = JSONDecoder()
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            switch errorResponse.message {
            case "Over quota":
                return .overQuota
            case "Invalid key":
                return .invalidKey
            default:
                return .unknownError
            }
        } catch {
            return .decodingFailed
        }
    }
}
