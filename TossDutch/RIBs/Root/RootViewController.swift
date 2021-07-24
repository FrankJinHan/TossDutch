//
//  RootViewController.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import SwiftRichString
import RxCocoa

protocol RootPresentableListener: AnyObject {
    func dutchButtonTapped()
}

final class RootViewController: UIViewController, RootPresentable, RootViewControllable {

    weak var listener: RootPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupViews()
        bindViews()
    }
    
    // MARK: - RootViewControllable
    
    func presentNavigation(rootViewController: ViewControllable) {
        let navigationController = UINavigationController(rootViewController: rootViewController.uiviewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func dismiss(viewController: ViewControllable) {
        viewController.uiviewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Privates
    
    private lazy var tossDutchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더치페이", for: .normal)
        button.titleLabel?.font = SystemFonts.AppleSDGothicNeo_Bold.font(size: 24)
        return button
    }()
    
    private let bag = DisposeBag()
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(tossDutchButton)
        tossDutchButton.snp.makeConstraints {
            $0.center.equalTo(view)
        }
    }
    
    private func bindViews() {
        tossDutchButton.rx.tap
            .bind { [weak listener] in
                listener?.dutchButtonTapped()
            }
            .disposed(by: bag)
    }
}
