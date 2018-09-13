//
//  PermissionManager.swift
//  RealSimple
//
//  Created by Y Media Labs on 5/20/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
//import Contacts

/**
 *  A protocol which any service can conform to.
 */
//MARK:- PermissionService
protocol PermissionService: class {
    
    var requestedPermission: Bool {get set}
    func status() -> PermissionStatus
    func requestPermission(_ completion: PermissionCompletionBlock)
}

typealias PermissionCompletionBlock = ((PermissionStatus) -> Void)?

//MARK:- PermissionType
enum PermissionType: String {
    
    case Photos
    case Camera
    
    var permissionService: PermissionService {
        var service: PermissionService!
        
        switch self {
        case .Photos:
            service = PhotosPermissionService()
        case .Camera:
            service = CameraPermissionService()
        }
        
        return service
    }
}

enum PermissionStatus: String {
    
    /// User has not yet made a choice with regards to this application
    case NotDetermined
    
    /// User has explicitly denied this application access
    case Unauthorized
    
    /// User has disabled this services at settings level
    case Disabled
    
    /// User has authorized this application
    case Authorized
}

/******************/
//MARK:- Camera
/******************/
class CameraPermissionService: PermissionService {
    
    var requestedPermission: Bool = false
    
    func status() -> PermissionStatus {
        var permissionStatus: PermissionStatus = .NotDetermined
        
        let serviceStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch serviceStatus {
        case .authorized:
            permissionStatus = .Authorized
        case .restricted, .denied:
            permissionStatus = .Unauthorized
        case .notDetermined:
            permissionStatus = .NotDetermined
        }
        
        return permissionStatus
    }
    
    func requestPermission(_ completion: PermissionCompletionBlock) {
        let permissionsStatus = status()
        
        switch permissionsStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                self.requestedPermission = true
                let status = self.status()
                completion?(status)
            })
        case .Unauthorized:
            //Show some alert
            fallthrough
        default:
            completion?(permissionsStatus)
        }
    }
}

/******************/
//MARK:- Photos
/******************/
class PhotosPermissionService: PermissionService {
    
    var requestedPermission: Bool = false
    
    func status() -> PermissionStatus {
        var permissionStatus: PermissionStatus = .NotDetermined
        
        let serviceStatus = PHPhotoLibrary.authorizationStatus()
        
        switch serviceStatus {
        case .authorized:
            permissionStatus = .Authorized
        case .restricted, .denied:
            permissionStatus = .Unauthorized
        case .notDetermined:
            permissionStatus = .NotDetermined
        }
        
        return permissionStatus
    }
    
    func requestPermission(_ completion: PermissionCompletionBlock) {
        let permissionsStatus = status()
        
        switch permissionsStatus {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.requestedPermission = true
                let status = self.status()
                completion?(status)
            })
        case .Unauthorized:
            //Show some alert
            fallthrough
        default:
            completion?(permissionsStatus)
        }
    }
}

class AudioPermission: PermissionService {

    var requestedPermission: Bool = false

    func status() -> PermissionStatus {
        var permissionStatus: PermissionStatus = .NotDetermined

        let serviceStatus = AVAudioSession.sharedInstance().recordPermission()

        switch serviceStatus {
        case AVAudioSessionRecordPermission.denied:
            permissionStatus = .Unauthorized
        case AVAudioSessionRecordPermission.granted:
            permissionStatus = .Authorized
        case AVAudioSessionRecordPermission.undetermined:
            permissionStatus = .NotDetermined
        }

        return permissionStatus
    }

    func requestPermission(_ completion: PermissionCompletionBlock) {
        let permissionsStatus = status()

        switch permissionsStatus {
        case .NotDetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                self.requestedPermission = true
                let status = self.status()
                completion?(status)
            })
        case .Unauthorized:
            //Show some alert
            fallthrough
        default:
            completion?(permissionsStatus)
        }
    }
}
