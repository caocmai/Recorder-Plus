//
//  RecordingCollectionViewCell.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/9/21.
//

import UIKit
import AVFoundation

class RecordingCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    let countdownLabel = UILabel()
    let playBackButton = UIButton()
    let deleteButton = UIButton()
    let recordingTitle = UILabel()
    var recordingObject: Recording!
    var uuid = String()
    var timer:Timer?
    var totalAudioSeconds = 0
    var isPlaying = false
    var coreDataStack: CoreDataStack!
    
    required init?(coder: NSCoder) {
        fatalError("nope!")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(countdownLabel)
        self.contentView.addSubview(playBackButton)
        self.contentView.addSubview(recordingTitle)
        
        //    contentView.backgroundColor = .blue
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        playBackButton.translatesAutoresizingMaskIntoConstraints = false
        recordingTitle.translatesAutoresizingMaskIntoConstraints = false
        
        countdownLabel.textAlignment = .center
        recordingTitle.textAlignment = .center
        
        countdownLabel.textColor = .gray
        
        let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
        playBackButton.setImage(playButton, for: .normal)
        playBackButton.setTitleColor(.black, for: .normal)
        playBackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            countdownLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            countdownLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            countdownLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            
            playBackButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            playBackButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playBackButton.heightAnchor.constraint(equalToConstant: 60),
            playBackButton.widthAnchor.constraint(equalToConstant: 60),
            
            recordingTitle.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 35),
            recordingTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            recordingTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
        ])
        
        
        self.contentView.addSubview(deleteButton)
        let trash = SFSymbolCreator.setSFSymbolColor(symbolName: "xmark.square.fill", color: .red, size: 23)
        deleteButton.setImage(trash, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -3),
            deleteButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -3),
        ])
        
    }
    
    @objc func playbackButtonTapped() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        
        if isPlaying == false {
            let stopIcon = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle", color: .green, size: 40)
            AudioPlayer.shared.play(url: audioFilename)
            totalAudioSeconds = Int(AudioPlayer.shared.player.duration)
            AudioPlayer.shared.player.play()
            playBackButton.setImage(stopIcon, for: .normal)
            isPlaying = true
            startTimer()
        } else {
            timer?.invalidate()
            isPlaying = false
            AudioPlayer.shared.player.stop()
            let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
            playBackButton.setImage(playButton, for: .normal)
        }
    }
    
    /// not sure if should keep this functionality
    @objc func deleteButtonTapped() {
        coreDataStack.deleteRecordingByCategoryId(identifier: UUID(uuidString: uuid)!)
        let fileManager = FileManager.default
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        do {
            try fileManager.removeItem(at: audioFilename)
        } catch {
            
        }
        
        playBackButton.removeFromSuperview()
        deleteButton.removeFromSuperview()
        countdownLabel.removeFromSuperview()
        recordingTitle.removeFromSuperview()
        contentView.backgroundColor = .white
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        updateTimerLabel()
        
    }
    
    func updateTimerLabel() {
        var hours: Int
        var minutes: Int
        var seconds: Int
        
        if totalAudioSeconds == 0 {
            timer?.invalidate()
            let stopIcon = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
            playBackButton.setImage(stopIcon, for: .normal)
            
            totalAudioSeconds = Int(AudioPlayer.shared.player.duration)
            hours = totalAudioSeconds / 3600
            minutes = (totalAudioSeconds % 3600) / 60
            seconds = (totalAudioSeconds % 3600) % 60
            countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
        }
        
        //        print(totalSecond)
        hours = totalAudioSeconds / 3600
        minutes = (totalAudioSeconds % 3600) / 60
        seconds = (totalAudioSeconds % 3600) % 60
        countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        totalAudioSeconds = totalAudioSeconds - 1
        
    }
}
