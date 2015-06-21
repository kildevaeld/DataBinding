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

@objc public protocol FADataRepresentationProtocol {
    var data: AnyObject! { get }
    func arrangeWithData(data: NSObject)
    func arrange()
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController, withData: NSObject, animated: Bool) {
        
        let vis = self.visibleViewController
        
        objc_setAssociatedObject(vis, &kDidPushKey, 1, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
        
        self.pushViewController(viewController, animated: animated)
        if let vc = viewController as? FADataRepresentationProtocol {
            vc.arrangeWithData(withData)
        }
        
        objc_setAssociatedObject(viewController, &kDidPushKey, 0, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
        
    }
}

