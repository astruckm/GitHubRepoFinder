//
//  HttpClientHandler.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 7/14/22.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol HttpClientHandler: AnyObject {
    func handleDataTaskErrors(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, NetworkingError>
}

extension HttpClientHandler {
    func handleDataTaskErrors(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, NetworkingError> {
        if let error = error {
            return .failure(NetworkingError.apiError(error))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(NetworkingError.wrongRequestType(response))
        }
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            return .failure(NetworkingError.badURLResponse(httpResponse.statusCode))
        }
        guard let data = data, !data.isEmpty else {
            return .failure(NetworkingError.noData)
        }
        return .success(data)
    }
}
