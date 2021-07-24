//
//  DutchViewController.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import RIBs
import RxSwift
import UIKit
import RxDataSources

protocol DutchPresentableListener: AnyObject {
    func viewDidLoad()
    func close()
}

final class DutchViewController: UIViewController, DutchPresentable, DutchViewControllable {

    weak var listener: DutchPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        let sections: [DutchSectionModel] = [
            .summary(items: [.summary(model: DutchSummaryModel(ownerName: "김철수", message: "💸💸👍👍👻👻👻 우리 오늘 모임 즐거웠다~~~ 돈 다 나에게도 주즈아~~", ownerAmount: 32500, completedAmount: 308000, totalAmount: 380000, date: "2019-04-06T00:44:16+0000"))]),
            .detail(items: [.detail(model: DutchDetailModel(dutchId: 1, name: "김진규", amount: 32500, transferMessage: "🔫🔫🔫", isDone: true))])
        ]
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        listener?.viewDidLoad()
    }
    
    func setNavigationBarTitle(_ title: String) {
        self.title = title
    }
    
    private let tableView = UITableView()
    
    private let bag = DisposeBag()
}

private extension DutchViewController {
    var dataSource: RxTableViewSectionedReloadDataSource<DutchSectionModel> {
        RxTableViewSectionedReloadDataSource<DutchSectionModel>(
            configureCell: { dataSource, table, idxPath, _ in
                switch dataSource[idxPath] {
                case let .summary(model):
                    let cell = UITableViewCell()
                    cell.textLabel?.text = model.ownerName
                    return cell
                case let .detail(model):
                    let cell = UITableViewCell()
                    cell.textLabel?.text = model.name
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                nil
            }
        )
    }
}
