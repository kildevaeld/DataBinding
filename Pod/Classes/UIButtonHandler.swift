//
//  UIButtonHandler.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation
import UIKit

class UIButtonHandler : NSObject, HandlerProtocol {
    
    
    var type: AnyObject.Type? = nil
    
    func setValue(value: AnyObject?, onView: UIView) {
        let buttonView = onView as! UIButton;
    
        
        if let str = value as? String {
            buttonView.setTitle(str, forState:.Normal)
        } else if let bool = value as? Bool {
            buttonView.selected = bool
        }
    
    }

    
    
}