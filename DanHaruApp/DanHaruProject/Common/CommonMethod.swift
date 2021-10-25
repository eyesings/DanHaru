//
//  CommonMethod.swift
//  DanHaruProject
//
//  Created by RadCns_SON_JIYOUNG on 2021/10/25.
//

import Foundation

/// 개발전용 로그
/// - Parameters:
///   - obj: 출력 값
///   - function: 해당 함수명
/// - Returns: 출력로그
func Dprint(_ obj: Any..., function: String = #function) -> () {
    #if DEBUG
    print("\(function) : \(obj)")
    #endif
}