//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 05.06.2025.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    private let dayLabel = UILabel()
    private let daySwitch = UISwitch()
    var onSwitchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        activateConstaints()
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private func setupUI() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        daySwitch.onTintColor = .blue
        daySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    private func activateConstaints() {
        dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    func configure(with day: String, isSelected: Bool) {
        dayLabel.text = day
        daySwitch.isOn = isSelected
    }
    
    @objc private func switchValueChanged() {
        onSwitchChanged?(daySwitch.isOn)
    }
}
