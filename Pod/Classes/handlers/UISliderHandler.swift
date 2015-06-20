//
//  UISliderHandler.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import UIKit

class UISliderHandler : Handler, ObservableHandlerProtocol {
    
    var observerFn : ((value: AnyObject?) -> Void)?
    
    init () {
        super.init(setValue: { (value, onView) -> Void in
            if value == nil { return }
            
            let slider = onView as! UISlider
            slider.value = (value as! NSNumber).floatValue
            
        }, type: NSNumber.self)
    }
    
    func observe(view: UIView, fn: (value: AnyObject?) -> Void) {
        observerFn = fn
        (view as! UISlider).addTarget(self, action: "onValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func onValueChanged(slider:UISlider) {
        self.observerFn!(value: slider.value as NSNumber)
    }
    
    func unobserve(view: UIView) {
        (view as! UISlider).removeTarget(self, action: "onValueChanged:", forControlEvents: .ValueChanged)
        self.observerFn = nil
    }
}

