//
//  RKAuthorizationManager.swift
//  RokidSDK
//
//  Created by chzy on 2021/10/18.
//

import Foundation
import AVKit
import Photos

public enum RKAuthorizationType: Int {
    case camera ///相机
    case album ///相册
}


/// 获取权限
public class RKAuthorizationManager: NSObject {
    public class func authorization(_ mediaType: RKAuthorizationType, _ compeletBlock:@escaping (Bool) ->Void) {
        switch mediaType {
        case .camera:
            cameraAuthoriztion(compeletBlock)
        case .album:
            albumAuthoriztion(compeletBlock)
        }
    }
    
    public class func cameraAuthoriztion(_ compeletBlock:@escaping (Bool) ->Void) {
        let authStatus =  AVCaptureDevice.authorizationStatus(for: .video)
        // .notDetermined  .authorized  .restricted  .denied
           if authStatus == .notDetermined {
               // 第一次触发授权 alert
               AVCaptureDevice.requestAccess(for: .video) { granted in
                   DispatchQueue.main.async {
                       compeletBlock(granted)
                   }
               }
           } else if authStatus == .authorized {
              compeletBlock(true)
           } else {
              compeletBlock(false)
           }
    }
    
    public class func albumAuthoriztion(_ compeletBlock:@escaping  (Bool) ->Void) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
       // .notDetermined  .authorized  .restricted  .denied .limited
       if authStatus == .notDetermined {
           // 第一次触发授权 alert
           PHPhotoLibrary.requestAuthorization { granted in
               DispatchQueue.main.async {
                   compeletBlock(granted != .denied || granted != .restricted)
               }
           }
       } else if authStatus == .authorized  {
           compeletBlock(true)
       } else {
           compeletBlock(true)
       }
        
    }
}
