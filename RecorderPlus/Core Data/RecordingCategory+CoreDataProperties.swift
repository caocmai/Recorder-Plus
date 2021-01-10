//
//  RecordingCategory+CoreDataProperties.swift
//  
//
//  Created by Cao Mai on 1/9/21.
//
//

import Foundation
import CoreData


extension RecordingCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordingCategory> {
        return NSFetchRequest<RecordingCategory>(entityName: "RecordingCategory")
    }

    @NSManaged public var category: String?
    @NSManaged public var categoryID: UUID?
    @NSManaged public var recordings: NSSet?

}

// MARK: Generated accessors for recordings
extension RecordingCategory {

    @objc(addRecordingsObject:)
    @NSManaged public func addToRecordings(_ value: Recording)

    @objc(removeRecordingsObject:)
    @NSManaged public func removeFromRecordings(_ value: Recording)

    @objc(addRecordings:)
    @NSManaged public func addToRecordings(_ values: NSSet)

    @objc(removeRecordings:)
    @NSManaged public func removeFromRecordings(_ values: NSSet)

}
