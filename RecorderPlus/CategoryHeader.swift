//
//  CategoryHeader.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/8/21.
//

import UIKit


class CategoryHeader: UITableViewHeaderFooterView {
    
    static var indentifier = "categoryHeader"
    let newRecordingButton = UIButton()
    let title = UILabel()
    
    var completion: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implmented")
    }
    
    private func configureUI() {
        self.contentView.addSubview(newRecordingButton)
        self.contentView.addSubview(title)
        
        newRecordingButton.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        newRecordingButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        newRecordingButton.addTarget(self, action: #selector(newRecordingButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            newRecordingButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            newRecordingButton.leadingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40),
            newRecordingButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    @objc func newRecordingButtonTapped() {
        completion?()
        
    }
}
