//
//  AsyncRequest.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/4/22.
//  Copyright © 2022 Light Year Software, LLC
//

import Foundation

public enum HTTPMethod: String {
    case get, post, put, patch, delete
}

public protocol AsyncRequest {
    associatedtype ModelType

    var method: HTTPMethod { get }
    var path: String { get }

    func start() async throws -> ModelType
}

extension AsyncRequest {
    var method: HTTPMethod { .get }
}
