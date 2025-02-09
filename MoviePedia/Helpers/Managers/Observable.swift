//
//  Observable.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/7/25.
//

import Foundation

class Observable<T> {
    
    private var closure: ((T) -> Void)?
    
    var value: T {
        didSet {
            closure?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    /// Bind the closure with value. The closure was called when the value did set and this method was called.
    func bind(_ closure: @escaping ((T) -> Void)) {
        closure(value)
        self.closure = closure
    }
    
    /// Bind the closure with value. The closure calls lazily, so that the closure was called when the value did set only.
    func lazyBind(_ closure: @escaping ((T) -> Void)) {
        self.closure = closure
    }
    
    /// Sets the value to the received value.
    func send(_ value: T) {
        self.value = value
    }
    
    func send() where T == Void {
        self.value = ()
    }
}
