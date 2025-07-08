//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 08.07.2025.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "colorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        backgroundColor = color
        
        if isSelected {
            layer.borderWidth = 3
            layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
