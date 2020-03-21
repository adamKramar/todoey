//
//  TaskModel.swift
//  Todoey
//
//  Created by Adam Kramar on 21/03/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

class Item {
    
    let title: String
    var done: Bool
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
