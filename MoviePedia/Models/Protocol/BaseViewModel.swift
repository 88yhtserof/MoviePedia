//
//  BaseViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/11/25.
//

import Foundation

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform()
}
