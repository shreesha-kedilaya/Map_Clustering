//
//  ViewController.swift
//  MLApp
//
//  Created by DImple on 29/11/17.
//  Copyright © 2017 DImple. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation
import CoreMedia


let kDropboxLinkMainBin1 = "https://www.dropbox.com/s/qc01o6g2edambnu/coremldata.bin?dl=0"
let kDropboxLinkModel0Bin1 = "https://www.dropbox.com/s/ljkxhdg1lsztcxi/coremldata.bin?dl=0"
let kDropboxLinkModel1Bin1 = "https://www.dropbox.com/s/1jlv3msw2sfe1hn/coremldata.bin?dl=0"

let kDropboxLinkMainBin = "https://dl.dropboxusercontent.com/s/qc01o6g2edambnu/coremldata.bin"
let kDropboxLinkModel0Bin = "https://dl.dropboxusercontent.com/s/ljkxhdg1lsztcxi/coremldata.bin"
let kDropboxLinkModel1Bin = "https://dl.dropboxusercontent.com/s/1jlv3msw2sfe1hn/coremldata.bin"

let apple = "https://www.dropbox.com/s/8wb4g82k6i4p653/apple.png?dl=0"

class ViewController: UIViewController {

    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    
    let manager = MovieWriterManager.shared()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var shouldCaptureFrame = false
    var currentImage : UIImage?
    var imageBuffer : CMSampleBuffer?
    
    var boundsArray: [NSValue]?
    let wrapper = MLWrapper()
    let emotions = ["Neutral", "Happy", "Sad", "Anger", "Fear", "Surprise", "Disgust", "Contempt"]
    let fileSystemManager = FileSystemManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isHidden = true
        wrapper?.prepare()
        emotionLabel.layer.cornerRadius = 20
        emotionLabel.layer.masksToBounds = true
      
        fileSystemManager.saveModelToDevice()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        manager.initialize {
            if let layer = self.manager.getVideoPreviewLayer() {
                
                self.videoPreviewLayer?.removeFromSuperlayer()
                self.layerView.layer.insertSublayer(layer, at: 0)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.frame
                
                self.manager.startCameraSession()
                self.manager.changeDevicePositionTo(position: .back)
            }
        }
        
