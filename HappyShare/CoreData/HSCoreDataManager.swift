//
//  HSCoreDataManager.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/15.
//  Copyright © 2016年 李现科. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Enum NoteType
enum NoteType: String {
    case Photo
    case URL
    case Record
    case Words
    case None
}

//MARK: - Enum CoreDataKeys
private enum CoreDataKeys: String {
    case TagEntity = "Tag"
    case AlbumEntity = "Album"
    case NoteEntity = "Note"
    case TagNameKey = "name"
    case CreateDateKey = "createDate"
    case OrderKey = "order"
    case NoteAlbumOrderKey = "albumOrder"
    case NoteAlbumKey = "album"
    case NoteTagsKey = "tags"
    case NoteTypeKey = "type"
    case AlbumIsDefaultKey = "isDefault"
}


class HSCoreDataManager: LXKCoreDataManager {
    
    static let sharedManager = HSCoreDataManager()
    
    private override init() {
        super.init()
    }
}

// MARK: - Tag
extension HSCoreDataManager {
    
    func addNewTag(name: String) -> Tag? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let tag = NSEntityDescription.insertNewObject(forEntityName: CoreDataKeys.TagEntity.rawValue, into: managedObjectContext) as? Tag
        tag?.name = name
        saveContext()
        return tag
    }
    
    func deleteTag(tag: Tag) -> Bool {
        managedObjectContext?.delete(tag)
        return saveContext()
    }
    
    func allTags(byHot: Bool) -> [Tag]? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Tag>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.TagEntity.rawValue, in: managedObjectContext)
        if !byHot {
            let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.TagNameKey.rawValue, ascending: true)
            request.sortDescriptors = [sortDescriptor]
        }
        do {
            var tags = try managedObjectContext.fetch(request)
            if byHot {
                tags = tags.sorted(by: {
                    ($0.notes?.count ?? 0) > ($1.notes?.count ?? 0)
                })
            }
            return tags
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
        
    }
    
}

// MARK: - Album
extension HSCoreDataManager {
    
    var defaultAlbum: Album? {
        get {
            guard let managedObjectContext = managedObjectContext else {
                return nil
            }
            let request = NSFetchRequest<Album>()
            request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.AlbumEntity.rawValue, in: managedObjectContext)
            request.predicate = NSPredicate(format: "%K = TRUE", argumentArray: [CoreDataKeys.AlbumIsDefaultKey.rawValue])
            request.fetchLimit = 1
            do {
                let albums = try managedObjectContext.fetch(request)
                return albums.first
            } catch let error {
                print("Error retrieving Reminders \(error)")
                return nil
            }
        }
    }
    
    func addNewAlbum(name: String, picture: NSData?) -> Album? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let album = NSEntityDescription.insertNewObject(forEntityName: CoreDataKeys.AlbumEntity.rawValue, into: managedObjectContext) as? Album
        album?.createDate = NSDate()
        album?.name = name
        album?.order = allAlbums()?.count as NSNumber?
        saveContext()
        return album
    }
    
    func deleteAlbum(album: Album) -> Bool {
        managedObjectContext?.delete(album)
        return saveContext()
    }
    
    func allAlbums() -> [Album]? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Album>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.AlbumEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.OrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            let albums = try managedObjectContext.fetch(request)
            return albums
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
    }
    
    func createDefaultAlbum() -> Album? {
        guard let managedObjectContext = managedObjectContext, defaultAlbum == nil else {
            return defaultAlbum
        }
        let album = NSEntityDescription.insertNewObject(forEntityName: CoreDataKeys.AlbumEntity.rawValue, into: managedObjectContext) as? Album
        album?.createDate = NSDate()
        album?.name = "待阅箱"
        album?.order = allAlbums()?.count as NSNumber?
        album?.isDefault = true
        saveContext()
        return album
    }
    
}

// MARK: - Note 
extension HSCoreDataManager {
        
    func addNewNote(title: String?, icon: NSData?, content:String?, url: String?, type: NoteType.RawValue, data: NSData?, album: Album?, tags: [Tag]?) -> Note? {
        var album = album
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let note = NSEntityDescription.insertNewObject(forEntityName: CoreDataKeys.NoteEntity.rawValue, into: managedObjectContext) as? Note
        album = album ?? defaultAlbum
        note?.title = title
        note?.icon = icon
        note?.content = content
        note?.url = url
        note?.type = type
        note?.data = data
        note?.album = album
        if let tags = tags {
            note?.tags = NSOrderedSet(array: tags)
        }
        note?.order = allNotes()?.count as NSNumber?
        note?.albumOrder = album?.notes?.count as NSNumber?
        note?.uuid = generateUUID()
        saveContext()
        return note
    }
    
