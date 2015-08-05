//
//  Bind.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation


func getValue (data: NSObject, prop: String) -> AnyObject? {
    
    if let dict = data as? NSDictionary {
        if let obj: AnyObject? = dict.objectForKey(prop) {
            return obj
        }
        
    } else {
        
        if prop.rangeOfString(".") != nil {
            return data.valueForKeyPath(prop)
        } else {
            if PropertyFinder.hasProperty(prop, object: data) {
                return data.valueForKey(prop)
            }
        }
        
    }
    
    DataBinding.log.error("obj \(data) does not have property: \(prop)")
    
    return nil
    
}


public class Binding : NSObject {
    
    public var on: String?
    public var recursive: Bool?
    
    /** Property to bind to */
    public var to: String?
    /** Property to get value from */
    public var prop: String?
    /** Comma separated converter list */
    public var convert: String?
    /** Default value */
    public var defaultValue: String?
    /** Hide the value on no value */
    public var hideOnNoValue: Bool = false
    /** Only bind on the kind if object */
    public var kind: String?
    /** Format the out */
    public var format: String?
    /** Two sync */
    public var sync: Bool = false
    /** Show if not nil */
    public var show: String?
    /** Hide if not nil */
    public var hide: String?
    
    
    public let view : UIView
    
    /** The binder reference */
    private var binder: Binder?
    /** The currently associated data */
    private var _data: NSObject?
    public var data: NSObject? {
        return _data
    }
    
    init (view: UIView) {
        self.view = view
    }
    
    /** Bind a data object.*/
    public func bindData(data: NSObject) {
        
        if self.data != nil {
            self.unbindData()
        }
        
        if self.show != nil {
            let val: AnyObject? = getValue(data, self.show!)
            if val == nil {
                self.view.hidden = true
                return
            } else {
                self.view.hidden = false
            }
        }
        
        // No prop, no map
        if self.prop == nil {
            return
        }
        
        if self.kind != nil {
            let klass: AnyClass! = NSClassFromString(self.kind!)
            if !data.isKindOfClass(klass) {
                return
            }
        }
        
        /*if !PropertyFinder.hasProperty(self.prop!, object: data) {
            return
        }*/
        
        _data = data
        
        
        let handler = getHandler()
        
        if handler == nil {
            let str = NSStringFromClass(self.view.dynamicType.self)
            DataBinding.log.error("no handler for \(str)")
            return
        }
        
        
        self.binder = Binder(obj:data, prop: self.prop!, handler:handler!, view:self.view)
        
        self.binder!.converters = getConverters()
        self.binder!.defaultValue = self.defaultValue
        self.binder!.format = self.format
        
        self.binder!.observe(once: !self.sync)
    
    }
    
    public func unbindData() {
        self.binder?.unobserve()
        self.binder = nil
        _data = nil
        
    }
    
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