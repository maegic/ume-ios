//
//  UmeDependencyContainer.swift
//  Ume
//
//  Created by marui on 2020/4/13.
//  Copyright © 2020 pointer. All rights reserved.
//

import Foundation
import UIKit

/// Dependency Container
class  UmeDependencyContainer {
    
    func makeRootVC() -> UINavigationController {
        let mainBoard =  UIStoryboard(name: "Main", bundle: nil)
        let navVC = mainBoard.instantiateInitialViewController() as! UINavigationController
        let messageVC = navVC.viewControllers.first as! MessageViewController
        messageVC.repository = UmeMessageRepository()
        messageVC.addMessageVCFactory = addMessageVCFactory
        return navVC
    }
    
    let addMessageVCFactory: (MessageViewController) -> AddMessageViewController = { messageVC in
        let mainBoard =  UIStoryboard(name: "Main", bundle: nil)
        let addMessageVC = mainBoard.instantiateViewController(withIdentifier: "AddMessageViewController") as! AddMessageViewController
        addMessageVC.repository = UmeMessageRepository()
        addMessageVC.didSubmit = messageVC.beginRefreshing
        return addMessageVC
    }
}
