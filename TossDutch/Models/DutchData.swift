//
//  DutchData.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import Foundation

struct DutchData: Decodable {
    let dutchSummary: DutchSummary
    let dutchDetailList: [DutchDetail]
}

struct DutchSummary: Decodable {
    let ownerName: String
    let message: String
    let ownerAmount: Int64
    let completedAmount: Int64
    let totalAmount: Int64
    let date: String
}

struct DutchDetail: Decodable {
    let dutchId: Int
    let name: String
    let amount: Int64
    let transferMessage: String?
    let isDone: Bool
}
