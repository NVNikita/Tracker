//
//  CreatingTrackersViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 03.06.2025.
//

import UIKit

final class CreatingTrackersViewController: UIViewController {
    
    private var mode: Mode = .create
    private var trackerToEdit: Tracker?
    private var categoryToEdit: String?
    
    enum Mode {
        case create
        case edit
    }
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private lazy var actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.setTitleColor(UIColor.white, for: .disabled)
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        actionButton.backgroundColor = .grayButton
        actionButton.layer.cornerRadius = 16
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.isEnabled = false
        return actionButton
    }()
    private let cancelButton = UIButton(type: .system)
    private let topTableView = UITableView()
    private let bottomTableView = UITableView()
    private var selectedDays: Set<String> = []
    private var selectedCategory: String? = nil
    private let categories = [NSLocalizedString("creatingtrackers.cell.category", comment: "Text for category cell"),
                              NSLocalizedString("creatingtrackers.cell.schedule", comment: "Text for schedule cell")]
    private let emojiArray = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                              "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colorsCells: [UIColor] = [.redYP, .lightOrangeYP, .blueYP, .purpleYP, .greenYP, .darkPinkYP,
                                          .lightPinkYP, .lightBlueYP, .lightGreenYP, .darkBlueYP, .orangeYP, .pinkYP,
                                          .beigeYP, .coralBlueYP, .darkPurpleYP, .fuchsiaYP, .lightPurpleYP, .emeraldYP]
    private let emojiCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
    private let colorsCollectionsView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout())
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.tintStringColor
        label.textAlignment = .center
        label.text = "0 дней"
        label.isHidden = true
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    convenience init(tracker: Tracker, category: String) {
        self.init()
        self.mode = .edit
        self.trackerToEdit = tracker
        self.categoryToEdit = category
        self.selectedCategory = category
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        activateUI()
        setupConstaints()
        setupTables()
        setupKeyboardDismissal()
        setupCollections()
        
        if mode == .edit {
            fillExistingData()
        }
        
        updateActionButtonState()
    }
    
    private func setupNavBar() {
        switch mode {
        case .create:
            title = NSLocalizedString("creatingtrackers.nav.title", comment: "Title CreatingVC")
            
        case .edit:
            title = NSLocalizedString("creatingtrackers.title.editHabbit", comment: "Title CreatingVC")

        }
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.tintStringColor
        ]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func activateUI() {
        view.backgroundColor = UIColor.backgroundViewColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        if mode == .edit {
            contentView.addSubview(daysCountLabel)
            daysCountLabel.isHidden = false
        }
        
        contentView.addSubview(topTableView)
        contentView.addSubview(bottomTableView)
        contentView.addSubview(actionButton)
        contentView.addSubview(cancelButton)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorsCollectionsView)
        
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        topTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionsView.translatesAutoresizingMaskIntoConstraints = false
        
        switch mode {
        case .create:
            actionButton.setTitle(NSLocalizedString("creatingtrackers.button.create",
                                                    comment: "Text creating button"), for: .normal)
        case .edit:
            actionButton.setTitle(NSLocalizedString("creatingtrackers.title.editHabbit.button",
                                                    comment: "Text creating button"), for: .normal)
        }
        
        cancelButton.setTitle(NSLocalizedString("creatingtrackers.button.cancel",
                                                comment: "Text cancel button"), for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .backgroundViewColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.redYP.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func fillExistingData() {
        guard let tracker = trackerToEdit else { return }
        
        DispatchQueue.main.async {
            if let cell = self.topTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell {
                cell.textField.text = tracker.name
            }
        }
        
        if let schedule = tracker.schedule {
            selectedDays = Set(schedule.map { weekday in
                switch weekday {
                case .monday:
                    return NSLocalizedString("schedule.day.monday", comment: "")
                case .tuesday:
                    return NSLocalizedString("schedule.day.tuesday", comment: "")
                case .wednesday:
                    return NSLocalizedString("schedule.day.wednesday", comment: "")
                case .thursday:
                    return NSLocalizedString("schedule.day.thursday", comment: "")
                case .friday:
                    return NSLocalizedString("schedule.day.friday", comment: "")
                case .saturday:
                    return NSLocalizedString("schedule.day.saturday", comment: "")
                case .sunday:
                    return NSLocalizedString("schedule.day.sunday", comment: "")
                }
            })
        }
        
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        
        updateDaysCount(for: tracker)
        
        DispatchQueue.main.async {
            self.bottomTableView.reloadData()
            self.emojiCollectionView.reloadData()
            self.colorsCollectionsView.reloadData()
            self.updateActionButtonState()
        }
    }
    
    private func updateDaysCount(for tracker: Tracker) {
        let completedDays = DataManager.shared.completedDaysCount(for: tracker)
        
        daysCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "Number of completed days"),
            completedDays
        )
    }
    
    private func setupTables() {
        topTableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        bottomTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        topTableView.isScrollEnabled = false
        bottomTableView.isScrollEnabled = false
        
        topTableView.separatorStyle = .none
        bottomTableView.separatorStyle = .singleLine
        bottomTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        topTableView.delegate = self
        topTableView.dataSource = self
        bottomTableView.delegate = self
        bottomTableView.dataSource = self
        
        topTableView.backgroundColor = .backgroundTables
        bottomTableView.backgroundColor = .backgroundTables
        topTableView.layer.cornerRadius = 16
        bottomTableView.layer.cornerRadius = 16
        topTableView.layer.masksToBounds = true
        bottomTableView.layer.masksToBounds = true
    }
    
    private func setupCollections() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorsCollectionsView.delegate = self
        colorsCollectionsView.dataSource = self
        
        emojiCollectionView.allowsMultipleSelection = false
        colorsCollectionsView.allowsMultipleSelection = false
        
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        colorsCollectionsView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        emojiCollectionView.register(
            CreatingCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        
        colorsCollectionsView.register(
            CreatingCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }
    
    private func setupConstaints() {
        var constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ]
        
        if mode == .edit {
            constraints.append(contentsOf: [
                daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                daysCountLabel.heightAnchor.constraint(equalToConstant: 38),
                
                topTableView.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 24),
            ])
        } else {
            constraints.append(contentsOf: [
                topTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            ])
        }
        
        constraints.append(contentsOf: [
            topTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topTableView.heightAnchor.constraint(equalToConstant: 75),
            
            bottomTableView.topAnchor.constraint(equalTo: topTableView.bottomAnchor, constant: 24),
            bottomTableView.leadingAnchor.constraint(equalTo: topTableView.leadingAnchor),
            bottomTableView.trailingAnchor.constraint(equalTo: topTableView.trailingAnchor),
            bottomTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.topAnchor.constraint(equalTo: bottomTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollectionsView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorsCollectionsView.leadingAnchor.constraint(equalTo: emojiCollectionView.leadingAnchor),
            colorsCollectionsView.trailingAnchor.constraint(equalTo: emojiCollectionView.trailingAnchor),
            colorsCollectionsView.heightAnchor.constraint(equalToConstant: 204),
            
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionsView.bottomAnchor, constant: 32),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            actionButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            actionButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func getShortDaysString() -> String {
        if selectedDays.count == 7 {
            return NSLocalizedString("creating.tracker.daily", comment: "Text for every day")
        } else if selectedDays.isEmpty {
            return ""
        } else {
            let shortDays = selectedDays.map { day in
                switch day {
                case NSLocalizedString("schedule.day.monday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.mon", comment: "")
                case NSLocalizedString("schedule.day.tuesday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.tue", comment: "")
                case NSLocalizedString("schedule.day.wednesday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.wed", comment: "")
                case NSLocalizedString("schedule.day.thursday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.thu", comment: "")
                case NSLocalizedString("schedule.day.friday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.fri", comment: "")
                case NSLocalizedString("schedule.day.saturday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.sat", comment: "")
                case NSLocalizedString("schedule.day.sunday", comment: ""):
                    return NSLocalizedString("creating.tracker.day.sun", comment: "")
                default: return ""
                }
            }.sorted { first, second in
                let order = [
                    NSLocalizedString("creating.tracker.day.mon", comment: ""),
                    NSLocalizedString("creating.tracker.day.tue", comment: ""),
                    NSLocalizedString("creating.tracker.day.wed", comment: ""),
                    NSLocalizedString("creating.tracker.day.thu", comment: ""),
                    NSLocalizedString("creating.tracker.day.fri", comment: ""),
                    NSLocalizedString("creating.tracker.day.sat", comment: ""),
                    NSLocalizedString("creating.tracker.day.sun", comment: "")
                ]
                return order.firstIndex(of: first) ?? 0 < order.firstIndex(of: second) ?? 0
            }
            
            return shortDays.joined(separator: ", ")
        }
    }
    
    private func convertDaysToWeekdays() -> [Tracker.Weekday] {
        var weekdays: [Tracker.Weekday] = []
        
        for day in selectedDays {
            switch day {
            case NSLocalizedString("schedule.day.monday", comment: ""):
                weekdays.append(.monday)
            case NSLocalizedString("schedule.day.tuesday", comment: ""):
                weekdays.append(.tuesday)
            case NSLocalizedString("schedule.day.wednesday", comment: ""):
                weekdays.append(.wednesday)
            case NSLocalizedString("schedule.day.thursday", comment: ""):
                weekdays.append(.thursday)
            case NSLocalizedString("schedule.day.friday", comment: ""):
                weekdays.append(.friday)
            case NSLocalizedString("schedule.day.saturday", comment: ""):
                weekdays.append(.saturday)
            case NSLocalizedString("schedule.day.sunday", comment: ""):
                weekdays.append(.sunday)
            default: break
            }
        }
        
        return weekdays
    }
    
    private func updateActionButtonState() {
        let isFormValid = isFormComplete()
        actionButton.isEnabled = isFormValid
        actionButton.backgroundColor = isFormValid ? UIColor.backgroundButtonColor : .grayButton
        actionButton.setTitleColor(.buttonTextColor, for: .normal)
    }
    
    private func isFormComplete() -> Bool {
        guard let cell = topTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
              let trackerName = cell.textField.text?.trimmingCharacters(in: .whitespaces),
              !trackerName.isEmpty else {
            return false
        }
        
        guard !selectedDays.isEmpty else {
            return false
        }
        
        guard selectedCategory != nil else {
            return false
        }
        
        guard selectedColor != nil else {
            return false
        }
        
        guard selectedEmoji != nil else {
            return false
        }
        
        return true
    }
    
    
    
    @objc private func actionButtonTapped() {
        guard isFormComplete() else { return }
        
        dismissKeyboard()
        
        guard let cell = topTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
              let trackerName = cell.textField.text?.trimmingCharacters(in: .whitespaces),
              !trackerName.isEmpty else { return }
        
        guard !selectedDays.isEmpty else { return }
        guard let selectedColor else { return }
        guard let selectedEmoji else { return }
        guard let selectedCategory else { return }
        
        switch mode {
        case .create:
            let newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: convertDaysToWeekdays()
            )
            DataManager.shared.addTracker(newTracker, to: selectedCategory)
            
            presentingViewController?.presentingViewController?.dismiss(animated: true)
            
        case .edit:
            guard let existingTracker = trackerToEdit else { return }
            
            let updatedTracker = Tracker(
                id: existingTracker.id,
                name: trackerName,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: convertDaysToWeekdays()
            )
            
            DataManager.shared.updateTracker(updatedTracker, category: selectedCategory)
            
            presentingViewController?.dismiss(animated: true)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismissKeyboard()
        switch mode {
        case .create:
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        case .edit:
            presentingViewController?.dismiss(animated: true)
        }
    }
}

extension CreatingTrackersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == topTableView ? 1 : categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
            cell.textField.placeholder = NSLocalizedString("creatingtrackers.search.placeholder",
                                                           comment: "Textp search placeholder")
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = .tintStringColor
            cell.textField.delegate = self
            
            if mode == .edit, let tracker = trackerToEdit {
                cell.textField.text = tracker.name
            }
            
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryCell")
            cell.textLabel?.text = categories[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = .tintStringColor
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .clear
            
            if indexPath.row == 0 {
                if let selectedCategory = selectedCategory {
                    cell.detailTextLabel?.text = selectedCategory
                }
                cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                cell.detailTextLabel?.textColor = .gray
            } else if indexPath.row == 1 {
                let daysString = getShortDaysString()
                if !daysString.isEmpty {
                    cell.detailTextLabel?.text = daysString
                    cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                    cell.detailTextLabel?.textColor = .gray
                }
            }
            
            if indexPath.row == 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == bottomTableView && indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = selectedDays
            scheduleVC.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                self?.bottomTableView.reloadRows(at: [indexPath], with: .none)
                self?.updateActionButtonState()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        } else if tableView == bottomTableView && indexPath.row == 0 {
            let categoryStore = TrackerCategoryStore(context: DataManager.shared.persistentContainer.viewContext)
            let categoryViewModel = CategoryViewModel(categoryStore: categoryStore)
            let categoryVC = CategoryViewController(viewModel: categoryViewModel)

            categoryVC.selectedCategory = selectedCategory

            categoryVC.onCategorySelected = { [weak self] (category: String) in
                self?.selectedCategory = category
                self?.bottomTableView.reloadRows(at: [indexPath], with: .none)
                self?.updateActionButtonState()
            }

            let navController = UINavigationController(rootViewController: categoryVC)
            present(navController, animated: true)
        }
    }
}

extension CreatingTrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateActionButtonState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateActionButtonState()
    }
}

extension CreatingTrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiArray.count
        } else {
            return colorsCells.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EmojiCollectionViewCell
            let emoji = emojiArray[indexPath.row]
            cell.emojiLabel.text = emoji
            cell.backgroundColor = selectedEmoji == emoji ? .lightGrayYP : .clear
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
            let color = colorsCells[indexPath.row]
            cell.configure(with: color, isSelected: selectedColor == color)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! CreatingCollectionHeaderView
        
        if collectionView == emojiCollectionView {
            header.titleLabel.text = NSLocalizedString("creatingtracker.title.emoji", comment: "Emoji header title")
        } else {
            header.titleLabel.text = NSLocalizedString("creatingtrackers.title.color", comment: "Colors header title")
        }
        
        header.titleLabel.textColor = UIColor.tintStringColor
        
        return header
    }
}

extension CreatingTrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojiArray[indexPath.row]
        } else {
            selectedColor = colorsCells[indexPath.row]
        }
        collectionView.reloadData()
        updateActionButtonState()
    }
}

extension CreatingTrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 0, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
}
