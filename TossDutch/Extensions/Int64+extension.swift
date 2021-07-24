//
//  Int64+extension.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import Foundation

extension Int64 {
    var addComma: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))
    }
}
