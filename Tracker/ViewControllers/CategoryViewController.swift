//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 15.09.2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let viewModel: CategoryViewModel
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private let placeholderImageView = UIImageView(image: UIImage(named: "trackerLogo"))
    private let placeholderTitle: UILabel = {
        let title = UILabel()
        title.text = "Привычки и события можно\nобъединить по смыслу"
        title.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        title.textColor = .black
        title.numberOfLines = 0
        title.textAlignment = .center
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
    
    var onCategorySelected: ((String) -> Void)?
    var selectedCategory: String?
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
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
        setupTable()
        setupBindings()
        viewModel.loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    private func setupTable() {
        categoriesTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "cell")
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        updateTableViewHeight()
        checkPlaceholderVisibility()
        categoriesTableView.reloadData()
    }
    
    private func updateTableViewHeight() {
        let cellHeight: Int = 75
        tableViewHeightConstraint.constant = CGFloat(cellHeight * viewModel.numberOfCategories)
    }
    
    private func setupNavBar() {
        title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
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
    
    private func activateConstraints() {
        tableViewHeightConstraint = categoriesTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            
            placeholderTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.bottomAnchor.constraint(equalTo: placeholderTitle.topAnchor, constant: -16),
            
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewHeightConstraint
        ])
    }
    
    private func checkPlaceholderVisibility() {
        let isEmpty = viewModel.shouldShowPlaceholder
        
        placeholderTitle.isHidden = !isEmpty
        placeholderImageView.isHidden = !isEmpty
        
        categoriesTableView.isHidden = isEmpty
    }
    
    private func addNewCategory(_ categoryName: String) {
        viewModel.saveCategory(categoryName)
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
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        
        cell.titleLabel.text = viewModel.getCategoryTitle(at: indexPath.row)
        
        if viewModel.getCategoryTitle(at: indexPath.row) == selectedCategory {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == viewModel.numberOfCategories - 1 {
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
        let selectedCategory = viewModel.selectCategory(at: indexPath.row)
        
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        onCategorySelected?(selectedCategory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteCategory(at: indexPath.row)
        }
    }
}
