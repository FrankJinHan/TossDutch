//
//  DutchDetailTableViewCell.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import UIKit
import SwiftRichString

protocol DutchDetailTableViewCellViewModelable {
    var nameText: String { get }
    var amountDescription: String { get }
    var messageDescription: String? { get }
}

protocol DutchDetailTableViewCellRenderable {
    func render(viewModel: DutchDetailTableViewCellViewModelable)
}

final class DutchDetailTableViewCell: UITableViewCell, DutchDetailTableViewCellRenderable {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(viewModel: DutchDetailTableViewCellViewModelable) {
        iconLabel.text = String(viewModel.nameText.prefix(1))
        nameLabel.text = viewModel.nameText
        amountLabel.text = viewModel.amountDescription
        messageLabel.text = viewModel.messageDescription
        messageLabel.isHidden = viewModel.messageDescription == nil
    }
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconLabel, contentsStackView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var contentsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [infoStackView, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, amountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        label.layer.cornerRadius = 20
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        label.textAlignment = .center
        label.font = SystemFonts.AppleSDGothicNeo_Regular.font(size: 17)
        label.textColor = .systemBlue
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Light.font(size: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.snp.contentHuggingHorizontalPriority = 700
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Medium.font(size: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = SystemFonts.AppleSDGothicNeo_Regular.font(size: 14)
        label.textColor = .gray
        return label
    }()
    
    private func setupViews() {
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.edges.equalTo(contentView).inset(UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20))
        }
    }
}
