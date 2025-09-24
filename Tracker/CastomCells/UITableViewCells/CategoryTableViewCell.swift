//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 15.09.2025.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .black
        return title
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func activateUI() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.accessoryType = .none
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
