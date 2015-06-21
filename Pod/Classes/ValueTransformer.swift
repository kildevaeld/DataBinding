//
//  ValueTransformer.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 20/06/15.
//
//

import Foundation
import UIKit
import RKValueTransformers

func _transformValue(value: AnyObject, type: AnyClass ) -> AnyObject?  {
    
    var out : AnyObject?
    
    var val : AnyObject = toNextFoundation(value)!
    
    if val.dynamicType.self === type {
        return val
    }
    
    
    if let str = val as? String {
        if type === NSString.self {
            return str as NSString
        }
    }
    
    if type === NSString.self  {
        var error : NSError?
        RKValueTransformer.stringValueTransformer().transformValue(val, toValue: &out, ofClass: NSString.self, error: &error)
    
    } else if type === NSDate.self {
        if value.dynamicType === NSNumber.self {
            
        }
    } else if type === NSNumber.self {
        
        if let number = val as? NSNumber {
            out = number
        } else if let str = val as? NSString {
            RKValueTransformer.numberToStringValueTransformer().transformValue(val, toValue: &out, ofClass: NSNumber.self, error: nil)
        } else if let date = val as? NSDate {
            out = date.timeIntervalSince1970 as NSNumber
        }
        
    } else if type === NSURL.self {
        RKValueTransformer.stringValueTransformer().transformValue(val, toValue: &out, ofClass: NSURL.self, error:nil)
    }
    
    
    
    return out
}

func toNextFoundation (value: AnyObject?) -> AnyObject? {
    if let str = value as? String {
        return str as NSString
    } else if let n = value as? Int {
        return n as NSNumber
    } else if let n = value as? Float {
        return n as NSNumber
    }
    return value
}