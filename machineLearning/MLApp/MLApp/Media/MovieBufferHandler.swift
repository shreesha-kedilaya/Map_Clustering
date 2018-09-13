//
//  VideoFilterHandler.swift
//  FilterCam
//
//  Created by Shreesha on 17/09/16.
//  Copyright © 2016 YML. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

typealias CustomErrorCallback = ((Error?, BufferErrorHandler?) -> Void)

protocol BufferErrorHandler: Error, CustomStringConvertible {
    
}


enum MovieBufferErrorHandler: String, BufferErrorHandler {
    case CameraSessionInterrupted = "CaptureSession interupted"
    case FailedToAddCameraInput = "Failed To Add Camera Input"
    case FailedToAddCameraStillImageOutput = "Failed To Add Camera Still Image Output"
    case FailedToAddVideoCaptureOutput = "Failed To Add Video Capture Output"
    case FailedToAddAudioOutput = "Failed To Add Audio Output"
    case FailedToAddAudioInput = "Failed To Add Audio Input"
    case VideoPermissionFailed = "The Video permission failed"
    case AudioPermissionFailed = "The Audio permission failed"

    var description: String {
        return self.rawValue
    }
}

typealias BufferCallBack = (CMSampleBuffer) -> ()

class MovieBufferHandler: NSObject, CaptureVideoDelagateProtocol, CaptureAudioDelagateProtocol, AVCaptureMetadataOutputObjectsDelegate {

   
    private (set) var currentDevicePosition = AVCaptureDevice.Position.back
    private (set) var videoOrientation: AVCaptureVideoOrientation
    fileprivate var captureCameraInput: AVCaptureDeviceInput?
    fileprivate var captureAudioInput: AVCaptureDeviceInput?
    fileprivate var captureVideoDelegate: CaptureVideoBufferDelegate?
    fileprivate var captureAudioDelegate: CaptureAudioBufferDelegate?

    fileprivate lazy var cameraStillImageOutput = AVCapturePhotoOutput()
    fileprivate lazy var audioOutput = AVCaptureAudioDataOutput()
    fileprivate lazy var videoCaptureOutput = AVCaptureVideoDataOutput()
    private(set) lazy var cameraCaptureSession: AVCaptureSession = {
        let session = AVCaptureSession()

        if session.canSetSessionPreset(self.resolutionQuality) {
            session.sessionPreset = self.resolutionQuality
        } else {
            //print("Failed to set the preset value")
        }
        return session
    }()

    var resolutionQuality = AVCaptureSession.Preset.photo {
        didSet {
            if cameraCaptureSession.canSetSessionPreset(resolutionQuality) {
                cameraCaptureSession.sessionPreset = resolutionQuality
            }
        }
    }

    var inputVideoDevice: AVCaptureDevice?
    var videoConnection: AVCaptureConnection?
    var cameraConnection: AVCaptureConnection?
    var metaOutput: AVCaptureMetadataOutput? = AVCaptureMetadataOutput()
    

    var cameraSettings: [String: String] {
        didSet {
            cameraCaptureSession.beginConfiguration()
            cameraCaptureSession.removeOutput(cameraStillImageOutput)
            setTheCameraStillImageOutputs()
            cameraCaptureSession.commitConfiguration()
        }
    }

    var bufferVideoCallBack: BufferCallBack?
    var bufferAudioCallback: BufferCallBack?
    var bufferMetadataCallBack: (([NSValue]) -> ())?
    var photOutputCallBack: ((UIImage?) -> ())?
    
    var videoSettings: [AnyHashable: Any] {
        didSet {
            cameraCaptureSession.beginConfiguration()
            cameraCaptureSession.removeOutput(videoCaptureOutput)
            setTheVideoOutput()
            cameraCaptureSession.commitConfiguration()
        }
    }

    var errorCallBack: CustomErrorCallback?

    override init() {
        videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
        if #available(iOS 11.0, *) {
            cameraSettings = [AVVideoCodecKey:AVVideoCodecType.jpeg.rawValue]
        } else {
            cameraSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        }
        
