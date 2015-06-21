//
//  UIViewController+DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import UIKit


extension UIViewController {
    public var didPush: Bool {
        let p = objc_getAssociatedObject(self, &kDidPushKey) as! Int;
        return p == 1 ? true : false
    }
}