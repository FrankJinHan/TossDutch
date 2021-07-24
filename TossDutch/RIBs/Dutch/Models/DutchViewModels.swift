//
//  DutchViewModels.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RxDataSources

enum DutchSectionModel {
    case summary(items: [DutchSectionItem])
    case detail(items: [DutchSectionItem])
}

enum DutchSectionItem {
    case summary(viewModel: DutchSummaryViewModeling)
    case detail(viewModel: DutchDetailViewModeling)
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

extension DutchSummary: DutchSummaryViewModeling {
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

extension DutchDetail: DutchDetailViewModeling {
    var nameText: String {
        name
    }
    
    var amountDescription: String {
        "\(amount.addComma ?? "-")원"
    }
    
    var messageDescription: String? {
        transferMessage
    }
    
    var status: DutchDetailStatus {
        isDone ? .completed : .retry
    }
}
