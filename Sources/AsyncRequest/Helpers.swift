//
//  Helpers.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/7/22.
//  Copyright © 2022 Light Year Software, LLC
//

import Foundation

extension APIBase.DataResponse {
    public func validateStatusCode<Codes: Sequence>(in successCodes: Codes) throws -> APIBase.DataResponse where Codes.Element == Int {
        guard successCodes.contains(self.response.statusCode) else { throw RequestError.failed(self) }
        return self
    }

    public func hasContentType(_ expectedType: String) throws -> APIBase.DataResponse {
        guard !data.isEmpty else { return self }
        if let contentType = response.value(forHTTPHeaderField: "Content-Type") {
            if contentType == expectedType || contentType.hasPrefix("\(expectedType); charset=") {
                return self
            }
        }
        throw RequestError.contentTypeMismatch(self)
    }
}
