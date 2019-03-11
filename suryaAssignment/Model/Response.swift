//
//  Response.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ListResponse:Codable {
    let users:[Users]?
}

extension ListResponse : ImmutableMappable {
    public init(map: Map) throws {
        users = try? map.value("items")
    }
}
