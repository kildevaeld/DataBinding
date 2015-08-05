//
//  Binder.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation

import Block_KVO
import CoreData

public class Binder : NSObject {
    let data : NSObject
    let keyPath: String
    var format: String?
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
        
    }
    
    func observe (once: Bool = true) {
        
        if self.keyPath == "@" {
            self.setValue(self.data)
            return
        }
        
        if once == true {
            let value : AnyObject? = getValue(self.data, prop: self.keyPath)
            self.setValue(value)
        } else {
            self.observeProperty("self.data." + self.keyPath, withBlock: { (s, old, new) -> Void in
                self.setValue(new)
            });
            
            if let observable = handler as? ObservableHandlerProtocol {
                observable.observe(self.view, fn: { (value) -> Void in
                    self.data.setValue(value, forKeyPath: self.keyPath)
                })
            }
        }
        
        
    }
    
    func unobserve () {
        if let observable = handler as? ObservableHandlerProtocol {
            observable.unobserve(self.view)
        }
    }
    
    private func getValue (data: NSObject, prop: String) -> AnyObject? {
        var result: AnyObject? = nil
        if let dict = data as? NSDictionary {
            if let obj: AnyObject? = dict.objectForKey(prop) {
                result = obj
            }
            
        } else {
            
            /*if prop.rangeOfString(".") != nil {
                
            } else {
                if PropertyFinder.hasProperty(prop, object: data) {
                    result = data.valueForKey(prop)
                }
            }*/
            result = data.valueForKeyPath(prop)
            
        }
        
        DataBinding.log.error("obj \(data) does not have property: \(prop)")
        
        return result
        
    }
    
    func setValue(value: AnyObject?) {
        var val: AnyObject? = value
        
        if val == nil {
            val = self.defaultValue
        }
        
        if val != nil {
            
            for converter in converters {
                val = converter.convert(val!, view: self.view, data: data)
                if val == nil { break }
            }
            
            if self.format != nil {
                val = _formatValue(val!, self.format!)
            }
            
            if val != nil {
                if handler.type != nil {
                    val = _transformValue(val!, handler.type!)
                }
            }
        }
        
        self.handler.setValue(val, onView: self.view)
    }
    
    deinit {
        self.unobserve()
    }
}