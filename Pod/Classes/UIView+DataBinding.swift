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
let kDataBindingDataKey = "fa_data_binding_data"


func getDataBindingsForView(view: UIView) -> [DataBinding] {
    
    var array = [view.bind]
    
    for view in view.subviews {
        array += getDataBindingsForView(view as! UIView)
    }
    return array
 }

extension UIView {
    public var bind : DataBinding {
        var b: AnyObject? = objc_getAssociatedObject(self, &kDataBindingKey)
        if b == nil {
            b = DataBinding(view: self)
            
            objc_setAssociatedObject(self, &kDataBindingKey, b,  objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            
        }
        
        return b! as! DataBinding
    }
    
    public var data : AnyObject? {
        return self.bind.data
    }
    
    public func bindData(data: NSObject) {
        let bindings = getDataBindingsForView(self)
        
        for binding in bindings {
            binding.bindData(data)
        }
        
    }
    
    
}


