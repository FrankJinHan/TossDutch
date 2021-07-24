//
//  Date+extension.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import Foundation

extension Date {
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return dateFormatter.string(from: self)
    }
}
