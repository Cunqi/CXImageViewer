//
//  File.swift
//  
//
//  Created by Cunqi Xiao on 4/27/24.
//

import UIKit

extension CGSize: Comparable {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: rhs.width * lhs, height: rhs.height * lhs)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    public static func <(lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width < rhs.width || lhs.height < rhs.height
    }
    
    public static func ^(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }
    
    var ratio: CGFloat {
        width / height
    }
    
    init(_ value: CGFloat) {
        self.init(width: value, height: value)
    }
}
