//
//  CreatingNewCategoryViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 16.09.2025.
//

import UIKit

final class CreatingNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    
    var onCategoryCreated: ((String) -> Void)?
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("new.button.text", comment: "Text button ready"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grayButton
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self,
                         action: #selector(readyButtonTapped),
                         for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let tableViewText: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .backgroundTables
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        activateConstraints()
    }
    
    private func setupNavBar() {
        title = NSLocalizedString("new.category.title", comment: "Title categoryVC")
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(readyButton)
        view.addSubview(tableViewText)
        
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        tableViewText.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewText.delegate = self
        tableViewText.dataSource = self
        tableViewText.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableViewText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewText.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    @objc private func readyButtonTapped() {
        guard let cell = tableViewText.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
              let categoryName = cell.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryName.isEmpty else {
            return
        }
        
        onCategoryCreated?(categoryName)
        
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        readyButton.isEnabled = !text.isEmpty
        readyButton.backgroundColor = !text.isEmpty ? .black : .grayButton
    }
}

extension CreatingNewCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TextFieldTableViewCell
        cell.textField.placeholder = NSLocalizedString("new.category.search.placeholder",
                                                       comment: "Text search placeholder")
        cell.textField.delegate = self
        cell.textField.clearButtonMode = .never
        cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        cell.backgroundColor = .backgroundTables
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
