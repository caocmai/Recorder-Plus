//
//  NewRecording.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//

import UIKit
import AVFoundation


class NewRecording: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let playbackButton = UIButton()
    var recordButton = UIButton()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white

        self.view.addSubview(playbackButton)
        playbackButton.setTitle("Play", for: .normal)
        playbackButton.backgroundColor = .orange
        playbackButton.setTitleColor(.purple, for: .normal)
        playbackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100),
            playbackButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording2.m4a")
        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
        }
    }
    
    func loadRecordingUI() {
        self.view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.backgroundColor = .orange
        recordButton.setTitleColor(.purple, for: .normal)
        NSLayoutConstraint.activate([
            recordButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100),
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func recordingButtonTapped() {
        print("recording")
    }
    
    @objc func playbackButtonTapped() {
        print("playback")
        
        if playbackButton.titleLabel?.text == "Play" {
            playbackButton.setTitle("Stop", for: .normal)
            setupPlayer()
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            playbackButton.setTitle("Play", for: .normal)
        }
    }
    
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
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
