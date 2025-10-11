//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private let statisticService = StatisticService()
    
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let titleBestTime = NSLocalizedString("statistic.titleBestTime.title",
                                                 comment: "Title cell statisticVC")
    private let perfectcDays = NSLocalizedString("statistic.perfectcDays.title",
                                                 comment: "Title cell perfectDays statisticVC")
    private let trackersCompleted = NSLocalizedString("statistic.trackersCompleted.title",
                                                 comment: "Title cell trackerCompleted statisticVC")
    private let averageValue = NSLocalizedString("statistic.averageValue.title",
                                                 comment: "Title cell averageValue statisticVC")
    
    private lazy var titleCells: [String] = [titleBestTime, perfectcDays, trackersCompleted, averageValue]
    
    private var statisticValues: [Int] = [0, 0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        activateConsraints()
        setupCollectionView()
        updateStatistics()
        
        DataManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
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
        
        updateUI()
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
    
    private func updateStatistics() {
        statisticValues = [
            statisticService.getBestPeriod(),
            statisticService.getPerfectDays(),
            statisticService.getCompletedTrackers(),
            statisticService.getAverageValue()
        ]
        
        updateUI()
        statisticCollectionView.reloadData()
    }
    
    private func updateUI() {
        let hasData = statisticService.hasStatisticsData()
        placeholderImageView.isHidden = hasData
        placeholderLabel.isHidden = hasData
        statisticCollectionView.isHidden = !hasData
    }
}

extension StatisticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StatisticCollectionViewCell
        cell.titleLabel.text = titleCells[indexPath.row]
        cell.countLabel.text = "\(statisticValues[indexPath.row])"
        return cell
    }
}

extension StatisticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

extension StatisticViewController: DataManagerDelegate {
    func didUpdateTrackers(_ changes: [DataManagerChange]) {
        updateStatistics()
    }
    
    func didUpdateCategories(_ changes: [DataManagerChange]) {
        updateStatistics()
    }
    
    func didUpdateRecords(_ changes: [DataManagerChange]) {
        updateStatistics()
    }
}
