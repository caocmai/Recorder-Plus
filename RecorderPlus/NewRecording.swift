//
//  NewRecording.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//

import UIKit


class NewRecording: UIViewController {
    
    let recordingButton = UIButton()
    let playbackButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.view.addSubview(recordingButton)
        recordingButton.setTitle("Recording", for: .normal)
        recordingButton.backgroundColor = .blue
        recordingButton.setTitleColor(.orange, for: .normal)
        recordingButton.addTarget(self, action: #selector(recordingButtonTapped), for: .touchUpInside)
        recordingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordingButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            recordingButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(playbackButton)
        playbackButton.setTitle("Playback", for: .normal)
        playbackButton.backgroundColor = .orange
        playbackButton.setTitleColor(.purple, for: .normal)
        playbackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100),
            playbackButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    @objc func recordingButtonTapped() {
        print("recording")
    }
    
    @objc func playbackButtonTapped() {
        print("playback")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
