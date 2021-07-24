//
//  DutchInteractor.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift
import Foundation
import RxRelay

struct DutchDetailItem: DutchDetailViewStatusCompatible {
    let dutchId: Int
    let nameText: String
    let amountDescription: String
    let messageDescription: String?
    var status: DutchDetailStatus
    var currentRetryProgress: Float? {
        guard let startTime = startTime else {
            return nil
        }
        switch status {
        case .retrying:
            let interval = Date().timeIntervalSince(startTime)
            return Float(interval) / GlobalConstant.dutchRetryDuration
        default:
            return nil
        }
    }
    
    var isEnabled: Bool
    var startTime: Date?
}

protocol DutchRouting: ViewableRouting {
    
}

protocol DutchPresentable: Presentable {
    var listener: DutchPresentableListener? { get set }
    func setNavigationBarTitle(_ title: String)
    func reload(sections: [DutchSectionModel])
    func showPopup(title: String)
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
    
        buttonTappedModelSubject
            .subscribe(onNext: { [weak self] in
                self?.detailButtonTapped(model: $0)
            })
            .disposeOnDeactivate(interactor: self)
        
        buttonTappedModelSubject
            .map { $0.button.showsCannotRetryPopup }
            .filter { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showPopup(title: "재요청은 한 번만 가능합니다.")
            })
            .disposeOnDeactivate(interactor: self)
        
        isEnabledRelay
            .subscribe(onNext: { [weak self] in
                self?.updateItems(isEnabled: $0)
            })
            .disposeOnDeactivate(interactor: self)
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
    
    func setEnabled() {
        isEnabledRelay.accept(true)
    }
    
    private let requirement: DutchInteractorRequired
    
    private let service: DutchService
    
    private var buttonTappedModelSubject = PublishSubject<DutchDetailButtonTappedModeling>()
    
    private let dutchDetailItemsRelay = BehaviorRelay<[DutchDetailItem]>(value: [])
    
    private let isEnabledRelay = BehaviorRelay<Bool>(value: true)
    
    private func requestDutchData() {
        service.requestDutchData()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] dutchData in
                self?.update(dutchData: dutchData)
            }, onFailure: { [weak self] error in
                self?.showPopup(title: error.localizedDescription)
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    private func update(dutchData: DutchData) {
        let newDutchDetailItems = dutchData.dutchDetailList.map {
            $0.makeItem(oldItems: dutchDetailItemsRelay.value)
        }
        
        dutchDetailItemsRelay.accept(newDutchDetailItems)
        
        let detailViewModels: [DutchDetailViewModel] = newDutchDetailItems.enumerated().map { offset, item in
            let buttonTappedSubject = PublishSubject<DutchDetailButton>()
            buttonTappedSubject
                .map { DutchDetailButtonTappedModel(dutchId: item.dutchId, button: $0) }
                .bind(to: buttonTappedModelSubject)
                .disposeOnDeactivate(interactor: self)
            return DutchDetailViewModel(dutchId: item.dutchId,
                                 viewStatusObservable: dutchDetailItemsRelay.map({ $0[offset] }),
                                 buttonTappedSubject: buttonTappedSubject)
        }
        
        let sections: [DutchSectionModel] = [
            .summary(items: [.summary(viewModel: dutchData.dutchSummary)]),
            .detail(items: detailViewModels.map({ .detail(viewModel: $0) }))
        ]
        
        presenter.reload(sections: sections)
    }
    
    private func detailButtonTapped(model: DutchDetailButtonTappedModeling) {
        switch model.button {
        case .status:
            let newItems: [DutchDetailItem] = dutchDetailItemsRelay.value.map {
                var newItem = $0
                if newItem.dutchId == model.dutchId {
                    switch newItem.status {
                    case .retry:
                        newItem.startTime = Date()
                        newItem.status = .retrying
                    case .retrying:
                        newItem.startTime = nil
                        newItem.status = .retry(isEnabled: newItem.isEnabled)
                    default:
                        break
                    }
                }
                return newItem
            }
            dutchDetailItemsRelay.accept(newItems)
        case let .progress(completed):
            let newItems: [DutchDetailItem] = dutchDetailItemsRelay.value.map {
                var newItem = $0
                if newItem.dutchId == model.dutchId {
                    switch (newItem.status, completed) {
                    case (.retrying, false):
                        newItem.status = .retry(isEnabled: newItem.isEnabled)
                    case (.retrying, true):
                        newItem.status = .retried(isEnabled: newItem.isEnabled)
                    default:
                        break
                    }
                }
                return newItem
            }
            dutchDetailItemsRelay.accept(newItems)
        }
    }
    
    private func updateItems(isEnabled: Bool) {
        let newItems: [DutchDetailItem] = dutchDetailItemsRelay.value.map {
            var newItem = $0
            newItem.status.set(isEnabled: isEnabled)
            return newItem
        }
        dutchDetailItemsRelay.accept(newItems)
    }
    
    private func showPopup(title: String) {
        isEnabledRelay.accept(false)
        presenter.showPopup(title: title)
    }
}

struct DutchDetailViewModel: DutchDetailViewModeling {
    let dutchId: Int
    let viewStatusObservable: Observable<DutchDetailViewStatusCompatible>
    let buttonTappedSubject: PublishSubject<DutchDetailButton>
}

private extension DutchDetail {
    func makeItem(oldItems: [DutchDetailItem]) -> DutchDetailItem {
        var newItem = DutchDetailItem(dutchId: dutchId, nameText: name, amountDescription: "\(amount.addComma ?? "-")원", messageDescription: transferMessage, status: isDone ? .completed : .retry(isEnabled: true), isEnabled: true, startTime: nil)
        if let oldItem = oldItems.first(where: { $0.dutchId == dutchId }), let startTime = oldItem.startTime {
            switch oldItem.status {
            case .retrying:
                newItem.startTime = startTime
                newItem.status = .retrying
            default:
                break
            }
        }
        return newItem
    }
}

private extension DutchDetailStatus {
    mutating func set(isEnabled: Bool) {
        switch self {
        case .retry:
            self = .retry(isEnabled: isEnabled)
        case .retried:
            self = .retried(isEnabled: isEnabled)
        default:
            break
        }
    }
}

private extension DutchDetailButton {
    var showsCannotRetryPopup: Bool {
        switch self {
        case let .status(status):
            switch status {
            case .retried:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}
