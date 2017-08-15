//
//  ArrayReference.swift
//  Shoot Out
//
//  Created by Eli Bradley on 8/14/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation

class ArrayReference<Element> {
    var array: [Element]?
    
    init() {
        array = []
    }
    
    deinit {
        array = nil
    }
}
