//
//  DutchRouter.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs

protocol DutchInteractable: Interactable {
    var router: DutchRouting? { get set }
    var listener: DutchListener? { get set }
}

protocol DutchViewControllable: ViewControllable {
    
}

final class DutchRouter: ViewableRouter<DutchInteractable, DutchViewControllable>, DutchRouting {

    override init(interactor: DutchInteractable, viewController: DutchViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
