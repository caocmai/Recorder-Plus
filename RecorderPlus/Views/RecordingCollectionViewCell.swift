//
//  RecordingCollectionViewCell.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/9/21.
//

import UIKit
import AVFoundation

class RecordingCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    let label = UILabel()
    let playBackButton = UIButton()
    var soundPlayer : AVAudioPlayer!
    var uuid : String!
    var deleteButton = UIButton()
    var recordingObject: Recording!
    
    var coreDataStack: CoreDataStack!

    required init?(coder: NSCoder) {
        fatalError("nope!")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(label)
        self.contentView.addSubview(playBackButton)
        
        //    contentView.backgroundColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        playBackButton.translatesAutoresizingMaskIntoConstraints = false
        playBackButton.setTitle("Play", for: .normal)
        let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 24)
        playBackButton.setImage(playButton, for: .normal)
        playBackButton.backgroundColor = .yellow
        playBackButton.setTitleColor(.black, for: .normal)
        playBackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
//        playBackButton.imageView?.contentMode = .scaleAspectFill
//        playBackButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)

        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant:  -8),
            label.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            
            playBackButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            playBackButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            playBackButton.heightAnchor.constraint(equalToConstant: 50),
            playBackButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        
        self.contentView.addSubview(deleteButton)
        deleteButton.setTitle("DELETE", for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.purple, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 50),
            deleteButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
        
    }
    
    @objc func playbackButtonTapped() {
        print("playback")
        if playBackButton.titleLabel?.text == "Play" {
            playBackButton.setTitle("Stop", for: .normal)
            let stopIcon = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle", color: .green, size: 24)
            playBackButton.setImage(stopIcon, for: .normal)
            setupPlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            playBackButton.setTitle("Play", for: .normal)
            let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 24)
            playBackButton.setImage(playButton, for: .normal)
        }
    }
    
    @objc func deleteButtonTapped() {
        
        coreDataStack.deleteRecordingCategoryByID(identifier: UUID(uuidString: uuid)!)
        let fileManager = FileManager.default
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        do {
            try fileManager.removeItem(at: audioFilename)
        } catch {
            
        }
        
        playBackButton.removeFromSuperview()
        deleteButton.removeFromSuperview()
        contentView.backgroundColor = .white
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
}
