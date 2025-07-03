//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    private var completedTrackers = Set<TrackerRecord>()
    private var currentDate = Date() {
        didSet {
            trackersCollectionView.reloadData()
            checkPlaceholderVisibility()
        }
    }
    
    private let placeholderImageView = UIImageView(image: UIImage(named: "trackerLogo"))
    private let placeholderLabel = UILabel()
    private let searchField = UISearchTextField()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    private let trackersCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupCollectionView()
        //loadSampleData() - тестовый сценарий с уже созданным трекером 
        checkPlaceholderVisibility()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewTrackerNotification(_:)),
            name: NSNotification.Name("NewTrackerCreated"),
            object: nil
        )
    }
    
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        trackersCollectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        trackersCollectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackersCollectionView.backgroundColor = .clear
    }
    
    private func loadSampleData() {
        let tracker = Tracker(
            id: UUID(),
            name: "Поливать растения",
            color: .greenCells,
            emoji: "😪",
            schedule: [.monday, .wednesday, .friday]
        )
        categories = [TrackerCategory(titleCategory: "Домашний уют", trackersArray: [tracker])]
        trackersCollectionView.reloadData()
    }
    
    private func setupUI() {
        [placeholderImageView, placeholderLabel, searchField, trackersCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .black
        searchField.placeholder = "Поиск"
        searchField.borderStyle = .roundedRect
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func checkPlaceholderVisibility() {
        let isEmpty = categories.isEmpty || categories.allSatisfy { $0.trackersArray.isEmpty }
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }
    
    private func isTrackerCompletedToday(_ tracker: Tracker, date: Date) -> Bool {
        completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func completedDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    @objc private func addButtonTapped() {
        let navVC = UINavigationController(rootViewController: TrackerTypeViewController())
        present(navVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(cell: TrackerCollectionViewCell, tracker: Tracker, date: Date, isCompleted: Bool) {
        guard !isFutureDate(date) else { return }
        
        let record = TrackerRecord(id: tracker.id, date: date)
        
        if isCompleted {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        
        trackersCollectionView.reloadData()
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackerCollectionViewCell
        let tracker = categories[indexPath.section].trackersArray[indexPath.row]
        let isCompleted = isTrackerCompletedToday(tracker, date: currentDate)
        let completedDays = completedDaysCount(for: tracker)
        let futureDate = isFutureDate(currentDate)
        
        cell.configure(
            with: tracker,
            selectedDate: currentDate,
            completedDays: completedDays,
            isCompleted: isCompleted,
            isFutureDate: futureDate
        )
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! TrackerSectionHeaderView
        
        header.titleLabel.text = categories[indexPath.section].titleCategory
        return header
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackerViewController {
    @objc private func handleNewTrackerNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let tracker = userInfo["tracker"] as? Tracker {
            let newCategory = TrackerCategory(
                titleCategory: "Новая категория",
                trackersArray: [tracker]
            )
            categories.append(newCategory)
            trackersCollectionView.reloadData()
            checkPlaceholderVisibility()
        }
    }
}
