//
//  Note+CoreDataProperties.swift
//  
//
//  Created by 李现科 on 2017/3/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note");
    }

    @NSManaged public var albumOrder: NSNumber?
    @NSManaged public var content: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var data: NSData?
    @NSManaged public var hasDeleted: NSNumber?
    @NSManaged public var icon: NSData?
    @NSManaged public var lastSyncDate: NSDate?
    @NSManaged public var localPath: String?
    @NSManaged public var order: NSNumber?
    @NSManaged public var syncStatus: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var uuid: String?
    @NSManaged public var album: Album?
    @NSManaged public var tags: NSOrderedSet?

}

// MARK: Generated accessors for tags
extension Note {

    @objc(insertObject:inTagsAtIndex:)
    @NSManaged public func insertIntoTags(_ value: Tag, at idx: Int)

    @objc(removeObjectFromTagsAtIndex:)
    @NSManaged public func removeFromTags(at idx: Int)

    @objc(insertTags:atIndexes:)
    @NSManaged public func insertIntoTags(_ values: [Tag], at indexes: NSIndexSet)

    @objc(removeTagsAtIndexes:)
    @NSManaged public func removeFromTags(at indexes: NSIndexSet)

    @objc(replaceObjectInTagsAtIndex:withObject:)
    @NSManaged public func replaceTags(at idx: Int, with value: Tag)

    @objc(replaceTagsAtIndexes:withTags:)
    @NSManaged public func replaceTags(at indexes: NSIndexSet, with values: [Tag])

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSOrderedSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSOrderedSet)

}
