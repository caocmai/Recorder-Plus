//
//  NewRecording.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//

import UIKit
import AVFoundation
import iOSDropDown
import RangeSeekSlider


class NewRecording: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let recordingTitle = UITextField()
    let recordingNote = UITextField()
    let timerLabel = UILabel()
    let recordButton = UIButton()
    let saveButton = UIButton()
    var coreDataStack: CoreDataStack!
    var quickRec: Bool!
    var editRecording: Recording!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var dropDown: DropDown!
    var uuid = UUID().uuidString
    var selectedCategory: RecordingCategory? = nil
    var recordingCategory = [RecordingCategory]()
    var categories = [String]()
    var timer: Timer!
    var time = 0
    var rangeSeekSlider = RangeSeekSlider()
    var recordingDuration = Float64()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.view.backgroundColor = .white
        UITextField.connectFields(fields: [recordingTitle, recordingNote])
        
        recordingSession = AVAudioSession.sharedInstance()
        // ask for recording permission
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
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //
    //        if self.isMovingFromParent {
    //            // to delete temp recording file that wasn't saved
    //            let fileManager = FileManager.default
    //            let audioFilename = self.getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
    //            do {
    //                try fileManager.removeItem(at: audioFilename)
    //            } catch {
    //               print("file not found to delete")
    //            }
    //        }
    //    }
    

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
            }
        }
        
        dropDown.optionArray = categories
        
        if selectedCategory != nil {
            dropDown.text = selectedCategory?.category
        }
        
        // the closure to get selected item
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            self.selectedCategory?.category = selectedText
        }
    }
    
    // - MARK: Save/Update Button

    @objc func saveButtonTapped() {
//        print(recordingDuration)
        if rangeSeekSlider.selectedMinValue != 0 || rangeSeekSlider.selectedMaxValue != CGFloat(recordingDuration) {
            let newTrimmedRecId = UUID().uuidString
            let asset = AVURLAsset(url: getDocumentsDirectory().appendingPathComponent(uuid+".m4a"))
            exportAsset(asset, importUUID: uuid, exportUUID: newTrimmedRecId, start: Int64(rangeSeekSlider.selectedMinValue), end: Int64(rangeSeekSlider.selectedMaxValue))
            uuid = newTrimmedRecId
        }
        
        if saveButton.currentTitle == "UPDATE"  {
            editRecording.name = recordingTitle.text
            editRecording.note = recordingNote.text
            editRecording.recordingID = UUID(uuidString: uuid)
            coreDataStack.saveContext()
            self.navigationController?.popViewController(animated: true)
        } else {
            if recordButton.titleLabel?.text == "Re-record" {
                if saveButton.currentTitle == "UPDATE"  {
                    editRecording.name = recordingTitle.text
                    editRecording.note = recordingNote.text
                    editRecording.recordingID = UUID(uuidString: uuid)
                    coreDataStack.saveContext()
                    self.navigationController?.popViewController(animated: true)
                }
                
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
                            self.createNewRecording(withUUID: self.uuid, topic: category)
                        }
                    }
                    if categoryFound == false {
                        let categoryUUID = UUID()
                        createNewRecordingTopic(withUUID: categoryUUID, recordingTopic: dropDown.text!)
                        coreDataStack.fetchRecordingCategoryByID(identifier: categoryUUID) { (results) in
                            switch results {
                            case .failure(let error):
                                print(error)
                            case .success(let categories):
                                self.createNewRecording(withUUID: self.uuid, topic: categories.first!)
                            }
                        }
                    }
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Caution", message: "You need to start then stop recording to save", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated:true, completion: nil)
            }
        }
    }
    
    private func unknownTopicSaves(recordingTopic: String, recordingKey: String) {
        let unknownTopicId = UserDefaults.standard.string(forKey: recordingKey)
        
        if let validUnknownTopic = unknownTopicId {
            coreDataStack.fetchRecordingCategoryByID(identifier: UUID(uuidString: validUnknownTopic)!) { (results) in
                switch results {
                case .failure(let error):
                    print(error)
                case .success(let recordings):
                    self.createNewRecording(withUUID: self.uuid, topic: recordings.first!)
                }
            }
            
        } else {
            let categoryUUID = UUID()
            createNewRecordingTopic(withUUID: categoryUUID, recordingTopic: recordingTopic)
            UserDefaults.standard.set(categoryUUID.uuidString, forKey: recordingKey)

            coreDataStack.fetchRecordingCategoryByID(identifier: categoryUUID) { (results) in
                switch results {
                case .failure(let error):
                    print(error)
                case .success(let recordings):
                    self.createNewRecording(withUUID: self.uuid, topic: recordings.first!)
                }
            }
        }
    }
    
    private func createNewRecording(withUUID uuid: String, topic: RecordingCategory) {
        let new = Recording(context: self.coreDataStack.managedContext)
        new.date = Date()
        new.recordingID = UUID(uuidString: uuid)
        new.recordingParent = topic
        new.name = self.recordingTitle.text
        new.note = self.recordingNote.text
        self.coreDataStack.saveContext()
    }
    
    private func createNewRecordingTopic(withUUID uuid: UUID, recordingTopic: String) {
        let newTopic = RecordingCategory(context: coreDataStack.managedContext)
        newTopic.category = recordingTopic
        newTopic.categoryID = uuid
        coreDataStack.saveContext()
    }
    
    
    // - MARK: Setup UI

    private func setupUI() {
        self.view.addSubview(recordingTitle)
        self.view.addSubview(recordingNote)
        self.view.addSubview(recordButton)
        self.view.addSubview(timerLabel)
        self.view.addSubview(saveButton)
        self.view.addSubview(rangeSeekSlider)
        self.view.addSubview(dropDown)

        dropDown = DropDown()
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        dropDown.font = UIFont.boldSystemFont(ofSize: 21)
        dropDown.backgroundColor = .white
        dropDown.placeholder = "Select or Type-In New Topic"
        
        saveButton.backgroundColor = #colorLiteral(red: 0.2055417001, green: 1, blue: 0, alpha: 1)
        saveButton.setTitleColor(.gray, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.layer.cornerRadius = 5
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        recordingTitle.translatesAutoresizingMaskIntoConstraints = false
        recordingNote.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        rangeSeekSlider.translatesAutoresizingMaskIntoConstraints = false

        rangeSeekSlider.tintColor = .lightGray
        rangeSeekSlider.colorBetweenHandles = #colorLiteral(red: 0.2055417001, green: 1, blue: 0, alpha: 1)
        //        rangeSeekSlider.handleColor = .blue
        rangeSeekSlider.lineHeight = 5
        rangeSeekSlider.isHidden = true
        
        timerLabel.font = UIFont.systemFont(ofSize: 25)
        timerLabel.text = "00:00:00"
        
        recordButton.setTitleColor(.red, for: .normal)
        recordButton.setTitle("Record", for: .normal)
        let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 60)
        recordButton.setImage(recordSymbol, for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        recordingTitle.setBottomBorder()
        recordingTitle.placeholder = "Title/Name (Optional)"
        recordingTitle.font = UIFont.systemFont(ofSize: 21)
        
        recordingNote.setBottomBorder()
        recordingNote.placeholder = "Note (Optional)"
        recordingNote.font = UIFont.systemFont(ofSize: 16)
        
        if let validEditRecording = editRecording {
            rangeSeekSlider.isHidden = false
            saveButton.setTitle("UPDATE", for: .normal)
            recordButton.setTitle("Re-record", for: .normal)
            recordingTitle.text = validEditRecording.name
            recordingNote.text = validEditRecording.note
            
            uuid = validEditRecording.recordingID!.uuidString
            let asset = AVURLAsset(url: getDocumentsDirectory().appendingPathComponent(uuid+".m4a"))
            
            recordingDuration = CMTimeGetSeconds(asset.duration)
            rangeSeekSlider.maxValue = CGFloat(recordingDuration)
            dropDown.text = validEditRecording.recordingParent?.category
            
        } else {
            saveButton.setTitle("SAVE", for: .normal)
        }
        
        NSLayoutConstraint.activate([
            dropDown.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            dropDown.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            dropDown.bottomAnchor.constraint(equalTo: recordingTitle.topAnchor, constant: -26),
            dropDown.heightAnchor.constraint(equalToConstant: 50),
            
            recordingTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            recordingTitle.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -120),
            recordingTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
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
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            rangeSeekSlider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -5),
            rangeSeekSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            rangeSeekSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func startRecording() {
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
    
    private func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            timer.invalidate()
            time = 0
            recordButton.setTitle("Re-record", for: .normal)
            recordButton.setTitleColor(.black, for: .normal)
            let recordSymbol = SFSymbolCreator.setSFSymbolColor(symbolName: "stop.circle.fill", color: .red, size: 60)
            recordButton.setImage(recordSymbol, for: .normal)
            
            let audioFilename = getDocumentsDirectory().appendingPathComponent(uuid+".m4a")
            print(audioFilename)
            let asset = AVURLAsset(url: getDocumentsDirectory().appendingPathComponent(uuid+".m4a"))
            recordingDuration = CMTimeGetSeconds(asset.duration)
            
            rangeSeekSlider.maxValue = CGFloat(recordingDuration)
            rangeSeekSlider.selectedMaxValue = CGFloat(recordingDuration)
            rangeSeekSlider.isHidden = false
            
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

// - MARK: Cropping Audio File

extension NewRecording {
    private func exportAsset(_ asset: AVAsset, importUUID: String, exportUUID: String, start: Int64, end: Int64){
        let trimmedSoundFileUrl = getDocumentsDirectory().appendingPathComponent("\(exportUUID).m4a")
        //                print("Saving to \(trimmedSoundFileUrl.absoluteString)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A){
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileUrl
            
            let startTime = CMTimeMake(value: start, timescale: 1)
            let stopTime = CMTimeMake(value: end, timescale: 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
            
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    if let e = exporter.error {
                        print("export failed \(e)")
                    }
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(String(describing: exporter.error))")
                default:
                    print("export complete")
                    self.deleteFileAlreadyPresent(uuid: importUUID)
                }
            })
        } else{
            print("cannot create AVAssetExportSession for asset \(asset)")
        }
    }
    
    private func deleteFileAlreadyPresent(uuid: String){
        let audioUrl = getDocumentsDirectory().appendingPathComponent("\(uuid).m4a")
        if FileManager.default.fileExists(atPath: audioUrl.path){
//            print("Sound exists, removing \(audioUrl.path)")
            do{
                if try audioUrl.checkResourceIsReachable(){
                    print("is reachable and deleting")
                    try FileManager.default.removeItem(at: audioUrl)
                }
            } catch{
                print("Could not remove \(audioUrl.absoluteString)")
            }
        }
    }
}
