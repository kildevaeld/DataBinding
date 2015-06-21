//
//  PropertyFinder.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 20/06/15.
//
//

import Foundation
import UIKit


func getPropertyType (property: objc_property_t) -> String? {
    
    let attributes = property_getAttributes(property)
    let str = String.fromCString(attributes)
    
    if nil == str {
        return nil
    }
    
    let s1 = str![str!.startIndex]
    let s2 = str![str!.startIndex.successor()]
    var s3 : Character?
    
    let l = distance(str!.startIndex,str!.endIndex)
    
    if l > 4 {
        s3 = str![advance(str!.startIndex, 3)]
    }

    var out : String?
    if  s1 == "T" && s2 != "@" {
        // Scalar
        out = nil
    } else if s1 == "T" && s2 == "@" && s3 != nil && s3! == "<" {
        // Delegates
        out = nil
    } else if s1 == "T" && s2 == "@" {
        
        out = str!.substringFromIndex(advance(minElement(indices(str!)), 3))
        let range = find(out!, ",")
        
        if range == nil {
            return nil
        }

        if range != out!.startIndex {
            out = out!.substringToIndex(range!.predecessor())
        } else {
            out = nil
        }
        
        
        
        // Check if generic
        if (out != nil && out!.hasSuffix(">")) {
            return nil
        }

    }
    
    return out == "" ? nil : out
}


struct Result {
    let name: String
    let type: AnyClass
    init (name: String, type: AnyClass) {
        self.name = name
        self.type = type
    }
}

class PropertyFinder {
    static func hasProperty (prop: String, type: AnyClass) -> Bool {
        return self.propertyType(prop, type: type) != nil
    }
    static func hasProperty (prop: String, object: NSObject) -> Bool {
        return self.propertyType(prop, object: object) != nil
    }
    
    static func propertyType(prop: String, type: AnyClass) -> AnyClass? {
        
        let properties = PropertyFinder.propertiesForClass(type)
        
        for p in properties {
            if p.name == prop {
                return p.type
            }
        }
        
        return nil
    }
    
    static func propertyType(prop: String, object:NSObject)  -> AnyClass? {
        let properties  = PropertyFinder.propertiesForObject(object)
        
        for p in properties {
            if p.name == prop {
                return p.type
            }
        }
        
        return nil
    }
    
    static func propertiesForObject(obj: NSObject?) -> [Result] {
        if obj == nil {
            return []
        }
        let mirrors = reflect(obj)
        var out = listProperties(mirrors)
        
        out += propertiesForClass(obj!.dynamicType.self)
        
        return out
    }
    
    static private func listProperties(mirror: MirrorType) -> [Result] {
        var out: [Result] = []
        for (var i=0;i<mirror.count;i++) {
            if (mirror[i].0 == "super") {
                out += listProperties(mirror[i].1)
            }
            else {
                let (index, mir) = mirror[i]
                let valueType = mir.valueType
                var value = mir.value
                
                var type: AnyClass?
                
                if valueType is String.Type || valueType is String?.Type {
                    type = NSString.self
                } else if valueType is NSNumber.Type || valueType is NSNumber?.Type {
                    type = NSNumber.self
                } else if valueType is NSDate.Type || valueType is NSDate?.Type {
                    type = NSDate.self
                } else if valueType is UIImage.Type || valueType is UIImage?.Type {
                    type = UIImage.self
                } else if valueType is NSString.Type || valueType is NSString?.Type {
                    type = NSString.self
                } else {
                    type = AnyClass.self
                }
                
                if type != nil {
                    let result = Result(name: mirror[i].0,type: type!)
                    out.append(result)
                }
                
            }
        }
        return out
    }
    
    static func propertiesForClass(type: AnyClass) -> [Result] {
        
        var results : [Result] = []
        
        var count: UInt32 = 0
    
        let properties = class_copyPropertyList(type, &count)
        
        for (var i = 0; UInt32(i) < count; i++) {
            
            let property = properties[i as Int]
            
            let propName = property_getName(property)
            
            if propName != nil {
                let name = String.fromCString(propName)
                let propType = getPropertyType(property)
                
                if propType != nil && name != nil {
                    
                    let type : AnyClass! = NSClassFromString(propType)
                    
                    if type == nil {
                        continue
                    }
                    results.append(Result(name: name!,type: type))
                }
            }
        }
        
        let superClass : AnyClass! = class_getSuperclass(type)
        
        if superClass != nil {
            results += propertiesForClass(superClass)
        }
        
        
       return results
    }
}