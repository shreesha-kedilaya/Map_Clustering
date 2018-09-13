//
//  FileSystemManager.swift
//  MLApp
//
//  Created by DImple on 06/12/17.
//  Copyright © 2017 DImple. All rights reserved.
//

import UIKit

class FileSystemManager: NSObject {

    let filemanager = FileManager.default
    var mainBinUrl, model0BinUrl, model1BinUrl : URL?
    var isDropBox = true
    
    enum BundleBinFileType: String {
        case mainBin = "coremldata1"
        case model0Bin = "coremldata2"
        case model1Bin = "coremldata3"
    }
    
    enum DropboxBinFileType: String {
        case mainBin = "https://dl.dropboxusercontent.com/s/qc01o6g2edambnu/coremldata.bin"
        case model0Bin = "https://dl.dropboxusercontent.com/s/ljkxhdg1lsztcxi/coremldata.bin"
        case model1Bin = "https://dl.dropboxusercontent.com/s/1jlv3msw2sfe1hn/coremldata.bin"
    }
    
    func getBinUrl(isDropBox: Bool, bundleBinFileType: BundleBinFileType, dropboxBinFileType: DropboxBinFileType, completion: @escaping (URL) -> ()) {
        if isDropBox {
            getLocalPathFor(link: dropboxBinFileType.rawValue) { (localUrl) in
                completion(localUrl)
            }
        }else {
            let mainBinUrl = Bundle.main.url(forResource: bundleBinFileType.rawValue, withExtension: "bin")
            if let mainBinUrl = mainBinUrl {
                completion(mainBinUrl)
            }
        }
    }
    
    
    func saveModelToDevice() {
        // create main directory
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let docPath = docPath, let docUrl = URL(string: docPath) {
            
            let mlmodelCPath = docUrl.appendingPathComponent("FacialEmotions.mlmodelc", isDirectory: true)
            let mlmodel0Path = docUrl.appendingPathComponent("FacialEmotions.mlmodelc/model0", isDirectory: true)
            let mlmodel1Path = docUrl.appendingPathComponent("FacialEmotions.mlmodelc/model1", isDirectory: true)
            
            createDirectoryAt(path: mlmodelCPath.absoluteString, completion: { exists in
                getBinUrl(isDropBox: isDropBox, bundleBinFileType: .mainBin, dropboxBinFileType: .mainBin, completion: { (binUrl) in
                    self.saveFileFor(localUrl: binUrl, byAppending: "FacialEmotions.mlmodelc/coremldata.bin", completion: {})
                })
                
                createDirectoryAt(path: mlmodel0Path.absoluteString, completion: {_ in
                    getBinUrl(isDropBox: isDropBox, bundleBinFileType: .model0Bin, dropboxBinFileType: .model0Bin, completion: { (binUrl) in
                        self.saveFileFor(localUrl: binUrl, byAppending: "FacialEmotions.mlmodelc/model0/coremldata.bin", completion: {})
                    })
                })
                
                createDirectoryAt(path: mlmodel1Path.absoluteString, completion: {_ in
                    getBinUrl(isDropBox: isDropBox, bundleBinFileType: .model1Bin, dropboxBinFileType: .model1Bin, completion: { (binUrl) in
                        self.saveFileFor(localUrl: binUrl, byAppending: "FacialEmotions.mlmodelc/model1/coremldata.bin", completion: {})
                    })
                })
            })
        }
    }
    
    func saveFileFor(localUrl: URL, byAppending path: String, completion : @escaping () -> ()) {
        do {
            let urlDoc = try self.filemanager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let binFilePath = urlDoc.appendingPathComponent(path, isDirectory: true)
            self.copyFileFrom(sourceUrl: localUrl, destUrl: binFilePath, completion: { (success) in
                completion()
            })
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func getLocalPathFor(link: String, completion: @escaping (URL) -> ()) {
        guard let url = URL(string: link) else {
            return
        }
        let task = URLSession.shared.downloadTask(with: url, completionHandler: { (url, urlResponse, error) in
            
            if let url = url {
                completion(url)
            }
        })
        task.resume()
    }
    
    func createDirectoryAt(path: String, completion: (Bool) -> ()) {
        var isDirectory: ObjCBool = true
        if filemanager.fileExists(atPath: path, isDirectory: &isDirectory) {
            print("file exists")
            completion(false)
        }else {
            do {
                try filemanager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                completion(true)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func copyFileFrom(sourceUrl : URL, destUrl: URL, completion: (Bool) -> () ){
        
        do {
            try filemanager.copyItem(at: sourceUrl, to: destUrl)
            completion(true)
        }catch {
            let nsError = error as NSError
            print(error.localizedDescription)
            if nsError.code == NSFileWriteFileExistsError {
                do {
                    try FileManager.default.removeItem(at: destUrl)
                } catch {
                    print(error.localizedDescription)
                }
                do {
                    try FileManager.default.copyItem(at: sourceUrl, to: destUrl)
                    print("file replaced")
                } catch {
                    print(error.localizedDescription)
                }
            }
            completion(true)
        }
    }
}
