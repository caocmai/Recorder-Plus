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
//    var soundPlayer = AudioPlayer()
    var uuid = String()
    var deleteButton = UIButton()
    var recordingObject: Recording!
    var recordingTitle = UILabel()
    var timer:Timer?
    var totalSecond = 0
    var totalAudioDuration = 0
    
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
        
        //        playBackButton.setTitle("Play", for: .normal)
        let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
        playBackButton.setImage(playButton, for: .normal)
        //        playBackButton.backgroundColor = .yellow
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
            //            playBackButton.setTitle("Stop", for: .normal)
            let stopIcon = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle", color: .green, size: 40)
            
            AudioPlayer.shared.play(url: audioFilename)
            
            totalSecond = Int(AudioPlayer.shared.player.duration)
//            totalAudioDuration = totalSecond
            AudioPlayer.shared.player.play()
            playBackButton.setImage(stopIcon, for: .normal)
//            setupPlayer()
//            soundPlayer.player.play()
            isPlaying = true
            startTimer()
        } else {
            timer?.invalidate()
            isPlaying = false
            AudioPlayer.shared.player.stop()
            //            playBackButton.setTitle("Play", for: .normal)
            let playButton = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
            playBackButton.setImage(playButton, for: .normal)
        }
    }
    
    @objc func deleteButtonTapped() {
        
        coreDataStack.deleteRecordingsCategoryByID(identifier: UUID(uuidString: uuid)!)
        let fileManager = FileManager.default
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        do {
            try fileManager.removeItem(at: audioFilename)
        } catch {
            
        }
        
        playBackButton.removeFromSuperview()
        deleteButton.removeFromSuperview()
        //        countdownLabel.removeFromSuperview()
        //        recordingTitle.removeFromSuperview()
        contentView.backgroundColor = .white
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
//        print(audioFilename)
        
        do {
            
//            soundPlayer?.delegate = self
//            totalSecond = Int(soundPlayer.duration)
//            soundPlayer.prepareToPlay()
//            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
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
        
        
        if totalSecond == 0 {
            timer?.invalidate()
            let stopIcon = SFSymbolCreator.setSFSymbolColor(symbolName: "play.circle", color: .green, size: 40)
            playBackButton.setImage(stopIcon, for: .normal)
            
            totalSecond = Int(AudioPlayer.shared.player.duration)
            hours = totalSecond / 3600
            minutes = (totalSecond % 3600) / 60
            seconds = (totalSecond % 3600) % 60
            countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

        }
        
//        print(totalSecond)
        hours = totalSecond / 3600
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        totalSecond = totalSecond - 1
        
    }
}
