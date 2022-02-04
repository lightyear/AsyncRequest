//
//  APIBase.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/4/22.
//  Copyright © 2022 Light Year Software, LLC
//

import Foundation

public enum RequestError: Error {
    case invalidURL
}

open class APIBase {
    public var baseURL: URL?
    public var method = HTTPMethod.get
    public var path = ""
    public var queryItems = [URLQueryItem]()

    public init() {
    }

    open func buildURLRequest() throws -> URLRequest {
        guard let url = buildURL() else { throw RequestError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

    private func buildURL() -> URL? {
        var components = URLComponents()
        components.path = path

        if !queryItems.isEmpty {
            var querySafe = CharacterSet.urlQueryAllowed
            querySafe.remove("+")
            components.percentEncodedQuery = queryItems.map {
                "\($0.name.addingPercentEncoding(withAllowedCharacters: querySafe)!)=\($0.value?.addingPercentEncoding(withAllowedCharacters: querySafe) ?? "")"
            }.joined(separator: "&")
        }

        return components.url(relativeTo: baseURL)
    }
}
