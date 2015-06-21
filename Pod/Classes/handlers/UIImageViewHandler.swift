//
//  UIImageHandler.swift
//  Pods
//
//  Created by Rasmus Kildevæld   on 21/06/15.
//
//

import Foundation


class UIImageViewHandler : HandlerProtocol {
    
    var type: AnyObject.Type? = nil

    func setValue(value: AnyObject?, onView: UIView) {
        let imageView = onView as! UIImageView;
        imageView.stopAnimating()
        if let str = value as? String {
            imageView.image = UIImage(named:str)
        } else if let image = value as? UIImage {
            imageView.image = image
        } else if let array = value as? NSArray {
            var images: [UIImage] = []
            for item in array {
                var image : UIImage?
                if let str = item as? String {
                    image = UIImage(named:str)
                } else if let img = item as? UIImage {
                    image = img
                }
                if image != nil {
                    images.append(image!)
                }
            }
            imageView.animationImages = images
            imageView.animationDuration = 5.0
    
            imageView.startAnimating()
        }
    }
}