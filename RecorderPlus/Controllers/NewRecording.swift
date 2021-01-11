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
    var quickRec: Bool!
    
    var recordButton = UIButton()
    let saveButton = UIButton()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    var dropDown: DropDown!
    let uuid = UUID().uuidString
    
    let recordingTitle = UITextField()
    let recordingNote = UITextField()
    // currently hidden not used
    let instructionLabel = UILabel()
    let timerLabel = UILabel()
    
    var selectedCategory: RecordingCategory? = nil
    var recordingCategory = [RecordingCategory]()
    var categories = [String]()
    
    var timer: Timer!
    var time = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        UITextField.connectFields(fields: [recordingTitle, recordingNote])
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        recordButton.isHidden = false
                    } else {
                        // failed to record!
                        recordButton.isHidden = true
                    }
                }
            }
        } catch {
            // failed to record!
        }
        setupUI()
        setupDropDown()
        
        if quickRec == true {
            if audioRecorder == nil {
                startRecording()
            } else {
                finishRecording(success: true)
            }
        }
    }
    
    private func setupDropDown() {
        
        coreDataStack.fetchAllRecordingCategories { (r) in
            switch r {
            case .failure(let error):
                print(error)
            case .success(let cate):
                self.recordingCategory = cate
                for c in cate {
                    self.categories.append(c.category!)
                }
            //                self.categories.append("-OR- Type One In")
            }
        }
        
        dropDown.optionArray = categories
        
        if selectedCategory != nil {
            dropDown.text = selectedCategory?.category
        }
        
        // The the Closure returns Selected Index and String
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            self.selectedCategory?.category = selectedText
        }
    }
    
    @objc func saveButtonTapped() {
        
        if recordButton.titleLabel?.text == "Re-record" {
            
            if dropDown.text == "" {
                if quickRec == true {
                    unknownTopicSaves(recordingTopic: "QuickREC", recordingKey: "quickRecTopicId")
                } else {
                    unknownTopicSaves(recordingTopic: "Unknown", recordingKey: "unknownTopicId")
                }
            } else {
                var categoryFound = false
                for category in recordingCategory{
                    if dropDown.text == category.category {
                        categoryFound = true
                        let new = Recording(context: self.coreDataStack.managedContext)
                        new.date = Date()
                        new.recordingID = UUID(uuidString: self.uuid)
                        new.recordingParent = category
                        new.name = self.recordingTitle.text
                        new.note = self.recordingNote.text
                        self.coreDataStack.saveContext()
                    }
                }
                
                if categoryFound == false {
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
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Note", message: "You need to start then stop recording to save", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    private func unknownTopicSaves(recordingTopic: String, recordingKey: String) {
        let unknownTopicId = UserDefaults.standard.string(forKey: recordingKey)
        
        if let validUnknownTopic = unknownTopicId {
            coreDataStack.fetchRecordingCategoryByID(identifier: UUID(uuidString: validUnknownTopic)!) { (r) in
                switch r {
                case .failure(let error):
                    print(error)
                case .success(let recordings):
                    let new = Recording(context: self.coreDataStack.managedContext)
                    new.date = Date()
                    new.recordingID = UUID(uuidString: self.uuid)
                    new.recordingParent = recordings.first
                    new.name = self.recordingTitle.text
                    new.note = self.recordingNote.text
                    self.coreDataStack.saveContext()                }
            }
            
        } else {
            let newTopic = RecordingCategory(context: coreDataStack.managedContext)
            newTopic.category = recordingTopic
            let uuid = UUID()
            newTopic.categoryID = uuid
            UserDefaults.standard.set(uuid.uuidString, forKey: recordingKey)
            coreDataStack.saveContext()
            
            coreDataStack.fetchRecordingCategoryByID(identifier: uuid) { (r) in
                switch r {
                case .failure(let error):
                    print(error)
                case .success(let recordings):
                    let new = Recording(context: self.coreDataStack.managedContext)
                    new.date = Date()
                    new.recordingID = UUID(uuidString: self.uuid)
                    new.recordingParent = recordings.first
                    new.name = self.recordingTitle.text
                    new.note = self.recordingNote.text
                    self.coreDataStack.saveContext()                   }
            }
        }
    }
    
    private func setupUI() {
        //        self.view.addSubview(instructionLabel)
        self.view.addSubview(recordingTitle)
        self.view.addSubview(recordingNote)
        self.view.addSubview(recordButton)
        self.view.addSubview(timerLabel)
        self.view.addSubview(saveButton)
        
        dropDown = DropDown()
        self.view.addSubview(dropDown)
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        //        dropDown.font = UIFont.systemFont(ofSize: 20.0)
        dropDown.font = UIFont.boldSystemFont(ofSize: 21)
        
        
        dropDown.backgroundColor = .white
        dropDown.placeholder = "Select or Type-In New Topic"
        
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.layer.cornerRadius = 5
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        recordingTitle.translatesAutoresizingMaskIntoConstraints = false
        recordingNote.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        timerLabel.text = "00:00:00"
        
        recordButton.setTitleColor(.red, for: .normal)
        recordButton.setTitle("Record", for: .normal)
        let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 60)
        recordButton.setImage(recordSymbol, for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        recordingTitle.setBottomBorder()
        recordingNote.setBottomBorder()
        recordingTitle.placeholder = "Title/Name (Optional)"
        recordingNote.placeholder = "Note (Optional)"
        
        recordingTitle.font = UIFont.systemFont(ofSize: 21)
        recordingNote.font = UIFont.systemFont(ofSize: 16)
        
        instructionLabel.text = "Select an existing Topic or input a new Topic"
        instructionLabel.textColor = .lightGray
        instructionLabel.numberOfLines = 0
        instructionLabel.font = instructionLabel.font.withSize(15)
        
        
        
        NSLayoutConstraint.activate([
            
            //            instructionLabel.bottomAnchor.constraint(equalTo: dropDown.topAnchor, constant: 5),
            //            instructionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            //            instructionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            
            
            recordingTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingTitle.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -120),
            recordingTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            dropDown.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            dropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            dropDown.bottomAnchor.constraint(equalTo: recordingTitle.topAnchor, constant: -26),
            dropDown.heightAnchor.constraint(equalToConstant: 50),
            
            recordingNote.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingNote.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            recordingNote.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            
            recordButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 50),
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -50),
            
            saveButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 210),
            saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 180),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        instructionLabel.isHidden = true
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
        
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
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
            recordButton.setTitle("Stop", for: .normal)
            let stopSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.fill", color: .red, size: 60)
            recordButton.setImage(stopSymbol, for: .normal)
            recordButton.setTitleColor(.red, for: .normal)
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    @objc func updateTimer() {
        time += 1
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            timer.invalidate()
            time = 0
            recordButton.setTitle("Re-record", for: .normal)
            recordButton.setTitleColor(.black, for: .normal)
            let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 60)
            recordButton.setImage(recordSymbol, for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    
    
    @objc func recordTapped() {
        
//        print(dropDown.text)
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
}
