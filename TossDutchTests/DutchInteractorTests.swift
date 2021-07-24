//
//  DutchInteractorTests.swift
//  TossDutchTests
//
//  Created by Frank Jin Han on 2021/07/25.
//

@testable import TossDutch
import XCTest
import RxBlocking
import RxSwift

final class DutchInteractorTests: XCTestCase {

    private var interactor: DutchInteractor!
    private var presenter: DutchPresenterMock!
    
    private let bag = DisposeBag()

    override func setUp() {
        super.setUp()

        presenter = DutchPresenterMock()
        let requirement = DutchRequirement(navigationBarTitle: "더치페이")
        let service = DutchServiceMock()
        let listener = DutchListenerMock()
        interactor = DutchInteractor(presenter: presenter, requirement: requirement, service: service)
        interactor.listener = listener
        interactor.activate()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        
        presenter.listener?.viewDidLoad()
        
        do {
            let result = try presenter.sectionsRelay.toBlocking(timeout: 10).first()
            
            XCTAssertEqual(result?.count, 2)
        } catch {
            
        }
    }
}
