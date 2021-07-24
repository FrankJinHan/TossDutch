//
//  DutchInteractor.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift
import Foundation

final class DutchDetailRetryStatus {
    var startTime: Date?
    var current: Float? {
        guard let startTime = startTime else {
            return nil
        }
        let interval = Date().timeIntervalSince(startTime)
        return Float(interval) / GlobalConstant.dutchRetryDuration
    }
}

struct DutchDetailItem {
    let nameText: String
    let amountDescription: String
    let messageDescription: String?
    let retryStatus: DutchDetailRetryStatus
    let isDone: Bool
    var buttonTappedClosure: (() -> Void)?
    var progressButtonTappedClosure: (() -> Void)?
}

protocol DutchRouting: ViewableRouting {
    
}

protocol DutchPresentable: Presentable {
    var listener: DutchPresentableListener? { get set }
    func setNavigationBarTitle(_ title: String)
    func reload(sections: [DutchSectionModel])
    func showError(_ error: Error)
}

protocol DutchListener: AnyObject {
    func closeDutch()
}

final class DutchInteractor: PresentableInteractor<DutchPresentable>, DutchInteractable, DutchPresentableListener {

    weak var router: DutchRouting?
    weak var listener: DutchListener?

    init(presenter: DutchPresentable, requirement: DutchInteractorRequired, service: DutchService) {
        self.requirement = requirement
        self.service = service
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    
    }

    override func willResignActive() {
        super.willResignActive()
        
    }
    
    func viewDidLoad() {
        presenter.setNavigationBarTitle(requirement.navigationBarTitle)
        requestDutchData()
    }
    
    func close() {
        listener?.closeDutch()
    }
    
    func refresh() {
        requestDutchData()
    }
    
    private let requirement: DutchInteractorRequired
    
    private let service: DutchService
    
    private func requestDutchData() {
        service.requestDutchData()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] dutchData in
                self?.update(dutchData: dutchData)
            }, onFailure: { [weak presenter] error in
                print(error)
                presenter?.showError(error)
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    private func update(dutchData: DutchData) {
        presenter.reload(sections: dutchData.sections)
    }
}

private extension DutchData {
    var sections: [DutchSectionModel] {
        [
            .summary(items: [.summary(viewModel: dutchSummary)]),
            .detail(items: dutchDetailList.map {
                .detail(viewModel: $0.dutchDetailItem)
            })
        ]
    }
}

private extension DutchDetail {
    var dutchDetailItem: DutchDetailItem {
        let retryStatus = DutchDetailRetryStatus()
        return DutchDetailItem(
            nameText: name,
            amountDescription: "\(amount.addComma ?? "-")원",
            messageDescription: transferMessage,
            retryStatus: retryStatus,
            isDone: isDone,
            buttonTappedClosure: { [weak retryStatus] in
                guard !isDone else { return }
                retryStatus?.startTime = Date()
            },
            progressButtonTappedClosure: { [weak retryStatus] in
                retryStatus?.startTime = nil
            })
    }
}
