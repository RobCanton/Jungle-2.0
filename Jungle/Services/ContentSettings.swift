//
//  File.swift
//  Jungle
//
//  Created by Robert Canton on 2018-05-21.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation

class ContentSettings {
    
    
    private(set) static var blockedWordsList = ["starwars"]
    private(set) static var blockedWordsDict = [String:Bool]()
    
    static var recentlyUpdated = false
    
    static func addBlockedWord(_ word:String) {
        blockedWordsDict[word] = true
        blockedWordsList.insert(word, at: 0)
        recentlyUpdated = true
    }
    
    static func removeBlockedWord(_ word:String) {
        blockedWordsDict[word] = nil
        for i in 0..<blockedWordsList.count {
            if blockedWordsList[i] == word {
                blockedWordsList.remove(at: i)
                recentlyUpdated = true
                break
            }
        }
        
    }
    
    static func checkContent(ofText text:String) -> [String] {
        var offenses = [String]()
        
        
        
        for word in blockedWordsList {
            if word.isHashtag, text.contains(hashtag: word) {
                offenses.append(word)
            }
            if text.contains(word: word) {
                offenses.append(word)
            }
        }
        return offenses
    }
}

extension String {
    /// stringToFind must be at least 1 character.
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
    
    func contains(word : String) -> Bool
    {
        return self.range(of: "\\b\(word)\\b", options: [ .regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
    }
    
    func contains(hashtag:String) -> Bool {
        return self.range(of: "(?:^|\\s|$)\(hashtag)\\b", options: [ .regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
    }
}
