//
//  CaregoryViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 15.09.2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let placeholderImageView = UIImageView(image: UIImage(named: "trackerLogo"))
    private let placeholderTitle: UILabel = {
        let title = UILabel()
        title.text = "Привычки и события можно объединить по смыслу"
        title.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        title.textColor = .black
        return title
    }()
    
    private lazy var newCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .backgroundTables
        return tableView
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var categoriesList: [String] = [] {
        didSet {
            checkPlaceholderVisibility()
            updateTableViewHeight()
            categoriesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        activateConstraints()
        setupTable()
        checkPlaceholderVisibility()
    }
    
    private func setupNavBar() {
        title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(placeholderTitle)
        view.addSubview(placeholderImageView)
        view.addSubview(newCategoryButton)
        view.addSubview(categoriesTableView)
        
        placeholderTitle.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        newCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTable() {
        categoriesTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }
    
    private func activateConstraints() {
        tableViewHeightConstraint = categoriesTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderTitle.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewHeightConstraint // Используем переменную констрейнта
        ])
    }
    
    private func updateTableViewHeight() {
        let height = CGFloat(categoriesList.count * 75)
        tableViewHeightConstraint.constant = height
    }
    
    private func checkPlaceholderVisibility() {
        let shouldHidePlaceholder = categoriesList.count > 0
        placeholderTitle.isHidden = shouldHidePlaceholder
        placeholderImageView.isHidden = shouldHidePlaceholder
        categoriesTableView.isHidden = !shouldHidePlaceholder
    }
    
    private func addNewCategory(_ categoryName: String) {
        categoriesList.append(categoryName)
    }
    
    @objc private func newCategoryButtonTapped() {
        let creatingVC = CreatingNewCategoryViewController()
        
        creatingVC.onCategoryCreated = { [weak self] categoryName in
            self?.addNewCategory(categoryName)
        }
        
        let navController = UINavigationController(rootViewController: creatingVC)
        present(navController, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        
        cell.titleLabel.text = categoriesList[indexPath.row]
        
        if indexPath.row == categoriesList.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundColor = .backgroundTables
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
