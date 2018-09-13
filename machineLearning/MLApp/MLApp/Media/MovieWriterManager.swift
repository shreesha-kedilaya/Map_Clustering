//
//  MoviewWriterManager.swift
//  VideoAnnotation
//
//  Created by Shreesha on 10/11/17.
//  Copyright © 2017 Shreesha. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import CoreMedia

protocol MovieWriterDelegate: class {
    func movieWriterManager(manager: MovieWriterManager, didRecieveVideoBuffer buffer: CMSampleBuffer)
    func movieWriterManager(manager: MovieWriterManager, didRecieveMetaData boundsArray: [NSValue])
    func movieWriterManager(manager: MovieWriterManager, didRecieveAudioBuffer buffer: CMSampleBuffer)
}

class MovieWriterManager {
    private static var sharedInstance: MovieWriterManager? = nil
    
    weak var delegate: MovieWriterDelegate?
    
    class func shared() -> MovieWriterManager {
        guard let sharedInstance = sharedInstance else {
            self.sharedInstance = MovieWriterManager()
            return self.sharedInstance!
        }
        
        return sharedInstance
    }
    
    func refresh() {
        movieBufferHandler = nil
    }
    
    class func reset() {
        sharedInstance = nil
    }
    
    private var movieBufferHandler: MovieBufferHandler?
    
    func initialize(videoSettings: [AnyHashable: Any] = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)],
         cameraSettings: [String: String] = [AVVideoCodecKey:AVVideoCodecJPEG],
         orientation: UIInterfaceOrientation = .portrait,
         resolution: AVCaptureSession.Preset = AVCaptureSession.Preset.high,
         callBack: (() -> ())?) {
        
        Async.global {
            self.movieBufferHandler?.removeObservers()
            self.movieBufferHandler = MovieBufferHandler()
            self.movieBufferHandler?.videoSettings = videoSettings
            self.movieBufferHandler?.cameraSettings = cameraSettings
            self.movieBufferHandler?.changeToVideoOrientation(orientation)
            self.movieBufferHandler?.resolutionQuality = resolution
        
            self.movieBufferHandler?.errorCallBack = { [weak self] (nserror, customError) in
//                self?.errorCallback?(nserror, customError)
                
                print(nserror)
                print(customError)
            }
            
            
            self.movieBufferHandler?.bufferMetadataCallBack = { [weak self] boundsArray in
                self?.handleMetadata(boundsArray)
            }
            
            self.movieBufferHandler?.bufferVideoCallBack = { [weak self] (buffer) -> () in
                Async.main {
                    self?.handleOutputBuffer(buffer: buffer)
                }
            }
            
            self.movieBufferHandler?.bufferAudioCallback = { [weak self] (buffer) -> () in
                Async.main {
                    self?.handleAudioBuffer(buffer: buffer)
                }
            }
            
            Async.main {
                callBack?()
            }
        }
    }
    
    func startCameraSession() {
        movieBufferHandler?.startSession()
    }
    
    func stopCameraSession() {
        movieBufferHandler?.stopSession()
        movieBufferHandler?.removeObservers()
    }
    
    func isCameraSessionRunning() -> Bool {
        return movieBufferHandler?.cameraCaptureSession.isRunning ?? false
    }
    
    func changeDevicePositionTo(position: AVCaptureDevice.Position) {
        movieBufferHandler?.changeDeviceTypeTo(position: position)
    }
    
    var isMirrored: Bool {
        return movieBufferHandler?.isMirrored ?? false
    }
    
    func changeFlashModeTo(torchMode: AVCaptureDevice.TorchMode, flashMode: AVCaptureDevice.FlashMode) {
        movieBufferHandler?.changeFlashModeTo(torchMode: torchMode, flashMode: flashMode)
    }
    
    func changeVideoOrientation(_ orientation: UIInterfaceOrientation) {
        movieBufferHandler?.changeToVideoOrientation(orientation)
    }
    
    func changeCameraSettingsTo(settings: [String: String]) {
        movieBufferHandler?.changeCameraSettingsTo(settings: settings)
    }
    
    func changeVideoSettingsTo(settings: [AnyHashable: Any]) {
        movieBufferHandler?.changeVideoSettingsTo(settings: settings)
    }
    
    func handleOutputBuffer(buffer: CMSampleBuffer)  {
        delegate?.movieWriterManager(manager: self, didRecieveVideoBuffer: buffer)
    }
    
    func handleMetadata(_ boundsArray: [NSValue]) {
        delegate?.movieWriterManager(manager: self, didRecieveMetaData: boundsArray)
    }
    
    func handleAudioBuffer(buffer: CMSampleBuffer)  {

        delegate?.movieWriterManager(manager: self, didRecieveAudioBuffer: buffer)
    }
    
    func getVideoPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return movieBufferHandler?.layer()
    }
    
    func getCurrentImage(sampleBuffer: CMSampleBuffer) -> UIImage? {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        //TODO: Get the current image from the CVPixelBuffer
        
        let image = getImageFrom(pixelBuffer: pixelBuffer!)
        return image
    }
    
    fileprivate func getImageFrom(pixelBuffer: CVPixelBuffer) -> UIImage{
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext(options: nil)
        let image = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer)))
        
        let uiImage = UIImage(cgImage: image!)
        
        return uiImage
    }
}


