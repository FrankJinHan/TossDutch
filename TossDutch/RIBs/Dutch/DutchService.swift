//
//  DutchService.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RxSwift

protocol DutchService {
    func requestDutchData() -> Single<DutchData>
}
