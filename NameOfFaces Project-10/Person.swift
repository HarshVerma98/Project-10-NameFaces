//
//  Person.swift
//  NameOfFaces Project-10
//
//  Created by Harsh Verma on 14/08/21.
//

import UIKit
class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
