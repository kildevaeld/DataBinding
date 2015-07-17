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
        
        if prop == "@" {
            self.setValue(obj)
        } else {
            let value : AnyObject? = getValue(obj, prop: prop)
            self.setValue(value)
        }
        
        
    }
    
    func observe () {
        
        if self.keyPath == "@" {
            self.setValue(self.data)
            return
        }
        
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
    }
    
    private func getValue (data: NSObject, prop: String) -> AnyObject? {
        
        if let dict = data as? NSDictionary {
            if let obj: AnyObject? = dict.objectForKey(prop) {
                return obj
            }
            
        } else {
            
            if prop.rangeOfString(".") != nil {
                return data.valueForKey(prop)
            } else {
                if PropertyFinder.hasProperty(prop, object: data) {
                    return data.valueForKeyPath(prop)
                }
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
        println("deinit \(self.view.viewID)")
        self.unobserve()
    }
}