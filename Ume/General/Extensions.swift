//
//  Extensions.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation
import UIKit

extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}

extension UIViewController {
    func showAlertView(_ title: String, message: String) {
        let alertC =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionA = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertC.addAction(actionA)
        present(alertC, animated: true, completion: nil)
    }
}
