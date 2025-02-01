//
//  Identifier.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/1/25.
//

import Foundation

struct Identifier<T: Hashable>: Hashable, Identifiable {
    let id = UUID()
    let value: T
    
    init(value: T) {
        self.value = value
    }
}