        manager.delegate = self
    }
    
    // MARK:- Action Methods
    @IBAction func captureButtonAction(_ sender: UIButton) {
        shouldCaptureFrame = true
    }
    
    @IBAction func cameraFlipAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.manager.changeDevicePositionTo(position: .front)
        }else {
            self.manager.changeDevicePositionTo(position: .back)
        }
    }
    
    // MARK:- Helper Methods
    func detectEmotionsIn(rect: CGRect) {
        
        if let image = currentImage {
            if let cgImage = image.cgImage {

                let imageRef = cgImage.cropping(to: rect)

                if let imageRef = imageRef {

                    let cropImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
                    let resizedImage = resizeImage(image: cropImage, newWidth: 256)
                    let points = wrapper?.doWork(onSampleBuffer: resizedImage, inRects: [NSValue(cgRect: CGRect(x: 0, y: 0, width: 256, height: 256))])

                    let facePointsImage = circle(radius: 2, points: points!, image: resizedImage!)

                    if let points = points {
                        let features = FacialFeatures.calculateFacialFeatures(data: points)
                        
                        var modelPoly : FacialEmotions?
                        do {
                            let urlDoc = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                            let url = urlDoc.appendingPathComponent("FacialEmotions.mlmodelc", isDirectory: true)
                             modelPoly = FacialEmotions(path: url)
                        }catch {
                            print(error.localizedDescription)
                        }
                        
                        let inputPoly  = FacialEmotionsInput(outerBrowRaiser: features[0], browLowerer: features[1], upperLidRaiser: features[2], cheekRaiser: features[3], lidTightener: features[4], NoseWrinkler: features[5], lipCornerPuller: features[6], dimpler: features[7], lipCornerDeppresser: features[8], lowerLipDeppresser: features[9], lipStretcher: features[10], lipTightener: features[11], jawDrop: features[12])

                        //                let input1 = FacialEmotionsInput(outerBrowRaiser: 14, browLowerer: 9, upperLidRaiser: 10, cheekRaiser: 90, lidTightener: 10, NoseWrinkler: 60, lipCornerPuller: 78, dimpler: 1, lipCornerDeppresser: 26, lowerLipDeppresser: 30, lipStretcher: 30, lipTightener: 78, jawDrop: 86)

                        guard let predictionPoly = try? modelPoly?.prediction(input: inputPoly) else {
                            print("error prediction")
                            return
                        }

                        let modelLinear = FacialEmotionsLinearSVM()
                        let inputLinear = FacialEmotionsLinearSVMInput(outerBrowRaiser: features[0], browLowerer: features[1], upperLidRaiser: features[2], cheekRaiser: features[3], lidTightener: features[4], NoseWrinkler: features[5], lipCornerPuller: features[6], dimpler: features[7], lipCornerDeppresser: features[8], lowerLipDeppresser: features[9], lipStretcher: features[10], lipTightener: features[11], jawDrop: features[12])
                        guard let predictionLinear = try? modelLinear.prediction(input: inputLinear) else {
                            print("error prediction")
                            return
                        }
//                        emotionLabel.text = "Poly -- \(emotions[Int((predictionPoly?.emotions)!)])\nLinear -- \(emotions[Int(predictionLinear.emotions)])"
                        emotionLabel.text = "\(emotions[Int(predictionLinear.emotions)])"
                    }
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func circle(radius: CGFloat, points: NSMutableArray,  image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 256, height: 256), false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: 256, height: 256))
        
        for point in points {
            let cgPoint = point as! CGPoint
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.saveGState()
            let rect = CGRect(x: cgPoint.x - radius, y: cgPoint.y - radius, width: radius * 2, height: radius * 2)
            ctx.setFillColor(UIColor.red.cgColor)
            ctx.fillEllipse(in: rect)
            ctx.restoreGState()
            
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
}

// MARK:- MovieWriterDelegate Methods
extension ViewController: MovieWriterDelegate {
    
    func movieWriterManager(manager: MovieWriterManager, didRecieveVideoBuffer buffer: CMSampleBuffer) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return
        }
        
        let image = CIImage(cvImageBuffer: imageBuffer)
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: image)
        let imageSize = CVImageBufferGetDisplaySize(imageBuffer)
        var actualRect = CGRect()
        for ff in faces! {
            
            actualRect = CGRect(x: ff.bounds.origin.x, y: imageSize.height - ff.bounds.origin.y - ff.bounds.height , width: ff.bounds.width, height: ff.bounds.height)
            
            let scaleX = UIScreen.main.bounds.width / imageSize.width
            let scaleY = UIScreen.main.bounds.height / imageSize.height
            
            let x = actualRect.origin.x * scaleX
            let y = actualRect.origin.y * scaleY
            let width = actualRect.width * scaleX
            let height = actualRect.height * scaleY
            
            let boundsRect = CGRect(x: x, y: y, width: width, height: height)
            
            let boundsView = UIView(frame: boundsRect)
            
            boundsView.backgroundColor = UIColor.clear
            boundsView.layer.borderWidth = 3
            boundsView.layer.borderColor = UIColor.red.cgColor
            
            if layerView.subviews.count > 0 {
                for view in layerView.subviews {
                    view.removeFromSuperview()
                }
            }
            layerView?.addSubview(boundsView)
        }
        
        
        if shouldCaptureFrame {
            self.imageBuffer = buffer
            if let image = manager.getCurrentImage(sampleBuffer: buffer) {
                currentImage = image
                shouldCaptureFrame = false
            }
            detectEmotionsIn(rect: actualRect)
        }
    }
    
    func movieWriterManager(manager: MovieWriterManager, didRecieveAudioBuffer buffer: CMSampleBuffer) {
        
    }
    
    func movieWriterManager(manager: MovieWriterManager, didRecieveMetaData boundsArray: [NSValue]) {
        self.boundsArray = boundsArray
        
    }
    
}
