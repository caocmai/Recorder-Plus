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
    let title = UITextField()
    let delete = UIButton()
    var deleteCompletion: (() -> Void)?
    
    var completion: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implmented")
    }
    
    private func configureUI() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(newRecordingButton)
        self.contentView.addSubview(title)
        self.contentView.addSubview(delete)
        
        newRecordingButton.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        delete.translatesAutoresizingMaskIntoConstraints = false
        
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title.setBottomBorder()
        title.isUserInteractionEnabled = false

        
        newRecordingButton.setImage(UIImage(systemName: "plus.app"), for: .normal)
        newRecordingButton.addTarget(self, action: #selector(newRecordingButtonTapped), for: .touchUpInside)
        
        delete.setImage(UIImage(systemName: "trash"), for: .normal)
        delete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
//        delete.backgroundColor = .blue
        
        NSLayoutConstraint.activate([
            
            newRecordingButton.widthAnchor.constraint(equalToConstant: 25),
            newRecordingButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            newRecordingButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            title.leadingAnchor.constraint(equalTo: newRecordingButton.trailingAnchor, constant: 5),
            title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            delete.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 5),
//            delete.leadingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -80),
            delete.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
//            delete.widthAnchor.constraint(equalToConstant: 30),
            
            
            
            
            
            
        ])
    }
    
    @objc func newRecordingButtonTapped() {
        completion?()
    }
    
    @objc func deleteButtonTapped() {
        deleteCompletion?()
    }
}
