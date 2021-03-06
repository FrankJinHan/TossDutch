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
        DutchStaticRequirement(navigationBarTitle: "λμΉνμ΄")
    }
    
    var dutchService: DutchService {
        DutchServiceImpl()
    }
}
