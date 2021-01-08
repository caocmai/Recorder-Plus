//
//  Recording+CoreDataProperties.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var recordingID: UUID?
    @NSManaged public var recordingParent: RecordingCategory?

}

extension Recording : Identifiable {

}
