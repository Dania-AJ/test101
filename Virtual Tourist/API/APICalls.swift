//
//  APICalls.swift
//  Virtual Tourist
//
//  Created by Dania A on 29/12/2018.
//  Copyright © Dania A. All rights reserved.
//

import Foundation
import UIKit

class APICalls {
    
    static func getPhotosBasedOnLocation (_ lat : String, _ long : String, completion: @escaping ([Photo]?, NSError?) -> ()) {
        
        let url = buildUrl(lat, long)
        if  url == nil {
            return
        }
        
        let urlRequest = URLRequest (url : url!)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if error != nil {
                //Error code 0 = no internet connectivity
                let unknownError = NSError (domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (nil, unknownError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {return}
            
            if statusCode >= 200 && statusCode < 300 {
                //skip the first 14 characters of the response and also the last character
                
                let range = Range(14..<data!.count - 1)
                let newData = data?.subdata(in: range)
                
                let jsonObject = try! JSONSerialization.jsonObject(with: newData!, options: .allowFragments)
                let responseDictionary = jsonObject as? [String:Any] ?? [:]
                let photosContainer = responseDictionary ["photos"] as? [String:Any] ?? [:]
                let photosArray = photosContainer ["photo"] as? [[String:Any]] ?? [[:]]
                
                //Loop through the array, get every photo dictionary from it, and get the related photo info from that dictionary
                var photosStructArray = [Photo] ()
                
                for dict in photosArray {
                    var photo = Photo ()
                    photo.farm = dict ["farm"] as? Int ?? 0
                    photo.serverId = dict ["server"] as? String ?? ""
                    photo.photoId = dict ["id"] as? String ?? ""
                    photo.secret = dict ["secret"] as? String ?? ""
                    photosStructArray.append(photo)
                } //end for
                
                completion (photosStructArray, nil)
            } else {
                //Error code 1 = response code is not 2xx
                let responseCodeError = NSError (domain: NSURLErrorDomain, code: 1, userInfo: nil)
                completion (nil, responseCodeError)
                return
            }
        }
        
        task.resume()
        
    }
    
    static func downloadImage (imagesUrl : [URL], completion: @escaping ([UIImage]?) -> ()) {
        
        var imagesArray = [UIImage] ()
        var success = true
        
        for i in 0..<imagesUrl.count {
            
            
            let request = URLRequest (url: imagesUrl [i])
            let session = URLSession.shared
            let downloadTask = session.dataTask(with: request) {data, response, error in
                
                if error != nil {return}
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {return}
                
                if statusCode >= 200 && statusCode < 300 {
                    
                    if let imageData = data {
                        imagesArray.append(UIImage (data: imageData)!)
                    } else {
                        success = false
                    }
                    
                } else {
                    success = false
                }
                
                
                if i == imagesUrl.count - 1 {
                    if success {
                        completion (imagesArray)
                    } else {
                        completion (nil)
                    }
                }
                
            }
            
            downloadTask.resume ()
        } //end for
    }
    
}


extension APICalls {
    static func buildUrl (_ lat : String, _ long : String) -> URL? {
        var baseUrlComponents = URLComponents (string:"https://api.flickr.com/services/rest")
        let apiConstants = APIConstants ()
        //I used Daniel Galasko's answer here to know how to build the query parameters: https://stackoverflow.com/questions/34060754/how-can-i-build-a-url-with-query-parameters-containing-multiple-values-for-the-s
        let queryItems = [URLQueryItem (name: apiConstants.key, value: apiConstants.apiKeyValue), URLQueryItem(name: apiConstants.format, value: "json"), URLQueryItem (name: apiConstants.method, value: apiConstants.methodValue), URLQueryItem (name: apiConstants.perPage, value: "50"), URLQueryItem (name: apiConstants.tags, value: ""), URLQueryItem (name: apiConstants.lat, value: lat), URLQueryItem (name: apiConstants.lon, value: long), URLQueryItem (name: apiConstants.accuracy, value: "11")]
        
        baseUrlComponents?.queryItems = queryItems
        let url = baseUrlComponents?.url
        print (url!)
        return url
    }
    
}
