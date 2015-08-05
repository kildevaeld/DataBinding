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


var kDataBindingKey = "softshag.binding.bindkey"
var kDataViewIDKey = "softshag.binding.viewid"

func getDataBindingsForView(view: UIView) -> [Binding] {
    
    var array = [view.bind]
    
    for view in view.subviews {
        array += getDataBindingsForView(view as! UIView)
    }
    return array.filter { $0.prop != nil || $0.show != nil || $0.hide != nil }
 }

extension UIView {
    
    struct IdGen {
        static var current_id : Double = 0
        static let lock : NSLock = NSLock()
        static func getID (prefix: String = "view") -> String {
            let out : Double
            self.lock.lock()
            out = ++current_id
            self.lock.unlock()
            return "\(prefix)\(out)"
        }
    }
    
    
    public var bind : Binding {
        var b: AnyObject? = objc_getAssociatedObject(self, &kDataBindingKey)
        if b == nil {
            b = Binding(view: self)
            
            objc_setAssociatedObject(self, &kDataBindingKey, b,  objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            
        }
        
        return b! as! Binding
    }
    
    public var viewID : String? {
        get {
            var b: AnyObject? = objc_getAssociatedObject(self, &kDataViewIDKey)
            if b == nil {
                b = IdGen.getID()
                objc_setAssociatedObject(self, &kDataViewIDKey, b, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
            }
            return b as? String
        }
        set (id) {
            objc_setAssociatedObject(self, &kDataViewIDKey, id, objc_AssociationPolicy(OBJC_ASSOCIATION_COPY_NONATOMIC))
        }
    }
    
    public var data : AnyObject? {
        return self.bind.data
    }
    
    
    public func bindData(data: NSObject) {
        let bindings = getDataBindingsForView(self)
        
        let bData = self.willBindData(data)
        
        for binding in bindings {
            binding.bindData(bData)
        }
        self.didBindData(bData)
    }
    
    public func unbindData() {
        let bindings = getDataBindingsForView(self)
        
        
        for binding in bindings {
            binding.unbindData()
        }

    }
    
    public func didBindData(data: NSObject) {
        
    }
    
    public func willBindData(data: NSObject) -> NSObject {
        return data
    }
}


