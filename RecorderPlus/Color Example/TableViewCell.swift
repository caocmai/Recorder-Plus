//
//  TableViewCell.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit

protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: CollectionViewCell?, index: Int, didTappedInTableViewCell: TableViewCell)
    // other delegate methods that you can define to perform action in viewcontroller
}


class TableViewCell: UITableViewCell {
    
    weak var cellDelegate: CollectionViewCellDelegate?
    
    var cellID: UUID!
    
    var coreDataStack = CoreDataStack()
    
    var recordings: [Recording]?

    
    var rowWithColors: [CollectionViewCellModel]?
    var subCategoryLabel = UILabel()
    
//    let simpleConfig = UICollectionView.CellRegistration<MyCollectionViewCell, CollectionViewCellModel> { (cell, indexPath, model) in
//        cell.label.text = model.name
//        cell.backgroundColor = model.color
//
//    }
    
    let simpleConfig = UICollectionView.CellRegistration<MyCollectionViewCell, Recording> { (cell, indexPath, model) in
        cell.label.text = model.name
        cell.backgroundColor = .blue

    }
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 180)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
//        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = .white
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

        ])

    }

}


extension TableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [CollectionViewCellModel]) {
        self.rowWithColors = row
        self.collectionView.reloadData()
    }
    
    func updateCellNew(row: [Recording]) {
        self.recordings = row
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        print("I'm tapping the \(indexPath.item)")
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.rowWithColors?.count ?? 0
        return recordings?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? UICollectionViewCell {
//            cell.backgroundColor = self.rowWithColors?[indexPath.item].color ?? UIColor.blue
////            cell.text = self.rowWithColors?[indexPath.item].name ?? ""
//            return cell
//        }
//        print("test")
//        return UICollectionViewCell()
//        let model = self.rowWithColors?[indexPath.item].name ?? ""
//        let model = self.rowWithColors?[indexPath.item].color
        
//        let model = self.rowWithColors?[indexPath.item]
        
        let model = self.recordings?[indexPath.item]

        
        return collectionView.dequeueConfiguredReusableCell(using: simpleConfig,
                                                            for: indexPath,
                                                            item: model)
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}
