//
//  NetworkClientType.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

public enum DataError : Error {
    case failedToMapObject
    case invalidURL
    case emptyResponse
    case noContent
    case nonZeroResponse(code: Int, desc: String?, title:String? )
    case badResponse(code: Int?, desc: String?)
    case timeout
}

extension DataError {
    public var code: Int {
        switch self {
        case .nonZeroResponse(let code, _, _):
            return code
        case .badResponse(let code, _):
            return code ?? 0
        default:
            return 0
        }
    }
    public var description: String? {
        switch self {
        case .nonZeroResponse(_, let description, _):
            return description ?? "non Zero Response"
        case .badResponse(_, let description):
            return description ?? "Bad Response"
        default:
            return nil
        }
    }
    
    public var title: String? {
        switch self {
        case .badResponse:
            return "Bad Response Error"
        case .nonZeroResponse(_, _, let title):
            return title ?? "non Zero Response"
        default:
            return nil
        }
    }
}

extension DataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nonZeroResponse(_, let description, _):
            return description ?? "non Zero Response"
        case .badResponse(_, let description):
            return description ?? "Bad Response Error"
        default:
            return nil
        }
    }
}

protocol NetworkClientType {
    var baseURL: URL? { get }
    func request<Response: ImmutableMappable>(_ request: Request) -> Single<Response>
}
