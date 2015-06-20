//
//  repository.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import UIKit

public protocol HandlerProtocol {
    var type : AnyObject.Type { get }
    func setValue(value: AnyObject?, onView: UIView)
    
}

public protocol ObservableHandlerProtocol {
    func observe(view: UIView, fn: (value: AnyObject?) -> Void)
    func unobserve(view: UIView)
}

public class Handler: NSObject, HandlerProtocol {

    public var type: AnyObject.Type
    
    let fn : (value: AnyObject?, onView: UIView) -> Void
    
    
    init (setValue: (value: AnyObject?, onView: UIView) -> Void, type: AnyClass) {
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
        super.init(setValue: { (value, onView) -> Void in
            onView.setValue(value, forKeyPath: keyPath)
        }, type: type)
    
    }

}


class Repository : NSObject {
    static let shared = Repository()
    
    var handlers : Dictionary<String,HandlerProtocol> = Dictionary<String,HandlerProtocol>()
    var converters : Dictionary<String,ConverterProtocol> = Dictionary<String, ConverterProtocol>()
    
    func registerHandler<T: NSObject>(type:T.Type, handler: HandlerProtocol) -> HandlerProtocol {
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
    
    private override init () {
        super.init()
        
        self.registerHandler(UILabel.self, handler:Handler(setValue: { (value, onView) -> Void in
            let label = onView as! UILabel
            if value == nil {
                label.text = ""
            } else {
                label.text = value as? String
            }
            
            
            
            
        }, type: NSString.self))
        
        self.registerHandler(UISlider.self, handler: UISliderHandler())
        self.registerHandler(UITextField.self, handler: UITextFieldHandler())
        
        
        self.registerHandler(UIImageView.self, handler: Handler(setValue: { (value, onView) -> Void in
            let imageView = onView as! UIImageView
            if value == nil {
                imageView.image = nil
            } else {
                imageView.image = value as? UIImage
            }
            
        }, type: UIImage.self))
        
        self.registerConverter("to_image", converter: Converter(fn: { (value, view, data) -> AnyObject? in
            var out: AnyObject? = value
            if let str = value as? String {
                
                if str.hasPrefix("http://") || str.hasPrefix("https://") {
                    
                } else {
                    out = UIImage(named: str)
                }
                
            }
            
            return out
        }))
        
    }
    
    
}