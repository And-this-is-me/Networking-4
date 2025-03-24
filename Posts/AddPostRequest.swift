//
//  AddPostRequest.swift
//  Posts
//

import Foundation

public struct AddPostRequest: Encodable {
    var title: String
    var body: String
    var userID: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case userID = "userId"
    }
}
