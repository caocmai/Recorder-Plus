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
    
    var recordButton = UIButton()
    
//    var deleteButton = UIButton()
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
        UITextField.connectFields(fields: [recordingTitle, recordingNote])
        
        
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
        setupDropDown()
    }
    
    private func setupDropDown() {
        
        dropDown = DropDown() // set frame
        view.addSubview(dropDown)
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropDown.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            dropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            dropDown.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            dropDown.heightAnchor.constraint(equalToConstant: 50)
        ])
        dropDown.backgroundColor = .white
        dropDown.placeholder = "Select Topic"
        
        var categories = [String]()
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
        
        
        if selectedCategory != nil {
            dropDown.text = selectedCategory
        }
        
        // The the Closure returns Selected Index and String
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            self.selectedCategory = selectedText
        }
        
    }
    
    @objc func saveButtonTapped() {
        
        if recordButton.titleLabel?.text == "Re-record" {
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
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Note", message: "You need to start then stop recording to save", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated:true, completion: nil)        }
        
    }
    
    private func setupUI() {
        recordingTitle.translatesAutoresizingMaskIntoConstraints = false
        recordingNote.translatesAutoresizingMaskIntoConstraints = false
        recordingTitle.setBottomBorder()
        recordingNote.setBottomBorder()
        recordingTitle.placeholder = "Title/Name (Optional)"
        recordingNote.placeholder = "Note (Optional)"
        
        self.view.addSubview(recordingTitle)
        self.view.addSubview(recordingNote)
        
        NSLayoutConstraint.activate([
            recordingTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingTitle.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -120),
            recordingTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            recordingNote.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingNote.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            recordingNote.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50)
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
            
            recordButton.setTitle("Stop", for: .normal)
            let stopSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.fill", color: .red, size: 20)
            recordButton.setImage(stopSymbol, for: .normal)
            recordButton.setTitleColor(.red, for: .normal)

        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Re-record", for: .normal)
            recordButton.setTitleColor(.black, for: .normal)
            let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 20)
            recordButton.setImage(recordSymbol, for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    func loadRecordingUI() {
        self.view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
//        recordButton.backgroundColor = .orange
        recordButton.setTitleColor(.red, for: .normal)
        NSLayoutConstraint.activate([
            recordButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 50),
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        recordButton.setTitle("Record", for: .normal)
        let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 20)
        recordButton.setImage(recordSymbol, for: .normal)
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
    
}
