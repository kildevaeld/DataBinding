//
//  repository.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import UIKit

@objc public protocol HandlerProtocol {
    var type : AnyObject.Type? { get }
    func setValue(value: AnyObject?, onView: UIView)
    
}

@objc public protocol ObservableHandlerProtocol {
    func observe(view: UIView, fn: (value: AnyObject?) -> Void)
    func unobserve(view: UIView)
}

public class Handler: NSObject, HandlerProtocol {

    public var type: AnyObject.Type?
    
    let fn : (value: AnyObject?, onView: UIView) -> Void
    
    
    init (type: AnyClass, setValue: (value: AnyObject?, onView: UIView) -> Void) {
        self.fn = setValue
        self.type = type
        super.init()
    }
    
    public func setValue(value: AnyObject?, onView: UIView) {
        self.fn(value: value, onView: onView);
    }
}


public class PropertyHandler : Handler {
    public var keyPath: String
    //public var type: AnyObject.Type
    
    init (keyPath: String, type: AnyClass) {
        self.keyPath = keyPath
        super.init(type: type, setValue: { (value, onView) -> Void in
            onView.setValue(value, forKeyPath: keyPath)
        })
    
    }

}


class Repository : NSObject {
    static let shared = Repository()
    
    var handlers : Dictionary<String,HandlerProtocol> = Dictionary<String,HandlerProtocol>()

    //var handlers : Dictionary<String,HandlerProtocol> = Dictionary<String,HandlerProtocol>()
    var converters : Dictionary<String,ConverterProtocol> = Dictionary<String, ConverterProtocol>()
    
    func registerHandler(type:AnyClass, handler: HandlerProtocol) -> HandlerProtocol {
        self.handlers[NSStringFromClass(type)] = handler as HandlerProtocol?
        return handler
    }
    
    static func handler(view: AnyObject) -> HandlerProtocol? {
        let str = NSStringFromClass(view.dynamicType.self)
        return Repository.shared.handlers[str]
    }
    
    func registerConverter(name: String, converter: ConverterProtocol) -> ConverterProtocol {
        self.converters[name] = converter
        return converter
    }
    
    static func converter(name: String) -> ConverterProtocol? {
        return self.shared.converters[name]
    }
    
}