//
//  GIFService.swift
//  Jungle
//
//  Created by Robert Canton on 2018-04-10.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class GIFService {
    static let API_ROOT = "https://api.tenor.com/v1/"
    static let API_KEY = "C62WPPAKZJ0P"
    
    // Max number of GIFs that can be retrieved
    // to prevent users from overusing API
    static let MAX_OFFSET = 250
    
    static fileprivate var currentDataTask:URLSessionDataTask?
    
    static func clearCurrentTask() {
        currentDataTask?.cancel()
        currentDataTask = nil
    }
    
    static func autoComplete(query:String, completion: @escaping(_ results:[String])->()) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return completion([]) }
        let url = URL(string:"\(API_ROOT)autocomplete?key=\(API_KEY)&q=\(queryEncoded)")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            if let data = data {
                var results = [String]()
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        if let _results = json["results"] as? [String] {
                            results = _results
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(results)
                }
            }
        }
        
        dataTask.resume()
    }
    
    static var tendingGIFImage:UIImage?
    
    static func getTopTrendingGif(completion: @escaping(_ gif:GIF?)->()) {
        var urlStr = "\(API_ROOT)trending?key=\(API_KEY)&media_filter=minimal&limit=1"
        let url = URL(string:urlStr)!
        currentDataTask?.cancel()
        currentDataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var gif:GIF?
            if let data = data {
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        if let resultsArray = json["results"] as? [[String:Any]] {
                            for gifData in resultsArray {
                                gif = GIF.parse(from: gifData)
                                break
                            }
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(gif)
                }
            }
        }
        currentDataTask?.resume()
    }
    
    static func getTrendingGIFs(next:String?, completion: @escaping(_ gifs:[GIF], _ next:String?)->()) {
        var urlStr = "\(API_ROOT)trending?key=\(API_KEY)&media_filter=minimal"
        if let next = next {
            urlStr += "&pos=\(next)"
        }
        let url = URL(string:urlStr)!
        currentDataTask?.cancel()
        currentDataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var gifs = [GIF]()
            var next:String?
            if let data = data {
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        next = json["next"] as? String
                        if let resultsArray = json["results"] as? [[String:Any]] {
                            for gifData in resultsArray {
                                if let gif = GIF.parse(from: gifData) {
                                    gifs.append(gif)
                                }
                            }
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(gifs, next)
                }
            }
        }
        currentDataTask?.resume()
    }
    
    static func search(withQuery query:String, next:String?, completion: @escaping(_ query:String, _ gifs:[GIF], _ next:String?)->()) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return completion(query,[],nil) }
        
        currentDataTask?.cancel()
        var urlStr = "\(API_ROOT)search?key=\(API_KEY)&q=\(queryEncoded)&media_filter=minimal"
        if let next = next {
            urlStr += "&pos=\(next)"
        }
        let url = URL(string:urlStr)!
        currentDataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            self.currentDataTask = nil
            var gifs = [GIF]()
            var next:String?
            if let data = data {
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        next = json["next"] as? String
                        if let resultsArray = json["results"] as? [[String:Any]] {
                            for gifData in resultsArray {
                                if let gif = GIF.parse(from: gifData) {
                                    gifs.append(gif)
                                }
                            }
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(query,gifs, next)
                }
            }
        }
        currentDataTask?.resume()
        
    }
}

class GIF {
    var name:String
    var size:Double
    var contentSize:CGSize
    var aspectRatio:CGFloat
    var high_url:URL
    var low_url:URL
    init(name:String, size:Double, contentSize:CGSize, high:URL, low:URL) {
        self.name = name
        self.size = size
        self.contentSize = contentSize
        self.aspectRatio = contentSize.width / contentSize.height
        self.high_url = high
        self.low_url = low
        
    }
    
    static func parse(from data:[String:Any]) -> GIF? {
        var highURL:URL?
        var lowURL:URL?
        
        var size:Double?
        var dimensions:CGSize?
        let id = data["id"] as? String
        
        if let media = data["media"] as? [[String:[String:Any]]] {
            for dict in media {
                for (format, mediaData) in dict {
                    
                    if let urlStr = mediaData["url"] as? String {
                        let url = URL(string: urlStr)
                        switch format {
                        case "gif":
                            size = mediaData["size"] as? Double
                            if let dimsArray = mediaData["dims"] as? [Double] {
                                dimensions = CGSize(width: dimsArray[0], height: dimsArray[1])
                            }
                            highURL = url
                            break
                        case "tinygif":
                            lowURL = url
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }
        if id != nil, highURL != nil,  lowURL != nil,
            size != nil, dimensions != nil {
            return GIF(name: id!, size: size!,
                       contentSize: dimensions!,
                       high: highURL!, low: lowURL!)
        }
        return nil
    }
}
