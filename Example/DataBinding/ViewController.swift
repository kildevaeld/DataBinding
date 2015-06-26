//
//  ViewController.swift
//  DataBinding
//
//  Created by Softshag & Me on 06/19/2015.
//  Copyright (c) 06/19/2015 Softshag & Me. All rights reserved.
//

import UIKit
import MapKit

class Blog : NSObject {
    dynamic var title: String?
    dynamic var imageName: String?
    dynamic var age: NSNumber?
    dynamic var image: [String]?
    dynamic var url: [String]? = ["<h1>Hello World</h1>"]
    dynamic var location : CLLocation?
    dynamic var date: NSDate = NSDate()
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.bind.prop = "Title"
        
        let blog = Blog()
        blog.title = "Test Title"
        blog.age = 4
        blog.image = ["Image", "Default"]
        blog.location = CLLocation()
        
        
        self.view.bindData(blog)
        
        var delta: Int64 = 5 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        //dispatch_suspend(dispatch_get_main_queue())
        dispatch_after(time, dispatch_get_main_queue(), {
            println("delay")
            blog.title = "A new cool title"
            blog.imageName = "Image"
            //self.view.bindData(Blog())
        });
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

