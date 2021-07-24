//
//  DutchBuilder.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs

protocol DutchDependency: Dependency {
    var dutchStaticRequirement: DutchStaticRequired { get }
}

final class DutchComponent: Component<DutchDependency> {
    fileprivate let requirement: DutchRequired
    
    init(dependency: DutchDependency, dynamicRequirement: DutchDynamicRequired) {
        self.requirement = DutchRequirement(navigationBarTitle: dependency.dutchStaticRequirement.navigationBarTitle)
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol DutchBuildable: Buildable {
    func build(withListener listener: DutchListener, requirement: DutchDynamicRequired) -> DutchRouting
}

final class DutchBuilder: Builder<DutchDependency>, DutchBuildable {

    override init(dependency: DutchDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DutchListener, requirement: DutchDynamicRequired) -> DutchRouting {
        let component = DutchComponent(dependency: dependency, dynamicRequirement: requirement)
        let viewController = DutchViewController()
        let interactor = DutchInteractor(presenter: viewController, requirement: component.requirement)
        interactor.listener = listener
        return DutchRouter(interactor: interactor, viewController: viewController)
    }
}
