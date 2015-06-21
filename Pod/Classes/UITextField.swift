//
//  UITextField.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation


class UITextFieldHandler : Handler, ObservableHandlerProtocol {
    
    var observerFn : ((value: AnyObject?) -> Void)?
    
    init () {
        super.init(type: NSString.self, setValue: { (value, onView) -> Void in
            if value == nil { return }
            
            let slider = onView as! UITextField
            slider.text = value as! String
            
            })
    }
    
    func observe(view: UIView, fn: (value: AnyObject?) -> Void) {
        
        let textfield = view as! UITextField
        
        self.observerFn = fn
        textfield.addTarget(self, action: "onValueChanged:", forControlEvents: .EditingChanged)
        
        
    }
    
    func onValueChanged (sender: UITextField) {
        observerFn!(value: sender.text)
    }
    
    func unobserve(view: UIView) {
        (view as! UIControl).removeTarget(self, action: "onValueChanged:", forControlEvents: .ValueChanged)
        self.observerFn = nil
    }
    
}