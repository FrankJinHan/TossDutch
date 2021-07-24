//
//  DutchViewController.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift
import UIKit

protocol DutchPresentableListener: AnyObject {
    func viewDidLoad()
}

final class DutchViewController: UIViewController, DutchPresentable, DutchViewControllable {

    weak var listener: DutchPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        listener?.viewDidLoad()
    }
    
    func setNavigationBarTitle(_ title: String) {
        self.title = title
    }
}
