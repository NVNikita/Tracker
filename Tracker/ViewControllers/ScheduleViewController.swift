//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 04.06.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private let days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    var selectedDays: Set<String> = []
    private var readyButton = UIButton(type: .system)
    private var scheduleTable = UITableView()
    var onDaysSelected: ((Set<String>) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        activateUI()
        activateConstaints()
        setupTable()
    }
    
    private func setupNavBar() {
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func activateUI() {
        view.backgroundColor = .white
        view.addSubview(readyButton)
        view.addSubview(scheduleTable)
        
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleTable.translatesAutoresizingMaskIntoConstraints = false
        
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.white, for: .normal)
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        readyButton.backgroundColor = .black
        readyButton.layer.masksToBounds = true
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
    }
    
    private func setupTable() {
        scheduleTable.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "DayCell")
        
        scheduleTable.isScrollEnabled = false
        scheduleTable.layer.masksToBounds = true
        scheduleTable.allowsSelection = false

        
        scheduleTable.backgroundColor = .backgroundTables
        scheduleTable.layer.cornerRadius = 16
        scheduleTable.separatorStyle = .singleLine
        scheduleTable.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
    }
    
    private func activateConstaints() {
        readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        readyButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        scheduleTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        scheduleTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        scheduleTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        scheduleTable.heightAnchor.constraint(equalToConstant: CGFloat(days.count * 75)).isActive = true
    }
    
    @objc private func readyButtonTapped() {
        onDaysSelected?(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as? ScheduleTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .backgroundTables
        
        let day = days[indexPath.row]
        cell.configure(with: day, isSelected: selectedDays.contains(day))
        
        cell.onSwitchChanged = { [weak self] ison in
            if ison {
                self?.selectedDays.insert(day)
            } else {
                self?.selectedDays.remove(day)
            }
        }
        
        if indexPath.row == days.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
