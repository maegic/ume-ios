//
//  HTTPClient.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation

/// HTTPClient协议
protocol HTTPClient {
    
    /// 发送请求
    /// - Parameters:
    ///   - request: 请求
    ///   - responseDataHandler: 提供返回Result<T>的回调方法
    ///   - completion: completion回调
    func send<T: Codable>(_ request: HTTPRequestType, responseDataHandler: @escaping (Data) -> Result<T>, completion: @escaping (Result<T>) -> Void)
}


/// 使用URLSession对HTTPClient协议的实现
class UmeHTTPClient: HTTPClient {
    let parameterEncoding: ParameterEncoding
    init(parameterEncoding: ParameterEncoding = UmeParameterEncoding()) {
        self.parameterEncoding = parameterEncoding
    }
    
    func send<T>(_ request: HTTPRequestType, responseDataHandler: @escaping (Data) -> Result<T>, completion: @escaping (Result<T>) -> Void) where T : Decodable, T : Encodable {
        let urlString = "\(request.host)\(request.path)"
        guard let url = URL(string: urlString) else {
            completion(.failure(RemoteAPIError.createURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        guard let encodedRequest = try? parameterEncoding.encode(urlRequest, with: request.parameters) else {
            completion(.failure(RemoteAPIError.parameterEncoding))
            return
        }
        urlRequest = encodedRequest
        
        // Send Data Task
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, error) in
            var responseResult: Result<T>
            if let error = error {
                responseResult = .failure(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                responseResult = .failure(RemoteAPIError.unknown)
                return
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                responseResult = .failure(RemoteAPIError.httpError)
                return
            }
            
            guard let data = data else {
                responseResult = .failure(RemoteAPIError.httpError)
                return
            }
            
            responseResult = responseDataHandler(data)
            
            DispatchQueue.main.safeAsync {
                completion(responseResult)
            }
        }.resume()
    }
}
