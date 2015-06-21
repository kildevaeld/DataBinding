//
//  UIViewController+DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import UIKit
import JRSwizzle

extension UIViewController {
    public var didPush: Bool {
        let p: AnyObject! = objc_getAssociatedObject(self, &kDidPushKey);
        
        if p == nil {
            return false
        }
        let i = p as! Int
        
        return i == 1 ? true : false
    }
    
    public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() ->Void)?, withData:AnyObject? ) {
        
        self.presentViewController(viewControllerToPresent, animated: flag) { () -> Void in
            
            if let vc = viewControllerToPresent as? FADataRepresentationProtocol {
                vc.arrangeWithData(withData as! NSObject)
            }
            
        }
    }
    
    func swizzled_presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        objc_setAssociatedObject(self, &kDidPushKey, 1, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC));
        
        self.swizzled_presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        //objc_setAssociatedObject(self, "fa_data_representation_push", 0, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC));
    }
    
    static func swizzle () {
        self.jr_swizzleMethod("presentViewController:animated:completion:", withMethod: "swizzled_presentViewController:animated:completion:", error: nil)
    }
}