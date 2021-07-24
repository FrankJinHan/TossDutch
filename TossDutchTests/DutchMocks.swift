//
//  DutchMocks.swift
//  TossDutchTests
//
//  Created by Frank Jin Han on 2021/07/25.
//

@testable import TossDutch
import RxSwift
import Foundation

final class DutchPresenterMock: DutchPresentable {
    var listener: DutchPresentableListener?
    
    func setNavigationBarTitle(_ title: String) {
        
    }
    
    func reload(sections: [DutchSectionModel]) {
        sectionsRelay.onNext(sections)
    }
    
    func showPopup(title: String) {
        
    }
    
    let sectionsRelay = ReplaySubject<[DutchSectionModel]>.createUnbounded()
}

final class DutchServiceMock: DutchService {
    enum DutchServiceError: Error {
        case findPathFailed
    }
    
    func requestDutchData() -> Single<DutchData> {
        .create { observer in
            if let path = Bundle.main.path(forResource: "sample", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let result = try JSONDecoder().decode(DutchData.self, from: data)
                    observer(.success(result))
                } catch {
                    observer(.failure(error))
                }
            } else {
                observer(.failure(DutchServiceError.findPathFailed))
            }
            return Disposables.create()
        }
    }
}

final class DutchListenerMock: DutchListener {
    func closeDutch() {
        
    }
}
