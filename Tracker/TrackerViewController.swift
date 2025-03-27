//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    private let labelTask = UILabel()
    private let labelTitle = UILabel()
    private let datePicker = UIDatePicker()
    private let imageViewTracker = UIImageView(image: UIImage(named: "trackerLogo"))
    private let searchField = UISearchTextField()
    private let buttonPlus = UIButton.systemButton(with: UIImage(named: "plus")!,
                                                   target: TrackerViewController.self,
                                                   action: #selector(Self.buttonPlusTap))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundView
        
        initUI()
        setupConstraints()
    }
    
    private func initUI() {
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        imageViewTracker.translatesAutoresizingMaskIntoConstraints = false
        labelTask.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelTitle)
        view.addSubview(buttonPlus)
        view.addSubview(searchField)
        view.addSubview(imageViewTracker)
        view.addSubview(labelTask)
        view.addSubview(datePicker)
    }
    
    private func setupConstraints() {
        
        // labelTitle
        labelTitle.text = "Трекеры"
        labelTitle.textColor = .black
        labelTitle.font = .systemFont(ofSize: 34, weight: .bold)
        labelTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        labelTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        
        // buttonPlus
        buttonPlus.tintColor = .black
        buttonPlus.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buttonPlus.widthAnchor.constraint(equalToConstant: 44).isActive = true
        buttonPlus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
        buttonPlus.topAnchor.constraint(equalTo: view.topAnchor, constant: 45).isActive = true
        
        // searchField
        searchField.placeholder = "Поиск"
        searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        searchField.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 7).isActive = true
        
        // imageViewTracker
        imageViewTracker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewTracker.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewTracker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageViewTracker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // labelTask
        labelTask.text = "Что будем отслеживать?"
        labelTask.font = .systemFont(ofSize: 12, weight: .medium)
        labelTask.centerXAnchor.constraint(equalTo: imageViewTracker.centerXAnchor).isActive = true
        labelTask.topAnchor.constraint(equalTo: imageViewTracker.bottomAnchor, constant: 8).isActive = true
        
        // datepicker
        datePicker.datePickerMode = .date
        datePicker.heightAnchor.constraint(equalToConstant: 34).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 97).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: buttonPlus.centerYAnchor).isActive = true
    }
    
    @objc func buttonPlusTap() {
        
    }
}
