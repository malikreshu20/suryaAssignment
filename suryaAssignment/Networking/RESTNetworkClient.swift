//
//  RESTNetworkClient.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RxSwift
import ObjectMapper

enum BaseUrlType :Int {
    case defaultUrl
}

struct Request {
    let method: HTTPMethod
    let path: String
    let parameters: [String: Any]
    let parametersArray: [Any]?
    var urlType: BaseUrlType = .defaultUrl

    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
        self.parameters = [:]
        self.parametersArray = nil
    }

    init(method: HTTPMethod, path: String, parameters: [String: Any]) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.parametersArray = nil
    }

    init(method: HTTPMethod, path: String, parametersArray: [Any]) {
        self.method = method
        self.path = path
        self.parameters = [:]
        self.parametersArray = parametersArray
    }
}

final class RequestBuilder {
    
    func buildRequest(baseURL: URL?, request: Request) throws -> URLRequest {
            guard let baseURL = baseURL else { throw DataError.invalidURL }
            return try buildRequestFor(baseURL: baseURL, request: request)
        }
    
        
    private func buildRequestFor(baseURL: URL, request: Request) throws -> URLRequest {
        switch request.method {
        case .get: return try buildGet(baseURL, request)
        case .delete: return try buildDelete(baseURL, request)
        case .post: return try buildPost(baseURL, request)
        case .put: return try buildPut(baseURL, request)
        default: return try builBaseRequest(baseURL, request)
        }
    }

    private func buildGet(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        urlRequest = try URLEncoding().encode(urlRequest, with: request.parameters)
        return urlRequest
    }

    private func buildDelete(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        urlRequest = try URLEncoding().encode(urlRequest, with: request.parameters)
        return urlRequest
    }

    private func buildPost(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        if let parametersArray = request.parametersArray {
            urlRequest = try self.encode(urlRequest, with: parametersArray)
        } else {
            urlRequest = try JSONEncoding().encode(urlRequest, with: request.parameters)
        }
        return urlRequest
    }

    private func buildPut(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var urlRequest = try builBaseRequest(baseURL, request)
        if let parametersArray = request.parametersArray {
            urlRequest = try self.encode(urlRequest, with: parametersArray)
        } else {
            urlRequest = try JSONEncoding().encode(urlRequest, with: request.parameters)
        }
        return urlRequest
    }

    private func builBaseRequest(_ baseURL: URL, _ request: Request) throws -> URLRequest {
        var path = request.path
        if path.isEmpty {
            path = "\(baseURL.absoluteString)"
        } else {
            switch (request.path.hasPrefix("/"), baseURL.absoluteString.hasSuffix("/")) {
            case (false,false): path = "\(baseURL.absoluteString)/\(path)"
            case (true, true): path = "\(baseURL.absoluteString)/\(path)".replacingOccurrences(of: "///", with: "/")
            default: path = "\(baseURL.absoluteString)\(path)"
            }
        }
       
        guard let concatenatedURL = URL(string: path) else {
            throw DataError.invalidURL
        }

        guard let urlRequest = try? URLRequest(url: concatenatedURL, method: request.method) else {
            throw DataError.invalidURL
        }
        return urlRequest
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parametersArray: [Any]) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parametersArray)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}

final class RESTNetworkClient : NetworkClientType {
    var baseURL : URL?
    private let dispatch : DispatchQueue
    private let sessionManager : SessionManager
    private let requestBuilder = RequestBuilder()
    var statementPDFBaseUrl:URL?

    let bag = DisposeBag()

    init() {
        self.sessionManager = SessionManager()
        self.dispatch = DispatchQueue(label: "networking", qos: .background, attributes: .concurrent)
        self.configureBaseURL()

    }

    func configureBaseURL() {
        self.baseURL = URL(string: "https://surya-interview.appspot.com")!
    }

    func request<Response: ImmutableMappable>(_ request: Request)  -> Single<Response> {
        let urlRequest: URLRequest
        do {
            urlRequest = try requestBuilder.buildRequest(baseURL: baseURL, request: request)
        } catch {
            return Single.error(error)
        }

        return Single<Response>.create { [unowned self] single in
            let request = self.sessionManager.request(urlRequest)
                .validate(statusCode: 200...500)
                .validate(contentType: ["application/json", "text/plain"])
                .responseJSON(queue: self.dispatch) { response in
                    print("Response is : \(String(describing: response.result.value))")
                    if let error = response.result.error {
                        single(.error(error))
                        return
                    }

                    if let statusCode = response.response?.statusCode {
                        if statusCode == 204 {
                            single(.error(DataError.noContent))
                        }
                    }
                    
                    guard let data = response.result.value else {
                        single(.error(DataError.emptyResponse))
                        return
                    }
                    
                    
                    do {
                        let result = try Mapper<Response>().map(JSONObject: data)
                        single(.success(result))
                    } catch {
                        single(.error(DataError.failedToMapObject))
                    }
            }

            return Disposables.create { request.cancel() }
        }
    }
    
}
