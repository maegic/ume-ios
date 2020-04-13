//
//  Models.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation
import UIKit


/// Message列表模型
public class MessageItems: Codable {
    public var count: Int?
    public var items: [MessageItem]?
    public var lastItem: MessageItem?
}


/// Message模型
public class MessageItem: Codable {
    
    public var `id`: String?
    public var content: String?
    public var state: Int?
    public var type: Int?
    public var creationTime: Int = 0
   

}

extension MessageItem: Comparable {
    
    public static func < (lhs: MessageItem, rhs: MessageItem) -> Bool {
        
        return lhs.creationTime > rhs.creationTime
        
    }
    
    public static func > (lhs: MessageItem, rhs: MessageItem) -> Bool {
        return lhs.creationTime > rhs.creationTime
    }
    
    public static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
        return lhs.creationTime == rhs.creationTime && lhs.content == rhs.content
    }
}

/// 添加Message返回数据模型
public class AddResponsePayload: Codable {
    public var creationTime: Int?
}


/// 查询Message返回数据模型
public class QueryResponsePayload<T: Codable>: Codable {
    public var data: T?
}

