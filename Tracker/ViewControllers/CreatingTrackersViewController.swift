//
//  CreatingTrackersViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 03.06.2025.
//

import UIKit

final class CreatingTrackersViewController: UIViewController {
    
    private let creatingButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let topTableView = UITableView()
    private let bottomTableView = UITableView()
    private var selectedDays: Set<String> = []
    
    private let categories = ["Категория", "Расписание"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        activateUI()
        setupConstaints()
        setupTables()
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
        
        topTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        creatingButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        cancelButton.layer.masksToBounds = true
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
            creatingButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8)
        ])
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
    
    @objc private func creatingButtonTapped() {
        
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension CreatingTrackersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topTableView {
            return 1
        } else {
            return categories.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
            cell.textField.placeholder = "Введите название трекера"
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = .black
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
                    cell.detailTextLabel?.numberOfLines = 0
                }
            }
            
            if indexPath.row != 0 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
            let navVC = UINavigationController(rootViewController: scheduleVC)
            navVC.modalPresentationStyle = .pageSheet
            present(navVC, animated: true)
        }
    }
}
