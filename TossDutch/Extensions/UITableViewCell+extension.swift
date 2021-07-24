//
//  UITableViewCell+extension.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import UIKit

protocol TableViewCellReusable {
    static var reuseIdentifier: String { get }
}

extension TableViewCellReusable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UITableViewCell: TableViewCellReusable {}