    func modifyNote(note: Note?, title: String?, icon: NSData?, content:String?, url: String?, type: NoteType.RawValue, data: NSData?, album: Album?, tags: [Tag]?) -> Note? {
        var album = album
        album = album ?? defaultAlbum
        note?.title = title
        note?.icon = icon
        note?.content = content
        note?.url = url
        note?.type = type
        note?.data = data
        note?.album = album
        if let tags = tags {
            note?.tags = NSOrderedSet(array: tags)
        }
        saveContext()
        return note
    }
    
    func deleteNote(note: Note) -> Bool {
        managedObjectContext?.delete(note)
        return saveContext()
    }
    
    func moveNote(note: Note,toOrder order: Int) -> Bool {
        
        note.syncStatus = false
        return saveContext()
    }
    
    func moveNote(note: Note?,toAlbum album: Album) -> Bool {
        note?.album = album
        note?.syncStatus = false
        return saveContext()
    }
    
    func deleteTag(tag: Tag, inNote note: inout Note?) -> Bool {
        if let oldTags = note?.tags?.mutableCopy() as? NSMutableOrderedSet {
            oldTags.remove(tag)
            note?.tags = oldTags.copy() as? NSOrderedSet
            note?.syncStatus = false
        }
        return saveContext()
    }
    
    func addTag(tag: Tag,toNote note: Note?) -> Bool {
        if let oldTags = note?.tags?.mutableCopy() as? NSMutableOrderedSet {
            oldTags.add(tag)
            note?.tags = oldTags.copy() as? NSOrderedSet
        }
        return saveContext()
    }
    
    func allNotes() -> [Note]? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Note>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.NoteEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.OrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            let notes = try managedObjectContext.fetch(request)
            return notes
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
    }
    
    func notesInAlbum(album: Album?) -> [Note]? {
        guard let album = album else {
            return nil
        }
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Note>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.NoteEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.NoteAlbumOrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [CoreDataKeys.NoteAlbumKey.rawValue,album])
        do {
            let notes = try managedObjectContext.fetch(request)
            return notes
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
    }
    
    func notesWithTag(tag: Tag?) -> [Note]? {
        guard let tag = tag else {
            return nil
        }
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Note>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.NoteEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.OrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "%K CONTAINS %@", argumentArray: [CoreDataKeys.NoteTagsKey.rawValue,tag])
        do {
            let notes = try managedObjectContext.fetch(request)
            return notes
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
    }
    
    func notesWithType(type: NoteType?) -> [Note]? {
        guard let type = type else {
            return nil
        }
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        let request = NSFetchRequest<Note>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.NoteEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.NoteAlbumOrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [CoreDataKeys.NoteTypeKey.rawValue,type.rawValue])
        do {
            let notes = try managedObjectContext.fetch(request)
            return notes
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return nil
        }
    }
    
    func noteCountWithType(type: NoteType?) -> Int {
        guard let type = type else {
            return 0
        }
        guard let managedObjectContext = managedObjectContext else {
            return 0
        }
        let request = NSFetchRequest<NSNumber>()
        request.entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.NoteEntity.rawValue, in: managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: CoreDataKeys.NoteAlbumOrderKey.rawValue, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "%COUNT(K = %@)", argumentArray: [CoreDataKeys.NoteTypeKey.rawValue,type.rawValue])
        do {
            let notes = try managedObjectContext.fetch(request)
            return notes.count
        } catch let error {
            print("Error retrieving Reminders \(error)")
            return 0
        }
    }
    
    func createDefaultNotes() -> Bool {
        if let exampleTag = addNewTag(name: "示例标签") {
            addNewNote(title: "", icon: nil, content: "", url: nil, type: NoteType.Words.rawValue, data: nil, album: nil, tags: [exampleTag])
            addNewNote(title: "", icon: nil, content: "", url: nil, type: NoteType.Words.rawValue, data: nil, album: nil, tags: [exampleTag])
            addNewNote(title: "", icon: nil, content: "", url: nil, type: NoteType.Words.rawValue, data: nil, album: nil, tags: [exampleTag])
            addNewNote(title: "", icon: nil, content: "", url: nil, type: NoteType.Words.rawValue, data: nil, album: nil, tags: [exampleTag])
        }
        return saveContext()
    }
}

func generateUUID() -> String {
    let uuid = CFUUIDCreate(kCFAllocatorDefault)
    return CFUUIDCreateString(kCFAllocatorDefault, uuid) as String
}