        videoOrientation = AVCaptureVideoOrientation.portrait
        super.init()
        initialize()
    }

    private func initialize() {
        addInputsToCameraSession()
        setTheVideoOutput()
        setTheCameraStillImageOutputs()
        setAudioOutput()
        addMetadata()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let currentMetadata = metadataObjects as [AnyObject]
        let boundsArray = currentMetadata
            .flatMap { $0 as? AVMetadataFaceObject }
            .map { (faceObject) -> NSValue in
                let convertedObject = output.transformedMetadataObject(for: faceObject, connection: connection)
                if let bounds = convertedObject?.bounds {
                    let newBounds = CGRect(x: bounds.origin.x * 667, y: bounds.origin.y * 375, width: bounds.size.width * 667, height: bounds.size.height * 375)                    
                    
                   return NSValue(cgRect: newBounds)
                    
                }
                 return NSValue(cgRect: CGRect.zero)
               
                
        }
        
        didOutput(boundsArray as [NSValue])
        
    }
    
    func addMetadata() {
//        let metaOutput = AVCaptureMetadataOutput()
        metaOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.faceQueue", attributes: []))
        cameraCaptureSession.beginConfiguration()
        if let metaOutput = metaOutput {
            if cameraCaptureSession.canAddOutput(metaOutput) {
                cameraCaptureSession.addOutput(metaOutput)
            }
        }
        
        cameraCaptureSession.commitConfiguration()
        metaOutput?.metadataObjectTypes = [.face]
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }

        if NSNotification.Name(keyPath) == NSNotification.Name.AVCaptureSessionRuntimeError {
            let cameraSession = object as? AVCaptureSession

            guard let captureSession = cameraSession else {
                return
            }

            if captureSession.isInterrupted {
                errorCallBack?(nil, MovieBufferErrorHandler.CameraSessionInterrupted)
            }
        }
    }

    func changeCameraSettingsTo(settings: [String: String]) {
        cameraCaptureSession.removeOutput(cameraStillImageOutput)
        setTheCameraStillImageOutputs()
    }

    func changeVideoSettingsTo(settings: [AnyHashable: Any]) {
        cameraCaptureSession.removeOutput(videoCaptureOutput)
        setTheVideoOutput()
    }

    func changeFlashModeTo(torchMode: AVCaptureDevice.TorchMode, flashMode: AVCaptureDevice.FlashMode) {
        
        if let inputVideoDevice = inputVideoDevice {
            if inputVideoDevice.hasFlash && inputVideoDevice.hasTorch {
                do {
                    try inputVideoDevice.lockForConfiguration()
                    inputVideoDevice.torchMode = torchMode
//                    inputVideoDevice.flashMode = flashMode
                    inputVideoDevice.unlockForConfiguration()
                }catch {
                    //
                }
                
            }
        }
    }
    
    func changeToVideoOrientation(_ orientation: UIInterfaceOrientation) {
        switch orientation {
        case .portrait:
            videoConnection?.videoOrientation = .portrait
            cameraConnection?.videoOrientation = .portrait
        case .landscapeLeft:
            videoConnection?.videoOrientation = .landscapeLeft
            cameraConnection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoConnection?.videoOrientation = .landscapeRight
            cameraConnection?.videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            videoConnection?.videoOrientation = .portraitUpsideDown
            cameraConnection?.videoOrientation = .portraitUpsideDown
        case .unknown: break
        }
    }

    fileprivate func addInputsToCameraSession() {

        inputVideoDevice = getCameraDevice(AVMediaType.video, devicePosition: currentDevicePosition)
        let inputAudioDevice = AVCaptureDevice.default(for: .audio)
        if let inputVideoDevice = inputVideoDevice {
            captureCameraInput = try? AVCaptureDeviceInput(device: inputVideoDevice)
        }
        
        if let inputAudioDevice = inputAudioDevice {
            captureAudioInput = try? AVCaptureDeviceInput(device: inputAudioDevice)
        }

        if let captureCameraInput = captureCameraInput {
            if cameraCaptureSession.canAddInput(captureCameraInput) {
                cameraCaptureSession.addInput(captureCameraInput)
            } else {
                errorCallBack?(nil, MovieBufferErrorHandler.FailedToAddCameraInput)
            }
        }
        
        let permission = AudioPermission()
        permission.requestPermission { (status) in
            if status == .Authorized {
                if let captureAudioInput = self.captureAudioInput {
                    if self.cameraCaptureSession.canAddInput(captureAudioInput) {
                        self.cameraCaptureSession.addInput(captureAudioInput)
                    } else {
                        self.errorCallBack?(nil, MovieBufferErrorHandler.FailedToAddAudioInput)
                    }
                }
            }
        }
    }
    

    fileprivate func setTheCameraStillImageOutputs() {

        if cameraCaptureSession.canAddOutput(cameraStillImageOutput) {
            cameraCaptureSession.addOutput(cameraStillImageOutput)
        } else {
            errorCallBack?(nil, MovieBufferErrorHandler.FailedToAddCameraStillImageOutput)
        }

        cameraConnection = cameraStillImageOutput.connection(with: .video)
        cameraConnection?.videoOrientation = videoOrientation
    }

    fileprivate func setAudioOutput() {
        captureAudioDelegate = CaptureAudioBufferDelegate(delegate: self)
        audioOutput.setSampleBufferDelegate(captureAudioDelegate, queue: DispatchQueue.main)

        let permission = AudioPermission().status()

        if permission == .Authorized {
            if self.cameraCaptureSession.canAddOutput(self.audioOutput) {
                self.cameraCaptureSession.addOutput(self.audioOutput)
            } else {
                self.errorCallBack?(nil, MovieBufferErrorHandler.FailedToAddAudioOutput)
            }
        }
    }

    fileprivate func setTheVideoOutput() {
        videoCaptureOutput.videoSettings = videoSettings as! [String : Any]

        captureVideoDelegate = CaptureVideoBufferDelegate(delegate: self)

        videoCaptureOutput.setSampleBufferDelegate(captureVideoDelegate, queue: DispatchQueue.main)
        if cameraCaptureSession.canAddOutput(videoCaptureOutput) {
            cameraCaptureSession.addOutput(videoCaptureOutput)
        } else {
            errorCallBack?(nil, MovieBufferErrorHandler.FailedToAddVideoCaptureOutput)
        }

        videoConnection = videoCaptureOutput.connection(with: .video)
        videoConnection?.videoOrientation = videoOrientation
        
        addMetadata()
    }

    func layer() -> AVCaptureVideoPreviewLayer? {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraCaptureSession)
        videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        return videoPreviewLayer
    }

    fileprivate func getCameraDevice(_ deviceType: AVMediaType, devicePosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDiscovery = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: deviceType, position: devicePosition)
        
        var device: AVCaptureDevice?
        
        let devices = deviceDiscovery.devices
        
        for dev in devices {
            if (dev as AnyObject).position == devicePosition {
                device = dev
                break
            }
        }

        return device
    }

    func startSession() {

        if !cameraCaptureSession.isRunning {
//            cameraCaptureSession.addObserver(self, forKeyPath: NSNotification.Name.AVCaptureSessionRuntimeError.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
            let permissionService = PermissionType.Camera.permissionService
            permissionService.requestPermission { (status) in
                switch status {
                case .Authorized:
                    self.cameraCaptureSession.startRunning()
                default:
                    self.errorCallBack?(nil, MovieBufferErrorHandler.VideoPermissionFailed)
                }
            }
        }
    }

    func stopSession() {
        cameraCaptureSession.stopRunning()
        if (cameraCaptureSession.observationInfo != nil) {
//            cameraCaptureSession.removeObserver(self, forKeyPath: NSNotification.Name.AVCaptureSessionRuntimeError.rawValue)
        }
    }

    func removeObservers() {
        if (cameraCaptureSession.observationInfo != nil) {
//            cameraCaptureSession.removeObserver(self, forKeyPath: NSNotification.Name.AVCaptureSessionRuntimeError.rawValue)
        }
    }

    func changeDeviceTypeTo(position: AVCaptureDevice.Position) {

        cameraCaptureSession.beginConfiguration()
        cameraCaptureSession.removeInput(captureCameraInput!)
        cameraCaptureSession.removeOutput(cameraStillImageOutput)
        cameraCaptureSession.removeOutput(videoCaptureOutput)

        currentDevicePosition = position
        initialize()

        videoConnection?.isVideoMirrored = position == .front ? true : false
        
        cameraCaptureSession.commitConfiguration()
    }
    
    var isMirrored: Bool {
        return videoConnection?.isVideoMirrored ?? false
    }

    func didOutput(_ videoSampleBuffer: CMSampleBuffer) {
        if let bufferCallBack = bufferVideoCallBack {
            bufferCallBack(videoSampleBuffer)
        }
    }
    
    func didOutput(_ boundsArray: [NSValue]) {
        bufferMetadataCallBack?(boundsArray)
    }

    func didOutputAudio(_ audioSampleBuffer: CMSampleBuffer) {
        if let bufferCallBack = bufferAudioCallback {
            bufferCallBack(audioSampleBuffer)
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: cameraSettings)
        cameraStillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension MovieBufferHandler: AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            photOutputCallBack?(nil)
            return
        }
        
        let fixedImage = UIImage(data: data)
        photOutputCallBack?(fixedImage)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let _ = error {
            photOutputCallBack?(nil)
            return
        }
        
        guard let photoSampleBuffer = photoSampleBuffer else {
            photOutputCallBack?(nil)
            return
        }
        
        guard let previewPhotoSampleBuffer = previewPhotoSampleBuffer else {
            photOutputCallBack?(nil)
            return
        }
        
        guard let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            photOutputCallBack?(nil)
            return
        }
        
        let fixedImage = UIImage(data: data)
        
        photOutputCallBack?(fixedImage)
    }
}

private class CaptureVideoBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CaptureVideoDelagateProtocol?

    init(delegate: CaptureVideoDelagateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didOutput(sampleBuffer)
    }
}

private class CaptureAudioBufferDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    weak var delegate: CaptureAudioDelagateProtocol?

    init(delegate: CaptureAudioDelagateProtocol) {
        self.delegate = delegate
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didOutputAudio(sampleBuffer)
    }
}


protocol CaptureVideoDelagateProtocol: class{
    func didOutput(_ videoSampleBuffer: CMSampleBuffer)
    func didOutput(_ boundsArray: [NSValue])
}

protocol CaptureAudioDelagateProtocol: class {
    func didOutputAudio(_ audioSampleBuffer: CMSampleBuffer)
}
