//
//  DataBinding.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 19/06/15.
//
//

import Foundation
import XCGLogger
import Block_KVO


public class Binder : NSObject {
    let data : NSObject
    let keyPath: String
    let handler: HandlerProtocol
    let view: UIView
    
    var converters: [ConverterProtocol] = []
    var defaultValue: AnyObject?
    
    init (obj: NSObject, prop: String, handler:HandlerProtocol, view: UIView) {
        self.data = obj
        self.keyPath = prop
        self.handler = handler
        self.view = view
        super.init()
        
        let value : AnyObject? = getValue(obj, prop: prop)
        self.setValue(value)
        
    }
    
    func observe () {
        self.observeProperty("self.data." + self.keyPath, withBlock: { (s, old, new) -> Void in
            self.setValue(new)
        });
        
        if let observable = handler as? ObservableHandlerProtocol {
            observable.observe(self.view, fn: { (value) -> Void in
                self.data.setValue(value, forKeyPath: self.keyPath)
            })
        }
        
        
    }
    
    func unobserve () {
        if let observable = handler as? ObservableHandlerProtocol {
            observable.unobserve(self.view)
        }
        
        self.removeAllObservations()
    }
    
    private func getValue (data: AnyObject, prop: String) -> AnyObject? {
        
        if let dict = data as? NSDictionary {
            if let obj: AnyObject? = dict.objectForKey(prop) {
                return obj
            }
            
        } else {
            if PropertyFinder.hasProperty(prop, object: data) {
                return data.valueForKeyPath(prop)
            }
        }
        
        DataBinding.log.error("obj \(data) does not have property: \(prop)")
        
        return nil
        
    }
    
    func setValue(value: AnyObject?) {
        var val: AnyObject? = value
        
        if val == nil {
            val = self.defaultValue
        }
        
        if val != nil {
            
            for converter in converters {
                val = converter.convert(val!, view: self.view, data: data)
                if val == nil { continue }
            }
            
            if val != nil {
                val = _transformValue(val!, handler.type)
            }
            
        }

        self.handler.setValue(val, onView: self.view)
    }
    
    deinit {
        println("deinit")
        self.unobserve()
    }
}

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
    
    public var to: String?
    public var prop: String?
    public var convert: String?
    public var defaultValue: String?
    public var hideOnNoValue: Bool = false
    
    public let view : UIView
    
    private var binder: Binder?
    
    private var _data: NSObject?
    public var data: NSObject? {
        return _data
    }
    
    init (view: UIView) {
        self.view = view
    }
    
    public func bindData(data: NSObject) {
        
        if self.data != nil {
            self.unbindData()
        }
        
        // No prop, no map
        if self.prop == nil {
            return
        }
        
        if !PropertyFinder.hasProperty(self.prop!, object: data) {
            return
        }
        
        _data = data
        
        
        let handler = getHandler()
        
        if handler == nil {
            DataBinding.log.error("no handler for \(self)")
            return
        }
        
        
        self.binder = Binder(obj:data, prop: self.prop!, handler:handler!, view:self.view)
        
        self.binder!.converters = getConverters()
        self.binder!.defaultValue = self.defaultValue
        
        self.binder!.observe()
        
        
    }
    
    public func unbindData() {
        self.binder?.unobserve()
        self.binder = nil
        _data = nil
        
    }
    
    /*private func getValue (data: AnyObject, prop: String) -> AnyObject? {
        
        if let dict = data as? NSDictionary {
            if let obj: AnyObject? = dict.objectForKey(prop) {
                return obj
            }
            
        } else {
            if PropertyFinder.hasProperty(prop, object: data) {
                return data.valueForKeyPath(prop)
            }
        }
        
        DataBinding.log.error("obj \(data) does not have property: \(prop)")
        
        return nil
        
    }
    
    private func transformValue (value: AnyObject) -> AnyObject? {
        var out : AnyObject?
        let handler = Repository.handler(view)
        
        if self.to != nil {
            var target: AnyClass? = PropertyFinder.propertyType(self.to!, type: self.view.dynamicType.self)
            
            if target != nil {
                out = _transformValue(value, target!)
            }
            
            
        } else if handler != nil {
            out = _transformValue(value, handler!.type)
        }
        
        return out
    }*/
    
    private func getConverters () -> [ConverterProtocol] {
        var out: [ConverterProtocol] = []
        if self.convert != nil {
            let array = stringToArray(self.convert!)
            for a in array {
                let converter = Repository.converter(a)
                if converter != nil {
                    out.append(converter!)
                } else {
                  DataBinding.log.warning("could not find converter: \(a)")
                }
            }
        }
        return out
    }
    
    private func stringToArray (str: String) -> [String] {
        var array = split(str) {$0 == ","}
        var i = 0
        for a in array {
            let str = a.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            array[i++] = str
            
        }
        return array
    }
    
    private func getHandler () -> HandlerProtocol? {
        var handler: HandlerProtocol?
        if self.to != nil {
            var target: AnyClass? = PropertyFinder.propertyType(self.to!, object: self.view)
            
            if target != nil {
                handler = PropertyHandler(keyPath: self.to!, type: target!)
            } else {
                DataBinding.log.warning("could not reflect destination type for keyPath \(self.to!) on \(self.view)")
            }
            
        } else {
            handler = Repository.handler(view)
        }
        return handler
    }
    
    deinit {
        self.unbindData()
    }
}