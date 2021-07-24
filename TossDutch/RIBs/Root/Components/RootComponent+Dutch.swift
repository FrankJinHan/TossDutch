//
//  RootComponent+Dutch.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs

protocol RootDependencyDutch: Dependency {
    
}

extension RootComponent: DutchDependency {
    var dutchStaticRequirement: DutchStaticRequired {
        DutchStaticRequirement(navigationBarTitle: "더치페이")
    }
}
