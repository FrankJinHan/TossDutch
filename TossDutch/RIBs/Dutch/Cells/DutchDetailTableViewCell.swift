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
    case retry(isEnabled: Bool)
    case retrying
    case retried(isEnabled: Bool)
}

enum DutchDetailButton {
    case status(DutchDetailStatus), progress(completed: Bool)
}

protocol DutchDetailButtonTappedModeling {
    var dutchId: Int { get }
    var button: DutchDetailButton { get }
}

struct DutchDetailButtonTappedModel: DutchDetailButtonTappedModeling {
    let dutchId: Int
    let button: DutchDetailButton
}

protocol DutchDetailViewStatusCompatible {
    var dutchId: Int { get }
    var nameText: String { get }
    var amountDescription: String { get }
    var messageDescription: String? { get }
    var status: DutchDetailStatus { get }
    var currentRetryProgress: Float? { get }
}

protocol DutchDetailViewModeling {
    var viewStatusObservable: Observable<DutchDetailViewStatusCompatible> { get }
    var buttonTappedSubject: PublishSubject<DutchDetailButton> { get }
}

protocol DutchDetailTableViewCellRenderable {
    func render(viewModel: DutchDetailViewModeling)
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
    
    func render(viewModel: DutchDetailViewModeling) {
        buttonTappedSubject = viewModel.buttonTappedSubject
        let statusObservable = viewModel.viewStatusObservable.map({ $0.status })
        
        let sharedStatusObservable = viewModel.viewStatusObservable
        
        sharedStatusObservable
            .map { $0.nameText }
            .bind(onNext: { [weak self] in
                self?.iconLabel.text = String($0.prefix(1))
                self?.nameLabel.text = $0
            })
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.amountDescription }
            .distinctUntilChanged()
            .bind(to: amountLabel.rx.text)
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.messageDescription }
            .distinctUntilChanged()
            .bind(to: messageLabel.rx.text)
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.messageDescription == nil }
            .distinctUntilChanged()
            .bind(to: messageLabel.rx.isHidden)
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.status.title }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] in
                self?.statusButton.setTitle($0, for: .normal)
            })
            .disposed(by: bag)
            
        sharedStatusObservable
            .map { $0.status.title }
            .distinctUntilChanged()
            .bind(to: statusButton.rx.title(for: .normal))
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.status.isEnabled }
            .distinctUntilChanged()
            .bind(to: statusButton.rx.isEnabled)
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.status.normalTitleColor }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] in
                self?.statusButton.setTitleColor($0, for: .normal)
            })
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.status.disabledTitleColor }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] in
                self?.statusButton.setTitleColor($0, for: .disabled)
            })
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.status.isStatusButtonHidden }
            .bind(onNext: { [weak self] in
                self?.statusButton.isHidden = $0
                self?.progressButton.isHidden = !$0
            })
            .disposed(by: bag)
        
        sharedStatusObservable
            .map { $0.currentRetryProgress }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(onNext: { [weak self] in
                self?.progressButton.animate(from: CGFloat($0))
            })
            .disposed(by: bag)
        
        statusButton.rx.tap
            .withLatestFrom(statusObservable) { $1 }
            .map { DutchDetailButton.status($0) }
            .bind(to: viewModel.buttonTappedSubject)
            .disposed(by: bag)
        
        progressButton.rx.tap
            .map { DutchDetailButton.progress(completed: false) }
            .bind(to: viewModel.buttonTappedSubject)
            .disposed(by: bag)
    }
    
    private var bag = DisposeBag()
    
    private var buttonTappedClosure: (() -> Void)?
    
    private var progressButtonTappedClosure: (() -> Void)?
    
    private var buttonTappedSubject: PublishSubject<DutchDetailButton>?
    
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
        button.setTitleColor(.lightGray, for: .disabled)
        button.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        return button
    }()
    
    private lazy var progressButton: ProgressButton = { [weak self] in
        let button = ProgressButton(color: .systemBlue, radius: 15, duration: CGFloat(GlobalConstant.dutchRetryDuration), completion: {
            self?.buttonTappedSubject?.onNext(.progress(completed: true))
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
}

private extension DutchDetailStatus {
    var canChangeEnabledStatus: Bool {
        switch self {
        case .retry, .retried: return true
        default: return false
        }
    }
}

private extension DutchDetailStatus {
    var title: String {
        switch self {
        case .completed:
            return "완료"
        case .retry:
            return "재요청"
        case .retrying:
            return ""
        case .retried:
            return "요청함"
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .completed:
            return false
        case let .retry(isEnabled):
            return isEnabled
        case .retrying:
            return false
        case let .retried(isEnabled):
            return isEnabled
        }
    }
    
    var normalTitleColor: UIColor {
        switch self {
        case .completed:
            return .black
        case .retry:
            return .systemBlue
        case .retrying:
            return .clear
        case .retried:
            return .systemBlue
        }
    }
    
    var disabledTitleColor: UIColor {
        switch self {
        case .completed:
            return .black
        case .retry:
            return .lightGray
        case .retrying:
            return .clear
        case .retried:
            return .lightGray
        }
    }
    
    var isStatusButtonHidden: Bool {
        switch self {
        case .completed:
            return false
        case .retry:
            return false
        case .retrying:
            return true
        case .retried:
            return false
        }
    }
}
