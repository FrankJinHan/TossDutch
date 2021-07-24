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
}

protocol DutchListener: AnyObject {
    func closeDutch()
}

final class DutchInteractor: PresentableInteractor<DutchPresentable>, DutchInteractable, DutchPresentableListener {

    weak var router: DutchRouting?
    weak var listener: DutchListener?

    init(presenter: DutchPresentable, requirement: DutchInteractorRequired) {
        self.requirement = requirement
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
    }
    
    func close() {
        listener?.closeDutch()
    }
    
    private let requirement: DutchInteractorRequired
}
