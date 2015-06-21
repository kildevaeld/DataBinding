//
//  UIWebViewHandler.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation

class UIWebViewHandler : NSObject, HandlerProtocol {
    
    var type: AnyObject.Type? = nil
    
    func setValue(value: AnyObject?, onView: UIView) {
        let webView = onView as! UIWebView;
        var url: NSURL?
        var html: String?
        
        if let _url = value as? NSURL {
            url = _url
        } else if let str = value as? String {
            
            if str.hasPrefix("http://") || str.hasPrefix("https://") {
                url = NSURL(string: str as String)
            } else {
                html = str
            }
        }
        
        if url != nil {
            let request = NSURLRequest(URL: url!)
            webView.loadRequest(request)
        } else if html != nil {
            webView.loadHTMLString(html!, baseURL: NSURL())
        }
        
    }
}