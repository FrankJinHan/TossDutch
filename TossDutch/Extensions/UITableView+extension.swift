//
//  UITableView+extension.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import UIKit

extension UITableView {
    func dequeue<T: UITableViewCell>(cellClass: T.Type) -> T? {
        dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as? T
    }
    
    func dequeue<T: UITableViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
            fatalError("cannot dequeue")
        }
        return cell
    }
}
