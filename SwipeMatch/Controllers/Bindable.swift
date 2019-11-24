//
//  Bindable.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 17/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }

    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}
