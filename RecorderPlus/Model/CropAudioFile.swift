//
//  CropAudioFile.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/21/21.
//

import AVFoundation

struct GetDocumentDir {
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

class CropAudioFile {
    
    public func exportAsset(_ asset: AVAsset, importUUID: String, exportUUID: String, start: Int64, end: Int64){
        let trimmedSoundFileUrl = GetDocumentDir.getDocumentsDirectory().appendingPathComponent("\(exportUUID).m4a")
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
        let audioUrl = GetDocumentDir.getDocumentsDirectory().appendingPathComponent("\(uuid).m4a")
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
