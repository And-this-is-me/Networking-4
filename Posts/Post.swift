//
//  Post.swift
//  Posts
//
//

import Foundation

public struct Post: Codable, Equatable, Identifiable {
    public let id: Int
    let body: String
    let title: String
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case body
        case title
        case userID = "userId"
    }
}
