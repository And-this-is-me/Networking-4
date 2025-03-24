//
//  AddPostRequest.swift
//  Posts
//

import Foundation

public struct UpdatePostRequest: Encodable {
    var id: Int
    var title: String
    var body: String
    var userID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case userID = "userId"
    }
}
