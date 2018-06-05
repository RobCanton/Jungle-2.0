//
//  Utilties.swift
//  Jungle
//
//  Created by Robert Canton on 2018-06-03.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation


func createDirectory(_ dirName:String) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dataPath = documentsDirectory.appendingPathComponent(dirName)
    
    do {
        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error creating directory: \(error.localizedDescription)")
    }
}

func clearDirectory(name:String) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dirPath = documentsDirectory.appendingPathComponent(name)
    do {
        let filePaths = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for filePath in filePaths {
            try FileManager.default.removeItem(at: filePath)
        }
    } catch {
        print("Could not clear temp folder: \(error)")
    }
}
