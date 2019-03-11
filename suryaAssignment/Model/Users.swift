//
//  Users.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Users :Codable {
    let emailId:String?
    let lastName:String?
    let imageUrl:String?
    let firstName:String?

}

extension Users : ImmutableMappable {
    public init(map: Map) throws {
        emailId = try? map.value("emailId")
        lastName = try? map.value("lastName")
        imageUrl = try? map.value("imageUrl")
        firstName = try? map.value("firstName")
    }
}
