//
//  NewRecording.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//

import UIKit
import AVFoundation
import iOSDropDown


class NewRecording: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let coreDataStack = CoreDataStack()
    
    let playbackButton = UIButton()
    var recordButton = UIButton()
    
    var deleteButton = UIButton()
    let saveButton = UIButton()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    var dropDown: DropDown!
    let uuid = UUID().uuidString
    
    let recordingTitle = UITextField()
    let recordingNote = UITextField()
    
    var selectedCategory: String? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setupUI()
        print(selectedCategory)

        UITextField.connectFields(fields: [recordingTitle, recordingNote])

        self.view.addSubview(playbackButton)
        playbackButton.setTitle("Play", for: .normal)
        playbackButton.backgroundColor = .green
        playbackButton.setTitleColor(.purple, for: .normal)
        playbackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100),
            playbackButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(deleteButton)
        deleteButton.setTitle("DELETE", for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.purple, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 170),
            deleteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(saveButton)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.backgroundColor = .green
        saveButton.setTitleColor(.purple, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 210),
            saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
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
        
        
    
        
        let valueLabel = UILabel()
        dropDown = DropDown(frame: CGRect(x: 110, y: 100, width: 200, height: 30)) // set frame
        dropDown.backgroundColor = .gray
        dropDown.placeholder = "Select Category"
        
        var categories = [String]()

        // The list of array to display. Can be changed dynamically
        
        coreDataStack.fetchAllRecordingCategories { (r) in
            switch r {
            case .failure(let error):
                print(error)
            case .success(let cate):
                for c in cate {
                    categories.append(c.category!)
                }
                categories.append("-OR- Type One In")
            }
        }
        
        dropDown.optionArray = categories

        
        view.addSubview(dropDown)
        if selectedCategory != nil {
                    dropDown.text = selectedCategory
                }

        // The the Closure returns Selected Index and String
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
        valueLabel.text = "Selected String: \(selectedText) \n index: \(index)"
            self.selectedCategory = selectedText
            }
        
    }
    
    @objc func deleteButtonTapped() {
        let fileManager = FileManager.default

        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        do {
            try fileManager.removeItem(at: audioFilename)
        } catch {
            
        }

    }
    
    @objc func saveButtonTapped() {
        if let category = selectedCategory {
            coreDataStack.fetchRecordingCategoryByTitle(categoryTitle: category) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let categoryObject):
                    let new = Recording(context: self.coreDataStack.managedContext)
                        new.date = Date()
                    new.recordingID = UUID(uuidString: self.uuid)
                        new.recordingParent = categoryObject.first
                    new.name = self.recordingTitle.text
                    new.note = self.recordingNote.text
                        self.coreDataStack.saveContext()
                }
            }
        } else {
            let newCategory = RecordingCategory(context: coreDataStack.managedContext)
            newCategory.category = dropDown.text
                    newCategory.categoryID = UUID()
                    coreDataStack.saveContext()
            
            coreDataStack.fetchRecordingCategoryByTitle(categoryTitle: dropDown.text!) { (r) in
                        switch r {
                            case .failure(let error):
                                print(error)
                            case .success(let categories):
                                let new = Recording(context: self.coreDataStack.managedContext)
                                    new.date = Date()
                                    new.recordingID = UUID(uuidString: self.uuid)
                                    new.recordingParent = categories.first
                                new.name = self.recordingTitle.text
                                new.note = self.recordingNote.text
                                    self.coreDataStack.saveContext()
                            }
        }
        }
        
    }
    
    private func setupUI() {
        recordingTitle.translatesAutoresizingMaskIntoConstraints = false
        recordingNote.translatesAutoresizingMaskIntoConstraints = false
        recordingTitle.setBottomBorder()
        recordingNote.setBottomBorder()
        recordingTitle.placeholder = "Title/Name (Optional)"
        recordingNote.placeholder = "Note (Optional)"
        

//        recordingTitle.borderStyle = .line
//        recordingTitle.backgroundColor = .blue
//        recordingNote.borderStyle = .line

//        recordingNote.backgroundColor = .blue
        
        self.view.addSubview(recordingTitle)
        self.view.addSubview(recordingNote)
        
        NSLayoutConstraint.activate([
            recordingTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingTitle.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -10),
            recordingTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            recordingNote.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingNote.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            recordingNote.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -70)
        ])
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
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
        
        print(dropDown.text)
        
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
