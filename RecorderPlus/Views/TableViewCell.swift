//
//  TableViewCell.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit
import AVFoundation

protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: RecordingCollectionViewCell?, index: Int, didTappedInTableViewCell: TableViewCell)
    // other delegate methods that you can define to perform action in viewcontroller
}


class TableViewCell: UITableViewCell {
    
    weak var cellDelegate: CollectionViewCellDelegate?
    
    //    var coreDataStack = CoreDataStack()
    var recordings: [Recording]?
    var recordingDuration = Int()
    var timeString = String()
    
    
    //    let simpleConfig = UICollectionView.CellRegistration<RecordingCollectionViewCell, Recording> { (cell, indexPath, model) in
    //        cell.recordingTitle.text = model.name
    //        cell.backgroundColor = .lightGray
    //        cell.uuid = model.recordingID!.uuidString
    //        cell.coreDataStack = CoreDataStack()
    //        cell.recordingObject = model
    //
    //    }
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 180)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(RecordingCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
    
    func updateCellNew(row: [Recording]) {
        self.recordings = row
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? RecordingCollectionViewCell
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecordingCollectionViewCell
        
        let model = self.recordings?[indexPath.item]
        cell.recordingTitle.text = model?.name
        cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.uuid = (model?.recordingID!.uuidString)!
        cell.coreDataStack = CoreDataStack()
        cell.recordingObject = model
        cell.countdownLabel.text = getTimeLabel(uuid: (model?.recordingID!.uuidString)!)
        
        return cell
        //        return collectionView.dequeueConfiguredReusableCell(using: simpleConfig,
        //                                                            for: indexPath,
        //                                                            item: model)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDuration(uuid: String) -> Int {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        let asset = AVURLAsset(url: audioFilename, options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = Int(CMTimeGetSeconds(audioDuration))
        //        print(audioDurationSeconds)
        return audioDurationSeconds
    }
    
    func getTimeLabel(uuid: String) -> String {
        let totalSecond = getDuration(uuid: uuid)
        var hours: Int
        var minutes: Int
        var seconds: Int
        
        
        //        print(totalSecond)
        hours = totalSecond / 3600
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}


extension TableViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let edit = UIAction(title: "Edit...") { _ in
            let cell = collectionView.cellForItem(at: indexPath) as? RecordingCollectionViewCell
            print("I'm tapping the \(indexPath.item)")
            self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
            
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: .none, discoverabilityTitle: .none, attributes: .destructive, state: .off) { (_) in
            
            let recording = self.recordings?[indexPath.row]
            let coreDataStack = CoreDataStack()
            coreDataStack.deleteRecordingCategoryByID(identifier: (recording?.recordingID)!)
            self.recordings?.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            let fileManager = FileManager.default
            
            let uuidString = recording?.recordingID?.uuidString
            
            let audioFilename = self.getDocumentsDirectory().appendingPathComponent(uuidString!+".m4a")
            do {
                try fileManager.removeItem(at: audioFilename)
            } catch {
               print("file not found to delete")
            }
            

        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [edit, delete])
        }
    }
    
}
