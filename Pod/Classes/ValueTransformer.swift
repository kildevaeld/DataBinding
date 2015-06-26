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
import MTDates

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
        
        if let date = val as? NSDate {
            out = date.description
        }
        
        RKValueTransformer.stringValueTransformer().transformValue(val, toValue: &out, ofClass: NSString.self, error: &error)
    
    } else if type === NSDate.self {
        
        if let date = val as? NSDate {
            out = date
        }
        
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
    } else if type === NSAttributedString.self {
        if let attr = val as? NSAttributedString {
            out = attr
        } else if let str = val as? NSString {
            out = NSAttributedString(string: str as String)
        }
    }
    
    
    
    return out
}

func Type(type: String, format: String) -> Bool {
    var regex: NSRegularExpression?
    var error: NSError?;
    
    regex = NSRegularExpression(pattern: type, options: nil, error: &error)
    
    if regex != nil {
        return regex!.numberOfMatchesInString(format, options: nil, range: NSMakeRange(0, (format as NSString).length)) > 0
    }
    
    return false
}

func _formatValue(obj: AnyObject, format: String) -> AnyObject {
    if let str = obj as? String {
        return NSString(format: format, str)
    } else if let date = obj as? NSDate {
        return date.mt_stringFromDateWithFormat(format, localized: true)
    } else if let number = obj as? NSNumber {
        
    } else if let array = obj as? NSArray  {
        
        /*func _format (valist:CVaListPointer) -> String {
            return NSString(format:format, arguments: valist) as String
        }
        let args: [CVarArgType] = array.map {
            return $0!
        }
        let s = withVaList(args: args , f:_format)
        return s*/
        
    }
    
    
    
    DataBinding.log.warning("cannot not format obj with format \(format)")
    return obj
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