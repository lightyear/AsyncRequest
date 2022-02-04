//
//  APIBaseTests.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/4/22.
//  Copyright © 2022 Light Year Software, LLC
//

import XCTest
import Nimble
import AsyncRequest

class APIBaseTests: XCTestCase {
    func testBuildURLRequestMethod() throws {
        expect(try TestRequest().buildURLRequest().httpMethod) == "GET"
        expect(try TestRequest(method: .post).buildURLRequest().httpMethod) == "POST"
    }

    func testBuildURLRequestURL() throws {
        let request = TestRequest()
        request.baseURL = URL(string: "http://test")
        expect(try request.buildURLRequest().url?.absoluteString) == "http://test/"
        request.path = "/foo"
        expect(try request.buildURLRequest().url?.absoluteString) == "http://test/foo"
    }

    func testBuildURLRequestQueryString() throws {
        let request = TestRequest()
        request.queryItems = [URLQueryItem(name: "foo", value: "bar")]
        expect(try request.buildURLRequest().url?.absoluteString) == "/?foo=bar"

        request.queryItems = [URLQueryItem(name: "foo", value: "bar baz")]
        expect(try request.buildURLRequest().url?.absoluteString) == "/?foo=bar%20baz"

        request.queryItems = [URLQueryItem(name: "foo", value: "bar+baz")]
        expect(try request.buildURLRequest().url?.absoluteString) == "/?foo=bar%2Bbaz"
    }

    func testBuildURLRequestBody() throws {
        let request = TestRequest()
        request.contentType = "text/plain"
        request.body = Data("hello world".utf8)
        let urlRequest = try request.buildURLRequest()
        expect(urlRequest.value(forHTTPHeaderField: "content-type")) == "text/plain"
        expect(urlRequest.httpBody) == Data("hello world".utf8)
        expect(urlRequest.value(forHTTPHeaderField: "content-length")) == "11"
    }

    func testBuildURLRequestBodyStream() throws {
        let request = TestRequest()
        request.contentType = "text/plain"
        request.bodyStream = (stream: InputStream(data: Data("hello world".utf8)), count: 11)
        let urlRequest = try request.buildURLRequest()
        expect(urlRequest.value(forHTTPHeaderField: "content-type")) == "text/plain"
        expect(urlRequest.value(forHTTPHeaderField: "content-length")) == "11"

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 11)
        defer { buffer.deallocate() }
        urlRequest.httpBodyStream?.open()
        let count = urlRequest.httpBodyStream?.read(buffer, maxLength: 11)
        let data = Data(bytes: buffer, count: count ?? 0)
        expect(data) == Data("hello world".utf8)
    }
}

class TestRequest: APIBase, AsyncRequest {
    init(method: HTTPMethod = .get) {
        super.init()
        self.method = method
        path = "/"
    }

    func start() async throws {
        
    }
}
