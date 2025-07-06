//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Никита Нагорный on 06.07.2025.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiString = UILabel()
    private let emojiArray = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
