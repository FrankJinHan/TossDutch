//
//  DutchModels.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RxDataSources
import Foundation

enum DutchSectionModel {
    case summary(items: [DutchSectionItem])
    case detail(items: [DutchSectionItem])
}

enum DutchSectionItem {
    case summary(model: DutchSummaryModel)
    case detail(model: DutchDetailModel)
}

extension DutchSectionModel: SectionModelType {
    typealias Item = DutchSectionItem
    
    var items: [Item] {
        switch  self {
        case let .summary(items):
            return items
        case let .detail(items):
            return items
        }
    }
    
    init(original: DutchSectionModel, items: [Item]) {
        switch original {
        case .summary:
            self = .summary(items: items)
        case .detail:
            self = .detail(items: items)
        }
    }
}

struct DutchSummaryModel {
    let ownerName: String
    let message: String
    let ownerAmount: Int64
    let completedAmount: Int64
    let totalAmount: Int64
    let date: String
}

extension DutchSummaryModel: DutchSummaryTableViewCellViewModelable {
    var dateDescription: String {
        date.isoDate?.toString ?? "-"
    }
    
    var amountDescription: String {
        "\(completedAmount.addComma ?? "-") 원 완료 / 총 \(totalAmount.addComma ?? "-") 원"
    }
    
    var messageDescription: String {
        "\(ownerName): \(message)"
    }
}

struct DutchDetailModel {
    let dutchId: Int
    let name: String
    let amount: Int64
    let transferMessage: String?
    let isDone: Bool
}

extension DutchDetailModel: DutchDetailTableViewCellViewModelable {
    var nameText: String {
        name
    }
    
    var amountDescription: String {
        "\(amount.addComma ?? "-")원"
    }
    
    var messageDescription: String? {
        transferMessage
    }
}
