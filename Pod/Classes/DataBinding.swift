//
//  DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import XCGLogger
import MapKit;

public class DataBinding : NSObject {
    private static var _log: XCGLogger?
    
    static var log: XCGLogger {
        if _log == nil {
            _log = XCGLogger()
            _log!.setup(logLevel: .None, showThreadName: false, showLogLevel: true, showFileNames: false, showLineNumbers: false, writeToFile: nil, fileLogLevel: nil)
        }
        return _log!
    }
    public static var debug: Bool {
        get {
            return !self.log.isEnabledForLogLevel(.None)
        }
        set (val) {
            let logLevel : XCGLogger.LogLevel = val == true ? .Debug : .None
            self.log.setup(logLevel: logLevel, showThreadName: false, showLogLevel: true, showFileNames: false, showLineNumbers: false, writeToFile: nil, fileLogLevel: nil)
        }
    }
    
    public static func registerHandler(type: AnyClass, handler: HandlerProtocol) {
        Repository.shared.registerHandler(type, handler: handler)
    }
    
    public static func registerConverter(name: String, converter: ConverterProtocol) {
        Repository.shared.registerConverter(name, converter: converter)
    }
    
    public static func registerConverter(name: String, convert: (value: AnyObject, view: UIView, data: AnyObject) -> AnyObject? ) {
        
        let converter = Converter(fn: convert)
        self.registerConverter(name, converter: converter)
    }
    
    public static func registerHandlers() {
        
        struct TokenHolder {
            static var token: dispatch_once_t = 0;
        }
        
        self.registerHandler(UILabel.self, handler:Handler(type: NSString.self,setValue: { (value, onView) -> Void in
            let label = onView as! UILabel
            if value == nil {
                label.text = ""
            } else {
                label.text = value as? String
            }
        }))
    
                
        self.registerHandler(UISlider.self, handler: UISliderHandler())
        self.registerHandler(UITextField.self, handler: UITextFieldHandler())
        self.registerHandler(UIImageView.self, handler: UIImageViewHandler())
        self.registerHandler(UIWebView.self, handler: UIWebViewHandler())
        
        self.registerHandler(UIButton.self, handler: UIButtonHandler())
        self.registerHandler(MKMapView.self, handler: MKMapViewHandler())
        self.registerConverter("array", converter: Converter(fn: { (value, view, data) -> AnyObject? in
            var out: AnyObject? = value
            if let array = value as? NSArray {
                if array.count > 0 {
                    out = array[0]
                } else {
                    out = nil
                }
            } else if let set = value as? NSSet {
                out = set.anyObject()
            }
            
            return out;
        }))
        
        
        
        dispatch_once(&TokenHolder.token) {
            UIViewController.swizzle()
        }
        
        
    }
    
}