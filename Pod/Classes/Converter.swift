//
//  Converter.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 20/06/15.
//
//

import Foundation

@objc public protocol ConverterProtocol {
    func convert (value: AnyObject, view:UIView, data: AnyObject) -> AnyObject?
}

@objc public class Converter : NSObject, ConverterProtocol {
    
    var fn : (value: AnyObject, view: UIView, data: AnyObject) -> AnyObject?

    public init (fn: (value: AnyObject, view: UIView, data: AnyObject) -> AnyObject?) {
        self.fn = fn
    }
    public func convert(value: AnyObject, view: UIView, data: AnyObject) -> AnyObject? {
        return self.fn(value: value,view: view,data: data)
    }
}