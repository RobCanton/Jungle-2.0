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

func numericShorthand(_ number:Int) -> String {
    var str = "\(number)"
    
    if number >= 1000000 {
        let decimal = Double(number) / 1000000
        str = "\(roundToOneDecimal(decimal))M"
    } else if number >= 100000 {
        let decimal = Int(Double(number) / 1000)
        str = "\(decimal)K"
    } else if number >= 10000 {
        let decimal = Double(number) / 1000
        str = "\(roundToOneDecimal(decimal))K"
    } else if number >= 1000 {
        str.insert(",", at: str.index(str.startIndex, offsetBy: 1))
    }
    return str
}

func roundToOneDecimal(_ value:Double) -> Double {
    return Double(floor(value*10)/10)
}
