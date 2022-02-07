//
//  HelperTests.swift
//  AsyncRequest
//
//  Created by Steve Madsen on 2/7/22.
//  Copyright © 2022 Light Year Software, LLC
//

import XCTest
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift
import AsyncRequest

class HelperTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testValidateStatusCodePasses() async {
        stub(condition: isAbsoluteURLString("/good")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        do {
            _ = try await TestRequest(path: "/good").start().validateStatusCode(in: 200..<300)
        } catch {
            fail("expected not to throw, but caught \(error)")
        }
    }

    func testValidateStatusCodeFails() async {
        stub(condition: isAbsoluteURLString("/bad")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
        }

        do {
            _ = try await TestRequest(path: "/bad").start().validateStatusCode(in: 200..<300)
            fail("expected to throw")
        } catch let error as RequestError {
            if case .failed(let dataResponse) = error {
                expect(dataResponse.data) == Data()
                expect(dataResponse.response.statusCode) == 400
            } else {
                fail("expected RequestError.failed, got \(error)")
            }
        } catch {
            fail("expected RequestError.failed, got \(error)")
        }
    }
}

fileprivate class TestRequest: APIBase, AsyncRequest {
    init(path: String) {
        super.init()
        self.path = path
    }

    func start() async throws -> DataResponse {
        try await sendRequest()
    }
}
