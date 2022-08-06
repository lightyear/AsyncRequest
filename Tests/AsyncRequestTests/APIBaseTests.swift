//
//  APIBaseTests.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/4/22.
//  Copyright © 2022 Light Year Software, LLC
//

import XCTest
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import AsyncRequest

@MainActor
class APIBaseTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testBuildURLRequestMethod() async throws {
        var request = try await TestRequest().buildURLRequest()
        expect(request.httpMethod)  == "GET"
        request = try await TestRequest(method: .post).buildURLRequest()
        expect(request.httpMethod) == "POST"
    }

    func testBuildURLRequestURL() async throws {
        let request = TestRequest()
        request.baseURL = URL(string: "http://test")
        var url = try await request.buildURLRequest().url?.absoluteString
        expect(url) == "http://test/"
        request.path = "/foo"
        url = try await request.buildURLRequest().url?.absoluteString
        expect(url) == "http://test/foo"
    }

    func testBuildURLRequestQueryString() async throws {
        let request = TestRequest()
        request.queryItems = [URLQueryItem(name: "foo", value: "bar")]
        var url = try await request.buildURLRequest().url?.absoluteString
        expect(url) == "/?foo=bar"

        request.queryItems = [URLQueryItem(name: "foo", value: "bar baz")]
        url = try await request.buildURLRequest().url?.absoluteString
        expect(url) == "/?foo=bar%20baz"

        request.queryItems = [URLQueryItem(name: "foo", value: "bar+baz")]
        url = try await request.buildURLRequest().url?.absoluteString
        expect(url) == "/?foo=bar%2Bbaz"
    }

    func testBuildURLRequestBody() async throws {
        let request = TestRequest()
        request.contentType = "text/plain"
        request.body = Data("hello world".utf8)
        let urlRequest = try await request.buildURLRequest()
        expect(urlRequest.value(forHTTPHeaderField: "content-type")) == "text/plain"
        expect(urlRequest.httpBody) == Data("hello world".utf8)
        expect(urlRequest.value(forHTTPHeaderField: "content-length")) == "11"
    }

    func testBuildURLRequestBodyStream() async throws {
        let request = TestRequest()
        request.contentType = "text/plain"
        request.bodyStream = (stream: InputStream(data: Data("hello world".utf8)), count: 11)
        let urlRequest = try await request.buildURLRequest()
        expect(urlRequest.value(forHTTPHeaderField: "content-type")) == "text/plain"
        expect(urlRequest.value(forHTTPHeaderField: "content-length")) == "11"

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 11)
        defer { buffer.deallocate() }
        urlRequest.httpBodyStream?.open()
        let count = urlRequest.httpBodyStream?.read(buffer, maxLength: 11)
        let data = Data(bytes: buffer, count: count ?? 0)
        expect(data) == Data("hello world".utf8)
    }

    func testStartSuccess() async throws {
        stub(condition: isAbsoluteURLString("/")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        try await TestRequest().start()
    }

    func testStartNetworkError() async throws {
        stub(condition: isAbsoluteURLString("/")) { _ in
            HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil))
        }

        do {
            try await TestRequest().start()
            fail("expected to throw")
        } catch let error as NSError {
            expect(error.domain) == NSURLErrorDomain
            expect(error.code) == NSURLErrorNotConnectedToInternet
        }
    }
}

fileprivate class TestRequest: APIBase, AsyncRequest {
    init(method: HTTPMethod = .get) {
        super.init()
        self.method = method
        path = "/"
    }

    func start() async throws {
        _ = try await sendRequest()
    }
}
