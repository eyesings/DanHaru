//
//  UIColor+Extension.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/26.
//

import Foundation
import UIKit

extension UIColor {
    
    static var mainColor = {
        return RadHelper.colorFromHex(hex: "D0C2C1")
    }()
    
    static var subLightColor = {
        return RadHelper.colorFromHex(hex: "EFE6E4")
    }()
    
    static var subHeavyColor = {
        return RadHelper.colorFromHex(hex: "9E9493")
    }()
    
    static var backgroundColor = {
        return RadHelper.colorFromHex(hex: "FFFCFC")
    }()
    
    static var customBlackColor = {
        return RadHelper.colorFromHex(hex: "253138")
    }()
    
    static var heavyGrayColor = {
        return RadHelper.colorFromHex(hex: "6D7172")
    }()
    
    static var lightGrayColor = {
        return RadHelper.colorFromHex(hex: "BCBEBF")
    }()
}