//
//  DutchDetailTableViewCell.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/24.
//

import UIKit
import SwiftRichString
import RxCocoa
import RxSwift

enum DutchDetailStatus {
    case completed
    case retry
    case retrying(current: Float)
    case retried
}

protocol DutchDetailTableViewCellViewModelable {
    var nameText: String { get }
    var amountDescription: String { get }
    var messageDescription: String? { get }
    var status: DutchDetailStatus { get }
}

protocol DutchDetailTableViewCellRenderable {
    func render(viewModel: DutchDetailTableViewCellViewModelable)
}

final class DutchDetailTableViewCell: UITableViewCell, DutchDetailTableViewCellRenderable {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
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
        status = viewModel.status
        
        statusButton.rx.tap
            .bind { [weak self] in
                self?.statusButtonTapped()
            }
            .disposed(by: bag)
        
        progressButton.rx.tap
            .bind { [weak self] in
                self?.progressButtonTapped()
            }
            .disposed(by: bag)
    }
    
    private var bag = DisposeBag()
    
    private var status: DutchDetailStatus? {
        didSet {
            switch status {
            case .completed:
                statusButton.setTitleColor(.black, for: .normal)
                statusButton.setTitle("완료", for: .normal)
                statusButton.isUserInteractionEnabled = false
                statusButton.isHidden = false
                progressButton.cancel()
                progressButton.isHidden = true
            case .retry:
                statusButton.setTitleColor(.systemBlue, for: .normal)
                statusButton.setTitle("재요청", for: .normal)
                statusButton.isUserInteractionEnabled = true
                statusButton.isHidden = false
                progressButton.cancel()
                progressButton.isHidden = true
            case let .retrying(current):
                statusButton.isHidden = true
                progressButton.isHidden = false
                progressButton.animate(from: CGFloat(current))
            case .retried:
                statusButton.setTitleColor(.systemBlue, for: .normal)
                statusButton.setTitle("요청함", for: .normal)
                statusButton.isUserInteractionEnabled = true
                statusButton.isHidden = false
                progressButton.cancel()
                progressButton.isHidden = true
            default:
                statusButton.isHidden = true
                progressButton.cancel()
                progressButton.isHidden = true
            }
        }
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
        let stackView = UIStackView(arrangedSubviews: [nameLabel, amountLabel, buttonContainerView])
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
        label.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).cgColor
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
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.addSubview(statusButton)
        view.addSubview(progressButton)
        view.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(30)
            $0.center.equalTo(progressButton)
            $0.edges.equalTo(statusButton)
        }
        return view
    }()
    
    private lazy var statusButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = SystemFonts.AppleSDGothicNeo_Medium.font(size: 16)
        button.setTitle("재전송", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        return button
    }()
    
    private lazy var progressButton: ProgressButton = { [weak self] in
        let button = ProgressButton(color: .systemBlue, radius: 15, duration: 3, completion: {
            self?.requestCompleted()
        })
        button.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        return button
    }()
    
    private func setupViews() {
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.edges.equalTo(contentView).inset(UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20))
        }
        progressButton.isHidden = true
    }
    
    private func statusButtonTapped() {
        switch status {
        case .retrying?:
            status = .retry
        case .retry?:
            status = .retrying(current: 0)
        case .retried?:
            break // TODO : 팝업
        default:
            break
        }
    }
    
    private func progressButtonTapped() {
        switch status {
        case .retrying?:
            status = .retry
        default:
            break
        }
    }
    
    private func requestCompleted() {
        status = .retried
    }
}
