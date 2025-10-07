//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            trackersCollectionView.reloadData()
            checkPlaceholderVisibility()
        }
    }
    
    private var currentFilter: DataManager.Filter = .all {
        didSet {
            DataManager.shared.setCurrentFilter(currentFilter)
            updateFilterButtonAppearance()
            loadData()
        }
    }
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var currentDate = Date() {
        didSet {
            loadData()
        }
    }
    
    private let dataManager = DataManager.shared
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
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("trackers.buttonFilter.title",
                                          comment: "Title button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundViewColor
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupCollectionView()
        
        currentFilter = DataManager.shared.getCurrentFilter()
        if currentFilter == .today {
            datePicker.date = Date()
            currentDate = Date()
        }
        
        loadData()
        
        DataManager.shared.delegate = self
        
        updateFilterButtonAppearance()
        
        if currentFilter == .today {
            datePicker.date = Date()
            currentDate = Date()
        }
    }
    
    private func loadData() {
        categories = dataManager.fetchCategories()
        completedTrackers = Set(dataManager.fetchRecords())
        trackersCollectionView.reloadData()
        checkPlaceholderVisibility()
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("trackers.nav.title", comment: "Title trackerVC")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = UIColor.tintStringColor
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func filterTrackers(for date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        let currentWeekday: Tracker.Weekday?
        switch weekdayNumber {
        case 2: currentWeekday = .monday
        case 3: currentWeekday = .tuesday
        case 4: currentWeekday = .wednesday
        case 5: currentWeekday = .thursday
        case 6: currentWeekday = .friday
        case 7: currentWeekday = .saturday
        case 1: currentWeekday = .sunday
        default: currentWeekday = nil
        }
        
        let scheduleFilteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackersArray.filter { tracker in
                guard let schedule = tracker.schedule, !schedule.isEmpty else { return true }
                return currentWeekday != nil && schedule.contains { $0 == currentWeekday }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                titleCategory: category.titleCategory,
                trackersArray: filteredTrackers
            )
        }
        
        return applyAdditionalFilters(to: scheduleFilteredCategories, date: date)
    }
    
    private func applyAdditionalFilters(to categories: [TrackerCategory], date: Date) -> [TrackerCategory] {
        switch currentFilter {
        case .all, .today:
            return categories
            
        case .completed:
            return categories.compactMap { category in
                let completedTrackers = category.trackersArray.filter { tracker in
                    DataManager.shared.isTrackerCompleted(tracker, on: date)
                }
                return completedTrackers.isEmpty ? nil : TrackerCategory(
                    titleCategory: category.titleCategory,
                    trackersArray: completedTrackers
                )
            }
            
        case .uncompleted:
            return categories.compactMap { category in
                let uncompletedTrackers = category.trackersArray.filter { tracker in
                    !DataManager.shared.isTrackerCompleted(tracker, on: date)
                }
                return uncompletedTrackers.isEmpty ? nil : TrackerCategory(
                    titleCategory: category.titleCategory,
                    trackersArray: uncompletedTrackers
                )
            }
        }
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
        
        trackersCollectionView.alwaysBounceVertical = true
        trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    private func setupUI() {
        [placeholderImageView, placeholderLabel, searchField, trackersCollectionView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderLabel.text = NSLocalizedString("trackers.empty.title", comment: "Placeholder title trackerVC")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = UIColor.tintStringColor
        searchField.placeholder = NSLocalizedString("trackers.search.placeholder", comment: "Placeholder search trackerVC")
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
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 131),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func checkPlaceholderVisibility() {
        let filteredCategories = filterTrackers(for: currentDate)
        let allTrackersForDate = getTrackersForDateWithoutFilters(currentDate)
        let hasTrackersForDate = !allTrackersForDate.isEmpty
        let hasFilteredTrackers = !filteredCategories.isEmpty
        
        if !hasFilteredTrackers {
            if !hasTrackersForDate {
                placeholderImageView.image = UIImage(named: "trackerLogo")
                placeholderLabel.text = NSLocalizedString("trackers.empty.title", comment: "Placeholder title trackerVC")
            } else {
                placeholderImageView.image = UIImage(named: "emptySearch")
                placeholderLabel.text = NSLocalizedString("trackers.empty.search", comment: "Nothing found")
            }
        }
        
        placeholderImageView.isHidden = hasFilteredTrackers
        placeholderLabel.isHidden = hasFilteredTrackers
        trackersCollectionView.isHidden = !hasFilteredTrackers
        
        filterButton.isHidden = !hasTrackersForDate
    }
    
    private func getTrackersForDateWithoutFilters(_ date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        let currentWeekday: Tracker.Weekday?
        switch weekdayNumber {
        case 2: currentWeekday = .monday
        case 3: currentWeekday = .tuesday
        case 4: currentWeekday = .wednesday
        case 5: currentWeekday = .thursday
        case 6: currentWeekday = .friday
        case 7: currentWeekday = .saturday
        case 1: currentWeekday = .sunday
        default: currentWeekday = nil
        }
        
        return categories.compactMap { category in
            let trackersForDate = category.trackersArray.filter { tracker in
                guard let schedule = tracker.schedule, !schedule.isEmpty else { return true }
                return currentWeekday != nil && schedule.contains { $0 == currentWeekday }
            }
            return trackersForDate.isEmpty ? nil : TrackerCategory(
                titleCategory: category.titleCategory,
                trackersArray: trackersForDate
            )
        }
    }
    
    private func isTrackerCompletedToday(_ tracker: Tracker, date: Date) -> Bool {
        return dataManager.isTrackerCompleted(tracker, on: date)
    }
    
    private func completedDaysCount(for tracker: Tracker) -> Int {
        return dataManager.completedDaysCount(for: tracker)
    }
    
    private func updateFilterButtonAppearance() {
        let isFilterActive = currentFilter != .all && currentFilter != .today
        let titleColor = isFilterActive ? UIColor.redYP : UIColor.white
        filterButton.setTitleColor(titleColor, for: .normal)
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    @objc private func addButtonTapped() {
        let navVC = UINavigationController(rootViewController: TrackerTypeViewController())
        present(navVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FiltersViewController(currentFilter: currentFilter)
        filterVC.onFilterSelected = { [weak self] selectedFilter in
            self?.currentFilter = selectedFilter
            
            if selectedFilter == .today {
                self?.datePicker.date = Date()
                self?.currentDate = Date()
            }
        }
        
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    @objc private func handleNewTrackerNotification(_ notification: Notification) {
        loadData()
    }
    
    @objc private func handleDataChangeNotification(_ notification: Notification) {
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(cell: TrackerCollectionViewCell, tracker: Tracker, date: Date, isCompleted: Bool) {
        guard !isFutureDate(date) else { return }
        
        dataManager.toggleTrackerCompletion(tracker, on: date)
        loadData()
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filterTrackers(for: currentDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterTrackers(for: currentDate)[section].trackersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackerCollectionViewCell
        let filteredCategories = filterTrackers(for: currentDate)
        let tracker = filteredCategories[indexPath.section].trackersArray[indexPath.row]
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
        
        header.titleLabel.text = filterTrackers(for: currentDate)[indexPath.section].titleCategory
        header.titleLabel.textColor = UIColor.tintStringColor
        return header
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filterTrackers(for: currentDate)[indexPath.section].trackersArray[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            return nil
        }) { [weak self] _ in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("trackers.menu.edit", comment: "")) { _ in
                    self?.editTracker(tracker)
                },
                UIAction(title: NSLocalizedString("trackers.menu.delete", comment: ""), attributes: .destructive) { _ in
                    self?.deleteTracker(tracker)
                }
            ])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        
        let path = UIBezierPath(roundedRect: cell.containerView.bounds, cornerRadius: 16)
        parameters.visiblePath = path
        
        let preview = UITargetedPreview(view: cell.containerView, parameters: parameters)
        return preview
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return self.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration)
    }
    
    private func editTracker(_ tracker: Tracker) {
        let category = categories.first { category in
            category.trackersArray.contains { $0.id == tracker.id }
        }
        
        guard let categoryTitle = category?.titleCategory else { return }
        
        let editVC = CreatingTrackersViewController(tracker: tracker, category: categoryTitle)
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("trackers.alert.title", comment: ""),
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("trackers.alert.buttonDelete", comment: ""), style: .destructive) { [weak self] _ in
            self?.dataManager.deleteTracker(tracker)
            self?.loadData()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("trackers.alert.buttonCancel", comment: ""), style: .cancel))
        
        present(alert, animated: true)
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

extension TrackerViewController: DataManagerDelegate {
    func didUpdateTrackers(_ changes: [DataManagerChange]) {
        loadData()
    }
    
    func didUpdateCategories(_ changes: [DataManagerChange]) {
        loadData()
    }
    
    func didUpdateRecords(_ changes: [DataManagerChange]) {
        trackersCollectionView.reloadData()
    }
}
