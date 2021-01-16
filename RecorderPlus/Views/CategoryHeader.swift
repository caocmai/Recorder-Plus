//
//  CategoryHeader.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/8/21.
//

import UIKit


class CategoryHeader: UITableViewHeaderFooterView {
    
    let newRecordingButton = UIButton()
    let title = UITextField()
    let delete = UIButton()
    static var indentifier = "categoryHeader"
    var deleteCompletion: (() -> Void)?
    
    var newRecordingcompletion: (() -> Void)?
    
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
        
        let trashSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "trash", color: #colorLiteral(red: 1, green: 0.2586690485, blue: 0.2360589504, alpha: 1), size: 17)
        
        delete.setImage(trashSymbol, for: .normal)
        delete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        //        delete.backgroundColor = .blue
        
        NSLayoutConstraint.activate([
            
            delete.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            delete.widthAnchor.constraint(equalToConstant: 30),
            delete.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            title.leadingAnchor.constraint(equalTo: delete.trailingAnchor, constant: 3),
            title.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40),
            title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            newRecordingButton.widthAnchor.constraint(equalToConstant: 25),
            newRecordingButton.leadingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40),
            newRecordingButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

        ])
    }
    
    @objc func newRecordingButtonTapped() {
        newRecordingcompletion?()
    }
    
    @objc func deleteButtonTapped() {
        deleteCompletion?()
    }
}
