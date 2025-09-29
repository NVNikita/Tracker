//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 30.05.2025.
//

import UIKit

final class TrackerTypeViewController: UIViewController {
    
    private let buttonHabbit = UIButton(type: .system)
    private let buttonEvent = UIButton(type: .system)
    private let buttonHabbitText = NSLocalizedString("trackertype.button.habbit.title",
                                                     comment: "Button habbit text")
    private let buttonEventText = NSLocalizedString("trackertype.button.event.title" ,
                                                    comment: "Button event text")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        activateUIConstaints()
    }
    
    private func setupNavBar() {
        title = NSLocalizedString("trackertype.nav.title", comment: "Title trackerTypeVC")
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(buttonEvent)
        view.addSubview(buttonHabbit)
        
        buttonEvent.translatesAutoresizingMaskIntoConstraints = false
        buttonHabbit.translatesAutoresizingMaskIntoConstraints = false
        
        buttonHabbit.setTitle(buttonHabbitText, for: .normal)
        buttonHabbit.setTitleColor(.white, for: .normal)
        buttonHabbit.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonHabbit.backgroundColor = .black
        buttonHabbit.layer.cornerRadius = 16
        buttonHabbit.addTarget(self, action: #selector(buttonHabbitTapped), for: .touchUpInside)
        
        buttonEvent.setTitle(buttonEventText, for: .normal)
        buttonEvent.setTitleColor(.white, for: .normal)
        buttonEvent.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buttonEvent.backgroundColor = .black
        buttonEvent.layer.cornerRadius = 16
        buttonEvent.addTarget(self, action: #selector(buttonEventTapped), for: .touchUpInside)
    }
    
    private func activateUIConstaints() {
        buttonHabbit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonHabbit.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24).isActive = true
        buttonHabbit.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonHabbit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        buttonHabbit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        buttonEvent.topAnchor.constraint(equalTo: buttonHabbit.bottomAnchor, constant: 16).isActive = true
        buttonEvent.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonEvent.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonEvent.widthAnchor.constraint(equalTo: buttonHabbit.widthAnchor).isActive = true
    }
    
    @objc private func buttonHabbitTapped() {
        let navVC = UINavigationController(rootViewController: CreatingTrackersViewController())
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }
    
    @objc private func buttonEventTapped() {
        
    }
}
