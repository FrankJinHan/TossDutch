//
//  DutchInteractor.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift

protocol DutchRouting: ViewableRouting {
    
}

protocol DutchPresentable: Presentable {
    var listener: DutchPresentableListener? { get set }
    func setNavigationBarTitle(_ title: String)
    func reload(sections: [DutchSectionModel])
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
        service.requestDutchData()
            .subscribe(onSuccess: { [weak presenter] dutchData in
                presenter?.reload(sections: dutchData.sections)
            }, onFailure: { error in
                //TODO : show popup
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    func close() {
        listener?.closeDutch()
    }
    
    private let requirement: DutchInteractorRequired
    
    private let service: DutchService
}

private extension DutchData {
    var sections: [DutchSectionModel] {
        [
            .summary(items: [.summary(viewModel: dutchSummary)]),
            .detail(items: details)
        ]
    }
    
    private var details: [DutchSectionItem] {
        dutchDetailList.map {
            .detail(viewModel: $0)
        }
    }
}
