//
//  UIView+DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import UIKit
import ObjectiveC


var kDataBindingKey : UInt8 = 0

func getDataBindingsForView(view: UIView) -> [Binding] {
    
    var array = [view.bind]
    
    for view in view.subviews {
        array += getDataBindingsForView(view as! UIView)
    }
    return array
 }

extension UIView {
    @IBInspectable public var bind : Binding {
        var b: AnyObject? = objc_getAssociatedObject(self, &kDataBindingKey)
        if b == nil {
            b = Binding(view: self)
            
            objc_setAssociatedObject(self, &kDataBindingKey, b,  objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            
        }
        
        return b! as! Binding
    }
    
    public var data : AnyObject? {
        return self.bind.data
    }
    
    public func bindData(data: NSObject) {
        let bindings = getDataBindingsForView(self)
        
        for binding in bindings {
            binding.bindData(data)
        }
        self.didBindData(data)
    }
    
    public func didBindData(data: AnyObject?) {
        
    }
}


