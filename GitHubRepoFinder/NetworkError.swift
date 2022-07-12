//
//  NetworkError.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/12/22.
//

import Foundation

enum NetworkingError: LocalizedError {
    case invalidURL
    case apiError(Error)
    case wrongRequestType(URLResponse?)
    case badURLResponse(Int)
    case noData
    case noImageData
    case dataDecodingFailure(String?)
    case noImageURL
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL is invalid"
        case .apiError(let error): return error.localizedDescription
        case .wrongRequestType(let response): return "Wrong URL request type, response is: \(String(describing: response))"
        case .badURLResponse(let statusCode): return "Failure with server response code: \(statusCode)"
        case .noData: return "Data from request is nil"
        case .noImageData: return "Image data could not be retrieved from URL"
        case .dataDecodingFailure(let description): return description == nil ? "Could not decode JSON data to data model type" : description
        case .noImageURL: return "No URL for that image"
        }
    }
}
