//
//  ApiClient.swift
//  Posts
//
//

import SwiftUI

// Error definition
enum ApiClientError: Error {
    case undefined(message: String)
    case mappingError(requestID: UUID)
    case httpFailed(statusCode: Int, requestID: UUID)
}

// Actor declaration
actor ApiClient {
    
    // Initialization
    init(
        requestPosts: @Sendable @escaping (FetchPostsRequest) async throws -> [Post],
        addPost: @Sendable @escaping (AddPostRequest) async throws -> Post,
        updatePost: @Sendable @escaping (UpdatePostRequest) async throws -> Post,
        patchPost: @Sendable @escaping (PatchPostRequest) async throws -> Post,
        removePost: @Sendable @escaping (RemovePostRequest) async throws -> Void
    ) {
        self.requestPosts = requestPosts
        self.addPost = addPost
        self.updatePost = updatePost
        self.patchPost = patchPost
        self.removePost = removePost
    }
    
    public var requestPosts: @Sendable (FetchPostsRequest) async throws -> [Post]
    public var addPost: @Sendable (AddPostRequest) async throws -> Post
    public var updatePost: @Sendable (UpdatePostRequest) async throws -> Post
    public var patchPost: @Sendable (PatchPostRequest) async throws -> Post
    public var removePost: @Sendable (RemovePostRequest) async throws -> Void
    
    
    // Generic method to parse requests with a response
    static func handle <Success: Decodable>(
        baseURL: URL,
        urlSession: URLSession,
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        requestID: UUID,
        requester: URLRequester
    ) async throws -> Success {
        let request = try requester.urlRequest(
            baseURL: baseURL,
            encoder: encoder
        )
        
        let element: (data: Data, urlResponse: URLResponse) = try await urlSession.data(for: request)
        
        if let response = element.urlResponse as? HTTPURLResponse, response.statusCode != 200 {
            throw ApiClientError.httpFailed(
                statusCode: response.statusCode,
                requestID: requestID
            )
        }
        
        do {
            let response = try decoder.decode(Success.self, from: element.data)
            return response
        } catch {
            throw ApiClientError.mappingError(requestID: requestID)
        }
    }
    
    // Generic method for handling request that don't return responses
    static func handleVoid(
        baseURL: URL,
        urlSession: URLSession,
        encoder: JSONEncoder,
        requestID: UUID,
        requester: URLRequester
    ) async throws {
        
        let request = try requester.urlRequest(
            baseURL: baseURL,
            encoder: encoder
        )
        
        let element: (data: Data, urlResponse: URLResponse) = try await urlSession.data(for: request)
        
        if let response = element.urlResponse as? HTTPURLResponse, response.statusCode != 200 {
            throw ApiClientError.httpFailed(
                statusCode: response.statusCode,
                requestID: requestID
            )
        }
        
        // No decoding necessary as the response has no content
    }
    
    static func live(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = .init(),
        jsonEncoder: JSONEncoder = .init(),
        buildUUID: @escaping () -> UUID = { UUID() }
    ) -> Self {
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return .init(
            requestPosts: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            },
            addPost: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            },
            updatePost: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            },
            patchPost: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            },
            removePost: {
                try await handleVoid(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            }
        )
    }
}
