//
//  HTTPClient.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation



protocol ParameterEncoding {
    
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}


class UmeParameterEncoding: ParameterEncoding {
    
    /// 根据urlRequest的mothod对其进行encode
    /// - Parameters:
    ///   - urlRequest: <#urlRequest description#>
    ///   - parameters: <#parameters description#>
    func encode(_ urlRequest: URLRequest, with parameters: [String : Any]?) throws -> URLRequest {
        guard let parameters = parameters else { return urlRequest }
        let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET") ?? .post
        switch method {
        case .get:
            do {
                let res = try urlQueryEncode(urlRequest, with: parameters)
                return res
            } catch (let error) {
                throw error
            }
            
        default:
            do {
                let res = try jsonEncode(urlRequest, with: parameters)
                return res
            } catch (let error) {
                throw error
            }
        }
    }
    
    
    /// 编码到url
    /// - Parameters:
    ///   - urlRequest: <#urlRequest description#>
    ///   - parameters: <#parameters description#>
    private func urlQueryEncode (_ urlRequest: URLRequest, with parameters: [String : Any]) throws -> URLRequest {
        var urlRequest = urlRequest
        guard let url = urlRequest.url else {
            throw RemoteAPIError.missingURL
        }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            urlRequest.url = urlComponents.url
        }
        return urlRequest
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
    
    /// 编码到httpbody
    /// - Parameters:
    ///   - urlRequest: <#urlRequest description#>
    ///   - parameters: <#parameters description#>
    private func jsonEncode (_ urlRequest: URLRequest, with parameters: [String : Any]) throws -> URLRequest {
        var urlRequest = urlRequest
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [.fragmentsAllowed, .prettyPrinted])
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
        } catch {
            throw error
        }
        
        return urlRequest
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
