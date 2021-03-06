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
import RxRelay

protocol DutchPresentableListener: AnyObject {
    func viewDidLoad()
    func close()
    func refresh()
    func setEnabled()
}

final class DutchViewController: UIViewController, DutchPresentable, DutchViewControllable {

    weak var listener: DutchPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTableView()
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak listener] in
                listener?.refresh()
            }
            .disposed(by: bag)
        
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        listener?.viewDidLoad()
    }
    
    func setNavigationBarTitle(_ title: String) {
        self.title = title
    }
    
    func reload(sections: [DutchSectionModel]) {
        tableView.refreshControl?.endRefreshing()
        self.sections.onNext(sections)
    }
    
    func showPopup(title: String) {
        tableView.refreshControl?.endRefreshing()
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { [weak alertController, weak listener] _ in
            listener?.setEnabled()
            alertController?.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private let tableView = UITableView()
    
    private let bag = DisposeBag()
    
    private var sections = PublishSubject<[DutchSectionModel]>()
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(DutchSummaryTableViewCell.self, forCellReuseIdentifier: DutchSummaryTableViewCell.reuseIdentifier)
        tableView.register(DutchDetailTableViewCell.self, forCellReuseIdentifier: DutchDetailTableViewCell.reuseIdentifier)
    }
}

private extension DutchViewController {
    var dataSource: RxTableViewSectionedReloadDataSource<DutchSectionModel> {
        RxTableViewSectionedReloadDataSource<DutchSectionModel>(
            configureCell: { dataSource, tableView, indexPath, _ in
                switch dataSource[indexPath] {
                case let .summary(model):
                    let cell = tableView.dequeue(cellClass: DutchSummaryTableViewCell.self, forIndexPath: indexPath)
                    cell.render(viewModel: model)
                    return cell
                case let .detail(model):
                    let cell = tableView.dequeue(cellClass: DutchDetailTableViewCell.self, forIndexPath: indexPath)
                    cell.render(viewModel: model)
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                nil
            }
        )
    }
}
