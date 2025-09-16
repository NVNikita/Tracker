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
    
    private let newCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(CategoryViewController.self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .backgroundTables
        return tableView
    }()
    
    private let countCells = [Int]() 
    
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
            categoriesTableView.heightAnchor.constraint(equalToConstant: CGFloat(countCells.count * 75))
            
        ])
    }
    
    private func checkPlaceholderVisibility() {
        if countCells.count != 0 {
            placeholderTitle.isHidden = true
            placeholderImageView.isHidden = true
        }
    }
    
    @objc private func newCategoryButtonTapped() {
        
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        
        if indexPath.row < countCells.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        cell.titleLabel.text = "Важное"
        cell.backgroundColor = .backgroundTables
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        return cell
    }
}
