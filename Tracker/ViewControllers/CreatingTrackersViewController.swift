//
//  CreatingTrackersViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 03.06.2025.
//

import UIKit

final class CreatingTrackersViewController: UIViewController {
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let creatingButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let topTableView = UITableView()
    private let bottomTableView = UITableView()
    private var selectedDays: Set<String> = []
    private let categories = ["Категория", "Расписание"]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        activateUI()
        setupConstaints()
        setupTables()
        setupKeyboardDismissal()
        setupCollections()
    }
    
    private func setupNavBar() {
        title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func activateUI() {
        view.backgroundColor = .white
        
        view.addSubview(topTableView)
        view.addSubview(bottomTableView)
        view.addSubview(creatingButton)
        view.addSubview(cancelButton)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorsCollectionsView)
        
        topTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        creatingButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionsView.translatesAutoresizingMaskIntoConstraints = false
        
        creatingButton.setTitle("Создать", for: .normal)
        creatingButton.setTitleColor(.white, for: .normal)
        creatingButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        creatingButton.backgroundColor = .grayCreatingButton
        creatingButton.layer.cornerRadius = 16
        creatingButton.addTarget(self, action: #selector(creatingButtonTapped), for: .touchUpInside)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
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
        NSLayoutConstraint.activate([
            topTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            topTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topTableView.heightAnchor.constraint(equalToConstant: 75),
            
            bottomTableView.topAnchor.constraint(equalTo: topTableView.bottomAnchor, constant: 24),
            bottomTableView.leadingAnchor.constraint(equalTo: topTableView.leadingAnchor),
            bottomTableView.trailingAnchor.constraint(equalTo: topTableView.trailingAnchor),
            bottomTableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            creatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            creatingButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            creatingButton.heightAnchor.constraint(equalToConstant: 60),
            creatingButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            emojiCollectionView.topAnchor.constraint(equalTo: bottomTableView.bottomAnchor, constant: 50),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollectionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            colorsCollectionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            colorsCollectionsView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 34),
            colorsCollectionsView.heightAnchor.constraint(equalToConstant: 204)
        ])
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
            return "Каждый день"
        } else if selectedDays.isEmpty {
            return ""
        } else {
            let shortDays = selectedDays.map { day in
                switch day {
                case "Понедельник": return "Пн"
                case "Вторник": return "Вт"
                case "Среда": return "Ср"
                case "Четверг": return "Чт"
                case "Пятница": return "Пт"
                case "Суббота": return "Сб"
                case "Воскресенье": return "Вс"
                default: return ""
                }
            }.sorted { first, second in
                let order = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                return order.firstIndex(of: first) ?? 0 < order.firstIndex(of: second) ?? 0
            }
            
            return shortDays.joined(separator: ", ")
        }
    }
    
    private func convertDaysToWeekdays() -> [Tracker.Weekday] {
        var weekdays: [Tracker.Weekday] = []
        
        for day in selectedDays {
            switch day {
            case "Понедельник": weekdays.append(.monday)
            case "Вторник": weekdays.append(.tuesday)
            case "Среда": weekdays.append(.wednesday)
            case "Четверг": weekdays.append(.thursday)
            case "Пятница": weekdays.append(.friday)
            case "Суббота": weekdays.append(.saturday)
            case "Воскресенье": weekdays.append(.sunday)
            default: break
            }
        }
        
        return weekdays
    }
    
    @objc private func creatingButtonTapped() {
        dismissKeyboard()
        
        guard let cell = topTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
              let trackerName = cell.textField.text?.trimmingCharacters(in: .whitespaces),
              !trackerName.isEmpty else { return }
        
        guard !selectedDays.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .redCells,
            emoji: "🌺",
            schedule: convertDaysToWeekdays()
        )
        
        NotificationCenter.default.post(
            name: NSNotification.Name("NewTrackerCreated"),
            object: nil,
            userInfo: ["tracker": newTracker]
        )
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismissKeyboard()
        presentingViewController?.presentingViewController?.dismiss(animated: true)
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
            cell.textField.placeholder = "Введите название трекера"
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = .black
            cell.textField.delegate = self
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryCell")
            cell.textLabel?.text = categories[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = .clear
            
            if indexPath.row == 1 {
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
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

extension CreatingTrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            cell.emojiLabel.text = emojiArray[indexPath.row]
            cell.backgroundColor = selectedEmoji == emojiArray[indexPath.row] ? .lightGrayYP : .clear
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
            header.titleLabel.text = "Emoji"
        } else {
            header.titleLabel.text = "Цвет"
        }
        
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = emojiCollectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
        cell.backgroundColor = .clear
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
