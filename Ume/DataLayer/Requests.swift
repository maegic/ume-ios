//
//  Requests.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation

public protocol HTTPRequestType {
    /// 服务器地址
    var host: String { get }
    /// 请求路径
    var path: String { get }
    /// HTTP Method
    var method: HTTPMethod { get }
    /// 请求参数
    var parameters: [String: Any]? { get }
}


/// HTTP Method
public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
}


public protocol MessageHTTPRequestType: HTTPRequestType {
    
}

/// host path 的默认实现
extension MessageHTTPRequestType {
    var host: String {
        return "https://3evjrl4n5d.execute-api.us-west-1.amazonaws.com"
    }
    
    var path: String {
          return "/dev/message"
    }
}


/// 获取Message请求
struct MessageItemsRequest: MessageHTTPRequestType {
    var parameters: [String : Any]?
    var method: HTTPMethod {
        return .get
    }
}


/// 添加Message请求
struct AddMessageRequest: MessageHTTPRequestType {
    var parameters: [String : Any]?
    var method: HTTPMethod {
        return .post
    }
}





