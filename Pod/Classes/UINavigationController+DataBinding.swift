//
//  UINavigationController+DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import UIKit

var kDidPushKey : UInt8 = 1


extension UINavigationController {
    func pushViewController(viewController: UIViewController, data: AnyObject?, animated: Bool) {
        
        objc_setAssociatedObject(self, &kDidPushKey, 1, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
        
        self.pushViewController(viewController, animated: animated)
        
        
    }
}

