# AsyncRequest

AsyncRequest is a type-safe framework for building a suite of requests to communicate with an API, built on top of Swift Concurrency.

## Install

Installation is done through Swift Package Manager. Paste the URL of this repo into Xcode or add this line to your `Package.swift`:

    .package(url: "https://github.com/lightyear/AsyncRequest", from: "0.2.0")

## Usage

There are two primary types provided by this package: `AsyncRequest` and `APIBase`.

`AsyncRequest` is a protocol that describes the essentials of an API request. It defines the HTTP method, path to the endpoint and the type of data you expect to receive. An example that fetches users from [JSONPlaceholder](https://jsonplaceholder.typicode.com) looks like this:

```
class UsersRequest: APIBase, AsyncRequest {
    override init() {
        super.init()
        path = "https://jsonplaceholder.typicode.com/users"
    }
    
    func start() async throws -> Data {
        try await super.sendRequest().data
    }
}

try await UsersRequest().start()
```

`APIBase` is a base class. It contains a `URLSession` instance, builds the `URLRequest` and starts the data task. It is intended to be subclassed and contain the logic common to all requests for a given API. Again for JSONPlaceholder, a subclass might look like:

```
class JSONPlaceholderAPI: APIBase {
    override init() {
        super.init()
        baseURL = URL(string: "https://jsonplaceholder.typicode.com")
    }
    
    override func buildURLRequest() async throws -> URLRequest {
        var urlRequest = try super.buildURLRequest()
        urlRequest?.setValue("application/json", forHTTPHeaderField: "Accept")
        return urlRequest
    }
    
    override func startRequest() async throws -> DataResponse {
        try await super.startRequest()
            .validateStatusCode(in: 200..<300)
            .hasContentType("application/json")
    }
}
```

This subclass ensures that the `Accept` header is set for every request and validates both the HTTP status code and content type of the response. Take note that only the leaf classes conform to `Request`. This is important, because Swift does not look further down an inheritence hierarchy to find the proper implementation of a property or function when checking for protocol conformance.

## Decoding JSON data

Getting a `DataResponse` struct back from a request isn't as useful as  structured data. The `UsersRequest` can be modified slightly to do this automatically:

```
struct User: Codable {
    var id: Int
    var name: String
    var username: String
    var email: String
    // etc...
}

class UsersRequest: JSONPlaceholderAPI, AsyncRequest {
    override init() {
        super.init()
        path = "/users"
    }

    func start() async throws -> [User] {
        try await super.sendRequest()
            .decode([User].self, with: JSONDecoder())
    }
}
```

The return type of `start()`  changed to reflect the decoded type and the `decode` helper is used to parse the `Data` into an an  `Array<User>`.

## Helpers

There are several useful helpers available to validate that the response data matches what you expect.

`validateStatusCode(in:)` throws an error if the response status code isn't the provided sequence. You can pass any `Sequence` of `Int` (so, `Range<Int>`, `Set<Int>`, `Array<Int>` all work).

`hasContentType(_:)` throws an error if the response content type doesn't match the passed type. This helper will match with or without a trailing charset. For example, `hasContentType("text/plain")` accepts a content type of either "text/plain" (exact match) or "text/plain; charset=utf-8".

## Testing

You can test your `Request` conformances using any library that hooks into Apple's URL loading system, such as [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs).
