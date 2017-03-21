//
//  LXKFileManager.swift
//  HappyShare
//
//  Created by 李现科 on 16/1/20.
//  Copyright © 2016年 李现科. All rights reserved.
//

import Foundation

protocol FileNameType {
    
}

enum FileType: String,FileNameType {
    enum Image: String,FileNameType {
        case Gif
        case Tiff
        case JPG
        case CUR
        case ICO
        case PNG
    }
    enum Audio: String,FileNameType {
        case MP3
        case AAC
        case AIFF
        case WAV
        case M4A
    }
    enum Video: String,FileNameType {
        case MP4
        case MOV
        case M4V
        case ThreeGP
    }
    case HTML
    case None
}

extension NSData {
    
    var fileType: FileNameType {
        var oneToEight = (UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0))
        self.getBytes(&oneToEight, length: 8 * MemoryLayout.size(ofValue: UInt8.allZeros))
        switch oneToEight {
        case (0x49,0x20,0x49,_,_,_,_,_),(0x49,0x49,0x2A,0x00,_,_,_,_),(0x4D,0x4D,0x00,0x2A,_,_,_,_),(0x4D,0x4D,0x00,0x2B,_,_,_,_): return FileType.Image.Tiff
        case (0xFF,0xD8,0xFF,0xE0,_,_,0x4A,0x46): return FileType.Image.JPG
        case (0x49,0x44,0x33,_,_,_,_,_),(0x49,0xE0...0xFF,_,_,_,_,_,_): return FileType.Audio.MP3
        case (0xFF,0xF1,_,_,_,_,_,_),(0xFF,0xF9,_,_,_,_,_,_): return FileType.Audio.AAC
        case (0x46,0x4F,0x52,0x4D,0x00,_,_,_): return FileType.Audio.AIFF
        case (0x52,0x49,0x46,0x46,_,_,_,_): return FileType.Audio.WAV // 57 41 56 45 66 6D 74 20
        case (_,_,_,_,0x66,0x74,0x79,0x70):
            var nineToTwelve = (UInt8(0),UInt8(0),UInt8(0),UInt8(0))
            self.getBytes(&nineToTwelve, range: NSMakeRange(8,4))
            switch nineToTwelve {
            case (0x33,0x67,0x70,_): return FileType.Video.ThreeGP
            case (0x4D,0x34,0x41,0x20): return FileType.Audio.M4A
            default: return FileType.None
            }
        default: return FileType.None
        }
    }
    
    var fileHeader: String? {
        var cArray = [UInt8](repeating: 0 ,count: 8)
        self.getBytes(&cArray, length: 8 * MemoryLayout.size(ofValue: UInt8.allZeros))
        return String(describing: cArray)
    }
}
