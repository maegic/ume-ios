//
//  RemoteAPI.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation

enum RemoteAPIError: Error {
    case unknown
    case createURL
    case missingURL
    case parameterEncoding
    case httpError
    case jsonSerialization
    case decodeResponseData
    case unwrap
}


/// 远程消息API协议
protocol MessageRemoteAPI {
    func fetchMessageItems(_ request: MessageItemsRequest, completion: @escaping (Result<MessageItems>) -> Void)
    func addMessage(_ request: AddMessageRequest, completion: @escaping (Result<AddResponsePayload>) -> Void)
}

/// 基于HTTP的远程消息API协议实现
class UmeMessageRemoteAPI: MessageRemoteAPI {
    let httpClient: HTTPClient
    init(httpClient: HTTPClient = UmeHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func fetchMessageItems(_ request: MessageItemsRequest, completion: @escaping (Result<MessageItems>) -> Void) {
        
        let dataHandler: (Data) -> Result<MessageItems> = { data in
            let decoder = JSONDecoder()
            var payload: QueryResponsePayload<MessageItems>
            do {
                payload = try decoder.decode(QueryResponsePayload<MessageItems>.self, from: data)
            } catch (let error)  {
                return .failure(error)
            }
            
            guard let target = payload.data else {
                return .failure(RemoteAPIError.unwrap)
            }
            return .success(target)
        }
        
        httpClient.send(request, responseDataHandler: dataHandler, completion: completion)
    }
    
    
    
    func addMessage(_ request: AddMessageRequest, completion: @escaping (Result<AddResponsePayload>) -> Void) {
        
        let dataHandler: (Data) -> Result<AddResponsePayload> = { data in
            let decoder = JSONDecoder()
            var payload: AddResponsePayload
            do {
                payload = try decoder.decode(AddResponsePayload.self, from: data)
            } catch (let error)  {
                return .failure(error)
            }
            return .success(payload)
        }
        httpClient.send(request, responseDataHandler: dataHandler, completion: completion)
    }
}
