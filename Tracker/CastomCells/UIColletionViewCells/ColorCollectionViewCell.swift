//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 06.07.2025.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "colorCell"
    
    let rectangle = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
        contentView.addSubview(rectangle)
        rectangle.translatesAutoresizingMaskIntoConstraints = false
        
        rectangle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        rectangle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        rectangle.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rectangle.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {

        rectangle.layer.cornerRadius = 8
        rectangle.layer.masksToBounds = true
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        rectangle.backgroundColor = color
        
        if isSelected {
            layer.borderWidth = 3
            layer.cornerRadius = 8
            layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
