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
    
    
    required init?(coder: NSCoder) {
        fatalError("nope!")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        contentView.addSubview(playBackButton)
        
        //    contentView.backgroundColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        playBackButton.translatesAutoresizingMaskIntoConstraints = false
        playBackButton.setTitle("Play", for: .normal)
        playBackButton.backgroundColor = .green
        playBackButton.setTitleColor(.purple, for: .normal)
        playBackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant:  -8),
            label.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            playBackButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playBackButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
    }
    
    @objc func playbackButtonTapped() {
        print("playback")
        
        if playBackButton.titleLabel?.text == "Play" {
            playBackButton.setTitle("Stop", for: .normal)
            setupPlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            playBackButton.setTitle("Play", for: .normal)
        }
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
