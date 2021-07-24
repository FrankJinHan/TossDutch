//
//  String+extension.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import Foundation

extension String {
    var isoDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}
