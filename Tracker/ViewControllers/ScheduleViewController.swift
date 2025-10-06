//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 04.06.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private let days = [
        NSLocalizedString("schedule.day.monday", comment: ""),
        NSLocalizedString("schedule.day.tuesday", comment: ""),
        NSLocalizedString("schedule.day.wednesday", comment: ""),
        NSLocalizedString("schedule.day.thursday", comment: ""),
        NSLocalizedString("schedule.day.friday", comment: ""),
        NSLocalizedString("schedule.day.saturday", comment: ""),
        NSLocalizedString("schedule.day.sunday", comment: "")
        ]
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
        title = NSLocalizedString("schedule.nav.title", comment: "Title sheduleVC")
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.tintStringColor
        ]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func activateUI() {
        view.backgroundColor = UIColor.backgroundViewColor
        view.addSubview(readyButton)
        view.addSubview(scheduleTable)
        
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleTable.translatesAutoresizingMaskIntoConstraints = false
        
        readyButton.setTitle(NSLocalizedString("schedule.button.ready",
                                               comment: "Text ready button"), for: .normal)
        readyButton.setTitleColor(.buttonTextColor, for: .normal)
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        readyButton.backgroundColor = UIColor.backgroundButtonColor
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
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            
            scheduleTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            scheduleTable.heightAnchor.constraint(equalToConstant: CGFloat(days.count * 75))
        ])
    }
    
    @objc private func readyButtonTapped() {
        onDaysSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        
        let day = days[indexPath.row]
        cell.configure(with: day, isSelected: selectedDays.contains(day))
        
        cell.onSwitchChanged = { [weak self] isOn in
            if isOn {
                self?.selectedDays.insert(day)
            } else {
                self?.selectedDays.remove(day)
            }
        }
        
        if indexPath.row == days.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.backgroundColor = .backgroundTables
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
