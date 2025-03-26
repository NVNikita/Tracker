//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    private let labelBottomImageCenter = UILabel()
    private let imageViewCenter = UIImageView(image: UIImage(named: "trackerLogo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundView
        
        initUI()
        setupConstraints()
    }
    
    private func initUI() {
        labelBottomImageCenter.translatesAutoresizingMaskIntoConstraints = false
        imageViewCenter.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelBottomImageCenter)
        view.addSubview(imageViewCenter)
    }
    
    private func setupConstraints() {
        // imageViewCenter
        imageViewCenter.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewCenter.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageViewCenter.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageViewCenter.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // labelBottomImageCenter
        labelBottomImageCenter.text = "Что будем отслеживать?"
        labelBottomImageCenter.centerXAnchor.constraint(equalTo: imageViewCenter.centerXAnchor).isActive = true
        labelBottomImageCenter.topAnchor.constraint(equalTo: imageViewCenter.bottomAnchor, constant: 8).isActive = true
        
    }
}
