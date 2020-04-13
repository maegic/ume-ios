//
//  Repository.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation


/// 消息仓库协议
protocol MessageRepositoryType {
    
    /// 获取消息
    /// - Parameters:
    ///   - param: <#param description#>
    ///   - completion: <#completion description#>
    func fetchMessageItems(_ param: [String: Any], completion: @escaping (Result<MessageItems>) -> Void)
    
    
    /// 添加消息
    /// - Parameters:
    ///   - param: <#param description#>
    ///   - completion: <#completion description#>
    func addMessage(_ param: [String: Any], completion: @escaping (Result<AddResponsePayload>) -> Void)
}


/// 消息仓库协议的实现
class UmeMessageRepository: MessageRepositoryType {
    let remoteAPI: MessageRemoteAPI
    
    init(remoteAPI: MessageRemoteAPI = UmeMessageRemoteAPI()) {
        self.remoteAPI = remoteAPI
    }
    
    func fetchMessageItems(_ param: [String: Any], completion: @escaping (Result<MessageItems>) -> Void) {
        let req = MessageItemsRequest(parameters: param)
        remoteAPI.fetchMessageItems(req, completion: completion)
    }
    
    func addMessage(_ param: [String: Any], completion: @escaping (Result<AddResponsePayload>) -> Void) {
        let req = AddMessageRequest(parameters: param)
        remoteAPI.addMessage(req, completion: completion)
    }
}
