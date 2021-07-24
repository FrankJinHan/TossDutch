//
//  RootRouter.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs

protocol RootInteractable: Interactable, DutchListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    func presentNavigation(rootViewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {

    init(interactor: RootInteractable, viewController: RootViewControllable, dutchBuilder: DutchBuildable) {
        self.dutchBuilder = dutchBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func routeToDutch(requirement: DutchDynamicRequired) {
        guard dutchRouter == nil else { return }
        let router = dutchBuilder.build(withListener: interactor, requirement: requirement)
        dutchRouter = router
        attachChild(router)
        viewController.presentNavigation(rootViewController: router.viewControllable)
    }
    
    func detachDutch() {
        guard let router = dutchRouter else { return }
        dutchRouter = nil
        viewController.dismiss(viewController: router.viewControllable)
        detachChild(router)
    }
    
    // MARK: - Privates
    
    private let dutchBuilder: DutchBuildable
    private var dutchRouter: DutchRouting?
}
