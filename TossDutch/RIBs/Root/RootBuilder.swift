//
//  RootBuilder.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs

protocol RootDependency: Dependency {
    
}

final class RootComponent: Component<RootDependency> {

}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = RootComponent(dependency: dependency)
        let viewController = RootViewController()
        let interactor = RootInteractor(presenter: viewController)
        
        let dutchBuilder = DutchBuilder(dependency: component)
        
        return RootRouter(interactor: interactor, viewController: viewController, dutchBuilder: dutchBuilder)
    }
}
