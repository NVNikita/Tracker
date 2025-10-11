//
//  CreatingNewCategoryViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 16.09.2025.
//

import UIKit

final class CreatingNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    enum Mode {
        case create
        case edit(String, Int)
    }
    
    private let mode: Mode
    var onCategoryCreated: ((String) -> Void)?
    var onCategoryUpdated: ((String, Int) -> Void)?
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("new.button.text", comment: "Text button ready"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grayButton
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.isEnabled = false
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
    
    init() {
        self.mode = .create
        super.init(nibName: nil, bundle: nil)
    }
    
    init(categoryName: String, categoryIndex: Int) {
        self.mode = .edit(categoryName, categoryIndex)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        activateConstraints()
    }
    
    private func setupNavBar() {
        switch mode {
        case .create:
            title = NSLocalizedString("new.category.title", comment: "Title categoryVC")
            navigationItem.setHidesBackButton(true, animated: false)
        case .edit:
            title = NSLocalizedString("new.category.title.edit", comment: "Edit category")
        }
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.tintStringColor
        ]
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.backgroundViewColor
        view.addSubview(actionButton)
        view.addSubview(tableViewText)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        tableViewText.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewText.delegate = self
        tableViewText.dataSource = self
        tableViewText.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableViewText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewText.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    @objc private func actionButtonTapped() {
        guard let cell = tableViewText.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldTableViewCell,
              let categoryName = cell.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryName.isEmpty else {
            return
        }
        
        switch mode {
        case .create:
            onCategoryCreated?(categoryName)
            navigationController?.dismiss(animated: true)
        case .edit(_, let index):
            onCategoryUpdated?(categoryName, index)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        switch mode {
        case .create:
            let isValid = !text.isEmpty
            actionButton.isEnabled = isValid
            actionButton.backgroundColor = isValid ? .backgroundButtonColor : .grayButton
            actionButton.setTitleColor(UIColor.buttonTextColor, for: .normal)
            
        case .edit(let originalName, _):
            let hasChanges = text != originalName && !text.isEmpty
            actionButton.isEnabled = hasChanges
            actionButton.backgroundColor = hasChanges ? .backgroundButtonColor : .grayButton
            actionButton.setTitleColor(UIColor.buttonTextColor, for: .normal)
        }
    }
}

extension CreatingNewCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TextFieldTableViewCell
        cell.textField.placeholder = NSLocalizedString("new.category.search.placeholder", comment: "Text search placeholder")
        cell.textField.delegate = self
        cell.textField.clearButtonMode = .whileEditing
        cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if case .edit(let categoryName, _) = mode {
            cell.textField.text = categoryName
        }
        
        cell.backgroundColor = .backgroundTables
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        DispatchQueue.main.async {
            cell.textField.becomeFirstResponder()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
