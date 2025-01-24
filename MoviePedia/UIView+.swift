//
//  UIView+.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/24/25.
//

import UIKit

extension UIView {
    
    /// Add views to the end of the receiver’s list of subviews.
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
    
    /// Clips this view to its bounding frame, with the specified corner radius.
    func cornerRadius(_ radius: CGFloat = 10.0) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    /// Draws a border on this view.
    func border(width: CGFloat = 1.0, color: UIColor = .black) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
