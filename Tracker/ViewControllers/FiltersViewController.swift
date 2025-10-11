//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 08.10.2025.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    private lazy var filtersTableView = UITableView()
    private let filters: [DataManager.Filter] = [.all, .today, .completed, .uncompleted]
    private var currentFilter: DataManager.Filter
    
    var onFilterSelected: ((DataManager.Filter) -> Void)?
    
    init(currentFilter: DataManager.Filter = .all) {
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundViewColor
        
        setupNavigationBar()
        setupTableView()
        activateConstraints()
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("filters.nav.title", comment: "Title filtersVC")
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupTableView() {
        view.addSubview(filtersTableView)
        filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        filtersTableView.register(FiltersTableViewCell.self, forCellReuseIdentifier: "cell")
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        
        filtersTableView.backgroundColor = UIColor.backgroundViewColor
        filtersTableView.layer.cornerRadius = 16
        filtersTableView.separatorStyle = .singleLine
        filtersTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filtersTableView.isScrollEnabled = false
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filtersTableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FiltersTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        cell.titleLabel.text = filter.localizedString
        cell.backgroundColor = .backgroundTables
        
        let shouldShowCheckmark = (filter == currentFilter) &&
        (filter != .all && filter != .today)
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFilter = filters[indexPath.row]
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }
}
