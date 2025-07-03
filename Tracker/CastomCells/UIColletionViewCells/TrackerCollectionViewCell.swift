//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 30.06.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(cell: TrackerCollectionViewCell, tracker: Tracker, date: Date, isCompleted: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    private var countDays: Int = 0
    private let containerView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysCountLabel = UILabel()
    private let plusButton = UIButton()
    private let footerStackView = UIStackView()
    
    weak var delegate: TrackerCellDelegate?
    private var tracker: Tracker?
    private var selectedDate: Date?
    private var isCompleted: Bool = false
    private var isFutureDate: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        with tracker: Tracker,
        selectedDate: Date,
        completedDays: Int,
        isCompleted: Bool,
        isFutureDate: Bool
    ) {
        self.tracker = tracker
        self.selectedDate = selectedDate
        self.isCompleted = isCompleted
        self.isFutureDate = isFutureDate
        self.countDays = completedDays
        
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        containerView.backgroundColor = tracker.color
        daysCountLabel.text = "\(countDays) дней"
        
        if isCompleted {
            plusButton.setImage(UIImage(named: "done"), for: .normal)
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        plusButton.tintColor = .white
        plusButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
        plusButton.isUserInteractionEnabled = !isFutureDate
    }
    
    private func setupViews() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 16)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 2
        
        daysCountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysCountLabel.textColor = .black
        
        plusButton.layer.cornerRadius = 17
        plusButton.clipsToBounds = true
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        footerStackView.axis = .horizontal
        footerStackView.distribution = .fill
        footerStackView.alignment = .center
        footerStackView.spacing = 8
        
        [containerView, emojiLabel, titleLabel, footerStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        contentView.addSubview(footerStackView)
        
        footerStackView.addArrangedSubview(daysCountLabel)
        footerStackView.addArrangedSubview(UIView())
        footerStackView.addArrangedSubview(plusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            containerView.widthAnchor.constraint(equalToConstant: 167),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            footerStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            footerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            footerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            footerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func plusButtonTapped() {
        guard let tracker = tracker,
              let selectedDate = selectedDate,
              !isFutureDate else {
            return
        }
        delegate?.didTapPlusButton(cell: self, tracker: tracker, date: selectedDate, isCompleted: isCompleted)
    }
}
