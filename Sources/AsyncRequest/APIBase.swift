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
    case nonHTTPResponse
    case failed(APIBase.DataResponse)
    case contentTypeMismatch(APIBase.DataResponse)
}

open class APIBase {
    public struct DataResponse {
        public let data: Data
        public let response: HTTPURLResponse
    }

    public var session = URLSession(configuration: .ephemeral)
    public var request: URLRequest?
    public var baseURL: URL?
    public var method = HTTPMethod.get
    public var path = ""
    public var queryItems = [URLQueryItem]()
    public var contentType: String?
    public var body: Data?
    public var bodyStream: (stream: InputStream, count: Int)?

    public init() {
    }

    open func buildURLRequest() throws -> URLRequest {
        guard let url = buildURL() else { throw RequestError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let body = try encodeBody() {
            urlRequest.setValue(contentType, forHTTPHeaderField: "content-type")
            urlRequest.setValue("\(body.count)", forHTTPHeaderField: "content-length")
            urlRequest.httpBody = body
        } else if let body = bodyStream {
            urlRequest.setValue(contentType, forHTTPHeaderField: "content-type")
            urlRequest.setValue("\(body.count)", forHTTPHeaderField: "content-length")
            urlRequest.httpBodyStream = body.stream
        }

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

    open func encodeBody() throws -> Data? {
        body
    }

    public func sendRequest() async throws -> DataResponse {
        let request = try buildURLRequest()
        self.request = request
        return try await withCheckedThrowingContinuation { continuation in
            self.session.dataTask(with: request) { data, urlResponse, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let urlResponse = urlResponse as? HTTPURLResponse
                else {
                    continuation.resume(throwing: RequestError.nonHTTPResponse)
                    return
                }
                continuation.resume(returning: DataResponse(data: data ?? Data(), response: urlResponse))
            }
            .resume()
        }
    }
}
