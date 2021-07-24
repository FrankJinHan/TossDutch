//
//  DutchTableViewCells.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import UIKit
import SwiftRichString

protocol DutchSummaryTableViewCellViewModelable {
    var dateDescription: String { get }
    var amountDescription: String { get }
    var messageDescription: String { get }
}

protocol DutchSummaryTableViewCellRenderable {
    func render(viewModel: DutchSummaryTableViewCellViewModelable)
}

final class DutchSummaryTableViewCell: UITableViewCell, DutchSummaryTableViewCellRenderable {
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(viewModel: DutchSummaryTableViewCellViewModelable) {
        dateLabel.text = viewModel.dateDescription
        amountLabel.text = viewModel.amountDescription
        messageLabel.text = viewModel.messageDescription
    }
    
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, amountLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [innerStackView, messageLabelContainerView])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Medium.font(size: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Regular.font(size: 14)
        label.textColor = .gray
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Regular.font(size: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabelContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        return view
    }()
    
    private func setupViews() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(contentView).inset(UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20))
        }
        
        messageLabelContainerView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.edges.equalTo(messageLabelContainerView).inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints {
            $0.bottom.equalTo(contentView)
            $0.leading.equalTo(contentView)
            $0.trailing.equalTo(contentView)
            $0.height.equalTo(0.5)
        }
    }
}
