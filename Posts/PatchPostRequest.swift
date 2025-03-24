//
//  AddPostRequest.swift
//  Posts
//

import Foundation

public struct PatchPostRequest: Encodable {
    var id: Int
    var title: String?
    var body: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
    }
}
