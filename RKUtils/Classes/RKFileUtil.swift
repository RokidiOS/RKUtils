//
//  RKFileUtil.swift
//  RKUtils
//
//  Created by chzy on 2021/11/4.
//

import Foundation
import UIKit

public class RKFileUtil: NSObject {
    public class func getDocumentPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir  = paths.first
        return docDir!
    }
    
    public class func getDirectoryForDocuments(dir: String) -> String {
        let docPath:NSString = RKFileUtil.getDocumentPath() as NSString
        let dirPath = docPath.appendingPathComponent(dir)
        var isDir:ObjCBool = false
        let isCreated = FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir)
        if isDir.boolValue == false || isCreated == false {
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }
        return dirPath
    }
    
    
    public class func fileDir() -> String {
        return getDirectoryForDocuments(dir: "/file")
    }
    
    public class func randomAudioPath() -> String {
        let uuid = NSUUID().uuidString
        return RKFileUtil.fileDir() + "/" + uuid + ".aac"
    }
    
    public class func randomImagePath() -> String {
        let uuid = NSUUID().uuidString
        return RKFileUtil.fileDir() + "/" + uuid + ".png"
    }
    
    public class func randomVideoPath() -> String {
        let uuid = NSUUID().uuidString
        return RKFileUtil.fileDir() + "/" + uuid + ".MP4"
    }
    
    public class func randomThubmPath() -> String {
        let uuid = NSUUID().uuidString
        return RKFileUtil.fileDir() + "/" + uuid + ".png"
    }
    
    public class func randomBroserImagePath() -> (String, String) {
        let uuid = NSUUID().uuidString
        
        return (RKFileUtil.fileDir() + "/" + uuid + ".png", uuid)
    }
    
    public class func getBrowserImagePath(_ uuid: String) -> String {
        return RKFileUtil.fileDir() + "/" + uuid + ".png"

    }
}

