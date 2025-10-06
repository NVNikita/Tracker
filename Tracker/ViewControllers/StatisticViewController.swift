//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImageView = UIImageView()
        let image = UIImage(named: "statisticImageView")
        placeholderImageView.image = image
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statictic.placeholder.title",
                                       comment: "Statistic placeholder statistickVC")
        label.textColor = UIColor.tintStringColor
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var statisticCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private let titleBestTime = "Лучший период"
    private let perfectcDays = "Идеальные дни"
    private let trackersCompleted = "Трекеров завершено"
    private let averageValue = "Среднее значение"
    
    private lazy var titleCells: [String] = [titleBestTime, perfectcDays, trackersCompleted, averageValue]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        activateConsraints()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("statistic.nav.title", comment: "Title statisticVC nav")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        statisticCollectionView.register(StatisticCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        statisticCollectionView.delegate = self
        statisticCollectionView.dataSource = self
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.backgroundViewColor
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(statisticCollectionView)
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        statisticCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func activateConsraints() {
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 375),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            statisticCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statisticCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            statisticCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


extension StatisticViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StatisticCollectionViewCell
        cell.titleLabel.text = titleCells[indexPath.row]
        cell.countLabel.text = "9"
        return cell
    }
}

extension StatisticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 343, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
