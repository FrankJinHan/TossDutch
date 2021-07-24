//
//  DutchRequireds.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import Foundation

protocol DutchStaticRequired {
    var navigationBarTitle: String { get }
}

struct DutchStaticRequirement: DutchStaticRequired {
    let navigationBarTitle: String
}

protocol DutchDynamicRequired {
    
}

struct DutchDynamicRequirement: DutchDynamicRequired {
    
}

protocol DutchInteractorRequired {
    var navigationBarTitle: String { get }
}

protocol DutchRequired: DutchStaticRequired, DutchDynamicRequired, DutchInteractorRequired {
    
}

struct DutchRequirement: DutchRequired {
    let navigationBarTitle: String
}
